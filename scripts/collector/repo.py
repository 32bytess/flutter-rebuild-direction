import logging
import shutil
import subprocess
from pathlib import Path

from .config import REPOS_DIR

log = logging.getLogger(__name__)


def clone_repo(repo_url: str, repo_name: str) -> Path | None:
    # repo_name can contain '/', replace with '_'
    safe_repo_name = repo_name.replace("/", "_")

    dest_dir = REPOS_DIR / safe_repo_name
    if dest_dir.exists():
        log.debug("Repo already exists: %s", dest_dir)
        return dest_dir

    dest_dir.mkdir(parents=True, exist_ok=True)
    log.info("Cloning %s to %s", repo_url, dest_dir)
    try:
        subprocess.run(
            ["git", "clone", "--depth", "1", repo_url, str(dest_dir)],
            check=True,
            capture_output=True,
            text=True,
        )
        return dest_dir
    except subprocess.CalledProcessError as e:
        log.error("Failed to clone %s: %s", repo_url, e.stderr)
        if dest_dir.exists():
            # If it failed, don't leave an empty directory
            try:
                shutil.rmtree(dest_dir)
            except Exception:
                pass
        return None
