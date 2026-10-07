import json
import subprocess
from pathlib import Path

from scripts.mining.config import REPOS_ROOT
from scripts.paths import PROJECT_ROOT


def clone_repos(jsonl_path, target_root):
    jsonl_path = Path(jsonl_path)
    target_root = Path(target_root)

    if not target_root.exists():
        target_root.mkdir(parents=True)
        print(f"Created target root: {target_root}")

    with open(jsonl_path, "r") as f:
        for line in f:
            if not line.strip():
                continue
            data = json.loads(line)
            repo_url = data["repo_url"]
            repo_name = data["repo_name"]

            folder_name = repo_name.replace("/", "_")
            target_dir = target_root / folder_name

            if target_dir.exists():
                print(f"Skipping {repo_name}, already exists at {target_dir}")
                continue

            print(f"Cloning {repo_name} into {target_dir}...")
            try:
                subprocess.run(
                    ["git", "clone", "--depth", "1", repo_url, str(target_dir)],
                    check=True,
                )
            except subprocess.CalledProcessError as e:
                print(f"Failed to clone {repo_name}: {e}")


if __name__ == "__main__":
    project_root = PROJECT_ROOT
    candidates_file = project_root / "data" / "candidates.jsonl"
    # Clones live outside the repository; see scripts/mining/config.py for the one
    # definition of that root.
    target_directory = REPOS_ROOT
    clone_repos(candidates_file, target_directory)
