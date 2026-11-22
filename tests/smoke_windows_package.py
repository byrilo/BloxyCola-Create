import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time
from urllib.error import URLError
from urllib.request import Request, urlopen
from zipfile import ZipFile


def verify_server(place_dir, environment):
    log_path = place_dir / "launcher.log"
    password = "windows-smoke-test"
    request = Request(
        "http://127.0.0.1:8787/api/status",
        headers={"X-PT-Secret": password},
    )
    with log_path.open("wb") as log:
        process = subprocess.Popen(
            ["cmd.exe", "/d", "/c", "StartPlaceTogetherServer.bat", password],
            cwd=place_dir,
            env=environment,
            stdin=subprocess.DEVNULL,
            stdout=log,
            stderr=subprocess.STDOUT,
        )
        try:
            deadline = time.monotonic() + 35
            while process.poll() is None and time.monotonic() < deadline:
                try:
                    with urlopen(request, timeout=1) as response:
                        status = json.load(response)
                except (URLError, TimeoutError):
                    time.sleep(0.5)
                    continue
                if status.get("status") == "online" and status.get("auth_required") is True:
                    print("Server launcher answered its health check.")
                    return
            raise RuntimeError("The server launcher did not start successfully.")
        except Exception:
            log.flush()
            print(log_path.read_text(encoding="utf-8", errors="replace"))
            raise
        finally:
            if process.poll() is None:
                subprocess.run(
                    ["taskkill", "/pid", str(process.pid), "/t", "/f"],
                    capture_output=True,
                    check=False,
                )
                process.wait(timeout=5)


def verify_package(archive_path):
    with tempfile.TemporaryDirectory(prefix="BloxyCola Windows smoke ") as directory:
        root = Path(directory)
        package = root / "Extracted download"
        with ZipFile(archive_path) as archive:
            damaged_file = archive.testzip()
            if damaged_file is not None:
                raise RuntimeError(f"Damaged ZIP entry: {damaged_file}")
            for name in ("StartPlaceTogetherServer.bat", "InstallBloxyCola.bat"):
                contents = archive.read(name)
                if b"\n" in contents.replace(b"\r\n", b""):
                    raise RuntimeError(f"{name} must use CRLF line endings.")
            archive.extractall(package)

        environment = dict(os.environ, LOCALAPPDATA=str(root / "AppData"))
        subprocess.run(
            ["cmd.exe", "/d", "/c", "InstallBloxyCola.bat"],
            cwd=package,
            env=environment,
            stdin=subprocess.DEVNULL,
            check=True,
            timeout=10,
        )
        installed = root / "AppData" / "Roblox" / "Plugins" / "PlaceTogether.rbxmx"
        if installed.read_bytes() != (package / "PlaceTogether.rbxmx").read_bytes():
            raise RuntimeError("The installed plugin differs from the bundled plugin.")
        verify_server(package, environment)


if __name__ == "__main__":
    verify_package(Path(sys.argv[1]).resolve())
