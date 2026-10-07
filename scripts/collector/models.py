from dataclasses import dataclass


@dataclass
class Candidate:
    repo_name: str
    repo_url: str
    stars: int
    forks: int
    license: str
    pattern: str
    description: str
    local_path: str = ""
    item_url: str = ""
    patterns: str = ""  # comma-joined list of every pattern found in the clone
