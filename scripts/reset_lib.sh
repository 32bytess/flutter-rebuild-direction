#!/bin/sh
''':'
exec python3 "$0" "$@"
':'''
# Reset lib/ to a runnable benchmark app backed by one sample target.
#
# Usage:
#   ./scripts/reset_lib.sh              # samples/01/base.dart
#   ./scripts/reset_lib.sh 5            # samples/05/base.dart
#   ./scripts/reset_lib.sh 5 mutation_3 # samples/05/mutation_3.dart

import re
import sys
from pathlib import Path

# A bootstrap, not a root: this file is exec'd as a path (`./scripts/reset_lib.sh`), so the
# package has to be importable before `scripts.paths` can say where the repository is. That
# is the same exception `scripts/tests/conftest.py` takes, and for the same reason. The
# authoritative root is PROJECT_ROOT below; nothing here counts parents to answer that.
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from scripts.paths import PROJECT_ROOT  # noqa: E402
from scripts.device_runner.transplant import write_transplant  # noqa: E402


USAGE = """usage: ./scripts/reset_lib.sh [sample-number] [base|mutation_N]

Resets the active Flutter lib/ slot:
  samples/<NN>/<role>.dart      -> lib/generated_widget.dart
  samples/<NN>/dependencies.dart -> lib/dependencies.dart
  minimal app wrapper            -> lib/main.dart

Defaults to samples/01/base.dart.
"""

MAIN_DART = """import 'package:benchmark_container/generated_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BenchmarkApp());
}

class BenchmarkApp extends StatelessWidget {
  const BenchmarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Benchmark Container'),
        ),
        body: GeneratedWidget(),
      ),
    );
  }
}
"""


def usage(stream=sys.stdout):
    stream.write(USAGE)


def fail(message, exit_code):
    print(message, file=sys.stderr)
    usage(sys.stderr)
    return exit_code


def main(argv):
    if argv and argv[0] in {"-h", "--help"}:
        usage()
        return 0

    sample_arg = argv[0] if len(argv) >= 1 else "01"
    role = argv[1] if len(argv) >= 2 else "base"

    if not re.fullmatch(r"[0-9]+", sample_arg):
        return fail(
            f"error: sample-number must be numeric, got '{sample_arg}'",
            2,
        )

    if role != "base" and not re.fullmatch(r"mutation_[0-9]+", role):
        return fail(
            f"error: role must be 'base' or 'mutation_N', got '{role}'",
            2,
        )

    sample = f"{int(sample_arg, 10):02d}"

    repo_root = PROJECT_ROOT
    sample_dir = repo_root / "samples" / sample
    target = sample_dir / f"{role}.dart"
    deps = sample_dir / "dependencies.dart"
    lib_dir = repo_root / "lib"

    if not sample_dir.is_dir():
        print(f"error: sample directory not found: samples/{sample}", file=sys.stderr)
        return 1

    if not target.is_file():
        print(f"error: target not found: samples/{sample}/{role}.dart", file=sys.stderr)
        return 1

    if not deps.is_file():
        print(f"error: dependencies not found: samples/{sample}/dependencies.dart", file=sys.stderr)
        return 1

    lib_dir.mkdir(parents=True, exist_ok=True)
    (lib_dir / "main.dart").write_text(MAIN_DART, encoding="utf-8")
    # The staging rule -- which import is rewritten, and the part-file exemption -- belongs to
    # the runner, which does this once per measured execution. This tool asks it rather than
    # restating it; the copy that used to live here rewrote part files and corrupted them.
    staged = write_transplant(
        target, deps, lib_dir / "generated_widget.dart", lib_dir / "dependencies.dart"
    )

    print(f"reset lib/ to samples/{sample}/{role}.dart")
    if not staged:
        print(f"  note: {role} declares no `part 'dependencies.dart';` and the group fixture "
              f"is a part file, so it was NOT staged -- staging it would orphan the part and "
              f"fail `flutter analyze`. This role hoisted nothing and stands on its own.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
