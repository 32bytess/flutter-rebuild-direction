import argparse
import logging

from .collector import collect

parser = argparse.ArgumentParser(description="GitHub Flutter UI Seed Collector")
parser.add_argument("--max", type=int, default=100)
parser.add_argument("--verbose", action="store_true", help="Show debug-level logs")
parser.add_argument(
    "--discover-only",
    action="store_true",
    help="Run discovery and print the repos found, without cloning anything",
)
args = parser.parse_args()

logging.basicConfig(
    level=logging.DEBUG if args.verbose else logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    datefmt="%H:%M:%S",
)

if args.discover_only:
    from .config import DB_PATH
    from .db import init_db
    from .discovery import discover_candidates

    conn = init_db(DB_PATH)
    try:
        for repo in discover_candidates(conn):
            print(
                f"{repo['full_name']}\tstars={repo['stars']}"
                f"\tforks={repo['forks']}\tlicense={repo['license'] or 'none'}"
            )
    finally:
        conn.close()
else:
    collect(max_candidates=args.max)
