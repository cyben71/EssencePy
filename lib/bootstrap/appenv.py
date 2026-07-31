__version__ = "1.0.3"

import os
import platform
import re
from datetime import datetime
from typing import Optional, Dict
from pathlib import Path
import shutil



class AppEnv:
    """
    A tool class to get information about the execution environment.
    Handles OS detection, date/time utilities, file system helpers,
    and user environment variable loading for any context:
    local, remote, interactive or non-interactive (JupyterLab, VS Code remote, systemd).

    On Linux  : parses ~/.bash_env, ~/.bashrc, ~/.bash_profile, ~/.profile
                and injects ALL exported variables into os.environ (overwrite enabled).
    On Windows: captures full os.environ snapshot (already populated by the OS).

    Calling load() or relaunching init_env() always produces a fresh, complete snapshot.
    """
    alias = "appenv"

    _LINUX_PROFILE_FILES = [
        ".bash_env",
        ".bashrc",
        ".bash_profile",
        ".profile",
    ]

    def __init__(self):
        """Constructor — triggers a full environment load immediately."""
        self._loaded_vars: Dict[str, str] = {}
        self.load()

    #####################################
    ##### PUBLIC METHOD & FUNCTIONS #####
    #####################################

    @property
    def loaded_vars(self) -> Dict[str, str]:
        """
        Return the full snapshot of environment variables loaded by AppEnv.

        On Linux  : variables parsed from shell profile files (including updates).
        On Windows: full os.environ snapshot.

        Returns:
            Dict[str, str]: {key: value} of all loaded variables.
        """
        return self._loaded_vars

    def load(self) -> Dict[str, str]:
        """
        Load (or reload) all environment variables into os.environ.

        Always performs a full reload — existing values in os.environ
        are overwritten if a newer value is found in the profile files.
        Call this after modifying ~/.bash_env or any shell profile,
        without restarting the kernel.

        Returns:
            Dict[str, str]: Full snapshot of loaded variables.

        Example:
            # Initial load (called automatically at init)
            epy = init_env()

            # After modifying ~/.bash_env in your terminal:
            epy.appenv.load()
            print(epy.appenv.loaded_vars)
        """
        self._loaded_vars = {}

        if os.name == "nt":
            self._load_windows()
        else:
            self._load_linux()

        return self._loaded_vars

    @staticmethod
    def get_system() -> str:
        """Return type of system."""
        return f"{platform.system()} ({platform.platform()})"

    @staticmethod
    def get_hostname() -> str:
        """Return hostname."""
        return platform.node()

    @staticmethod
    def get_current_date(pattern: Optional[str] = None) -> str:
        """
        Return current date (default format: %Y-%m-%d).

        Args:
            pattern (str, optional): Pattern for displaying date.

        Returns:
            str: Current date with chosen pattern.

        Example:
            date1 = epy.appenv.get_current_date(pattern='%Y-%m-%d')
            date2 = epy.appenv.get_current_date(pattern='%d/%m/%Y')
        """
        if pattern is None:
            pattern = "%Y-%m-%d"
        return datetime.now().strftime(pattern)

    @staticmethod
    def get_current_time(pattern: Optional[str] = None) -> str:
        """
        Return current time (default format: %H:%M:%S).

        Args:
            pattern (str, optional): Pattern for displaying time.

        Returns:
            str: Current time with chosen pattern.
        """
        if pattern is None:
            pattern = "%H:%M:%S"
        return datetime.now().strftime(pattern)

    @staticmethod
    def is_folder_exists(location: str) -> bool:
        """
        Check if a folder exists at specified location.

        Args:
            location (str): Folder location.

        Returns:
            bool: True if folder exists, False otherwise.
        """
        return os.path.exists(location)

    @staticmethod
    def is_file_exists(location: str) -> bool:
        """
        Check if a file exists at specified location.

        Args:
            location (str): File location.

        Returns:
            bool: True if file exists, False otherwise.
        """
        return os.path.isfile(location)

    @staticmethod
    def rm_file(location: str) -> bool:
        """
        Delete a file if it exists.

        Args:
            location (str): File location.

        Returns:
            bool: True if successfully deleted, False otherwise.
        """
        if os.path.isfile(location):
            try:
                os.remove(location)
                return True
            except Exception:
                print(f"File ({location}) not deleted")
                return False
        print(f"File {location} is not found or is not available")
        return False

    @staticmethod
    def mkdir(location: str) -> bool:
        """
        Create a folder at specified location.

        Args:
            location (str): Folder location to create.

        Returns:
            bool: True if successfully created, False otherwise.
        """
        try:
            os.makedirs(location)
            print(f"Folder {location} successfully created")
            return True
        except Exception:
            print(f"Folder {location} not created")
            return False

    @staticmethod
    def mv_file(source: str, destination: str) -> bool:
        """
        Move a file to a given destination (equivalent to `mv` on Linux).
        If the destination folder tree does not exist, it is created automatically.

        Args:
            source (str): Path of the file to move.
            destination (str): Destination path (file or folder).
                - If `destination` ends with a folder separator or matches
                an existing folder, the file is moved into that folder,
                keeping its original name.
                - Otherwise, `destination` is treated as the full path of
                the destination file (allows renaming on the fly).

        Returns:
            bool: True if the move succeeded, False otherwise.

        Example:
            epy.appenv.mv_file("data/report.csv", "archive/2026/report.csv")
            epy.appenv.mv_file("data/report.csv", "archive/2026/")
        """
        if not AppEnv.is_file_exists(source):
            print(f"File {source} is not found or is not available")
            return False

        dest_path = Path(destination)

        # Determine whether the destination should be treated as a folder
        # (existing folder, or trailing separator notation)
        is_dir_target = destination.endswith(("/", "\\")) or dest_path.is_dir()

        if is_dir_target:
            target_dir = dest_path
            target_file = target_dir / Path(source).name
        else:
            target_dir = dest_path.parent
            target_file = dest_path

        # Create the missing folder tree by reusing AppEnv.mkdir
        if str(target_dir) and not AppEnv.is_folder_exists(str(target_dir)):
            if not AppEnv.mkdir(str(target_dir)):
                return False

        try:
            shutil.move(source, str(target_file))
            print(f"File {source} successfully moved to {target_file}")
            return True
        except Exception as e:
            print(f"File {source} not moved: {e}")
            return False


    @staticmethod
    def cp_file(source: str, destination: str) -> bool:
        """
        Copy a file to a given destination (equivalent to `cp` on Linux).
        If the destination folder tree does not exist, it is created automatically.

        Args:
            source (str): Path of the file to copy.
            destination (str): Destination path (file or folder).
                - If `destination` ends with a folder separator or matches
                an existing folder, the file is copied into that folder,
                keeping its original name.
                - Otherwise, `destination` is treated as the full path of
                the destination file (allows renaming on the fly).

        Returns:
            bool: True if the copy succeeded, False otherwise.

        Example:
            epy.appenv.cp_file("data/report.csv", "backup/2026/report.csv")
            epy.appenv.cp_file("data/report.csv", "backup/2026/")
        """
        if not AppEnv.is_file_exists(source):
            print(f"File {source} is not found or is not available")
            return False

        dest_path = Path(destination)

        # Determine whether the destination should be treated as a folder
        # (existing folder, or trailing separator notation)
        is_dir_target = destination.endswith(("/", "\\")) or dest_path.is_dir()

        if is_dir_target:
            target_dir = dest_path
            target_file = target_dir / Path(source).name
        else:
            target_dir = dest_path.parent
            target_file = dest_path

        # Create the missing folder tree by reusing AppEnv.mkdir
        if str(target_dir) and not AppEnv.is_folder_exists(str(target_dir)):
            if not AppEnv.mkdir(str(target_dir)):
                return False

        try:
            # copy2 preserves metadata (timestamps, permissions), like cp -p
            shutil.copy2(source, str(target_file))
            print(f"File {source} successfully copied to {target_file}")
            return True
        except Exception as e:
            print(f"File {source} not copied: {e}")
            return False
    
    ######################################
    ##### PRIVATE METHOD & FUNCTIONS #####
    ######################################

    def _load_windows(self) -> None:
        """
        Capture full os.environ snapshot on Windows.
        os.environ is already populated by the OS at session startup —
        this method records it into _loaded_vars for display and access.
        """
        for key, value in os.environ.items():
            self._loaded_vars[key] = value

    def _load_linux(self) -> None:
        """
        Parse user shell profile files and inject ALL exported variables
        into os.environ, overwriting existing values.
        Files are processed in priority order: .bash_env first.
        """
        for filename in self._LINUX_PROFILE_FILES:
            profile = Path.home() / filename
            if profile.is_file():
                self._parse_export_file(profile)

    def _parse_export_file(self, file_path: Path) -> None:
        """
        Parse 'export KEY=value' lines from a shell file and inject
        them into os.environ (overwrite enabled).

        Handles:
            export KEY=value
            export KEY="value"
            export KEY='value'
            export KEY=$OTHER_VAR      (resolved via os.path.expandvars)
            export KEY="${OTHER_VAR}"  (resolved via os.path.expandvars)

        Skips silently:
            export KEY=$(command)      (subshell expression)

        Args:
            file_path (Path): Shell file to parse.
        """
        pattern = re.compile(r"^export\s+([A-Za-z_][A-Za-z0-9_]*)=(.*)$")

        with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                match = pattern.match(line)
                if not match:
                    continue

                key   = match.group(1)
                value = match.group(2).strip().strip("'\"")

                if value.startswith("$("):
                    continue

                value = os.path.expandvars(value)
                self._inject(key, value)

    def _inject(self, key: str, value: str) -> None:
        """
        Inject a variable into os.environ and record it in _loaded_vars.
        Overwrites existing values to ensure a fresh state on every load().

        Args:
            key (str): Variable name.
            value (str): Variable value.
        """
        if key:
            os.environ[key] = value
            self._loaded_vars[key] = value