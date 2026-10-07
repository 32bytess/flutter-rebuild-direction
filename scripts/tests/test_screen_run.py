"""The screening run record, and what it stamps into `exclusions.json`.

`provenance()` had no test of any kind. It also read the raw argparse `Namespace` across a
module seam, so `screen/checkpoints.py` was coupled to `screen_samples.main()`'s flag names
and a rename would have failed silently -- `getattr(args, "prune_to_endpoints", False)` was
there precisely because one flag did not always exist on the object.
"""

from __future__ import annotations

import argparse
import dataclasses
from pathlib import Path

import pytest

from scripts.screen.checkpoints import ScreenRun, provenance


def _args(**overrides):
    """A Namespace with every flag `main()` defines, at its argparse default."""
    base = dict(
        checkpoints=None, screen_checkpoints=None, binding_source=None, vectors=None,
        license_provenance=None, license_candidates=None,
        render_exclusions=None, fixture_store=None,
        exclude_groups=None, strict=False, keep_unpairable=False,
        keep_excluded_revisions=False, include_unfinished=False,
        allow_unequal_bindings=False, allow_shim_form_drift=False,
        allow_unverified=False, fix_images=True,
        prune_imports=True, resume=False, rescreen=False, prune_to_endpoints=False,
        dry_run=False, report_only=False, markdown=False, prune=False, force_prune=False,
        fixtures=False,
    )
    base.update(overrides)
    return argparse.Namespace(**base)


# The digests `screen_mode` computes. Hand-built so this stays a unit test: the real
# `screen_mode` needs the Dart toolchain and the committed tables.
MODE = {
    "rules": "rules-digest", "backend": "dart", "values": "values-digest",
    "licenses": "licences-digest", "render": "render-digest",
    "strict": False, "keep_unpairable": False,
    "screen_revisions": True, "fix_images": True, "prune_imports": True,
}


def test_from_args_is_the_only_place_flag_names_are_read():
    run = ScreenRun.from_args(_args(strict=True, markdown=True))
    assert run.strict is True and run.markdown is True
    assert run.prune_to_endpoints is False


def test_paths_are_resolved_once(tmp_path):
    rel = tmp_path / "prov.jsonl"
    rel.write_text("", encoding="utf-8")
    run = ScreenRun.from_args(_args(license_provenance=rel))
    assert run.license_provenance == rel.resolve()
    assert run.license_provenance.is_absolute()


def test_the_record_is_frozen():
    """A phase must not be able to edit the record another phase is holding."""
    run = ScreenRun.from_args(_args())
    with pytest.raises(dataclasses.FrozenInstanceError):
        run.resume = True


def test_provenance_records_the_pass_not_the_invocation():
    """The behaviour the Namespace side-channel existed to produce.

    `--full` phase 5 prunes, and `--prune-to-endpoints` was never on the command line. The
    record has to say the corpus was pruned anyway, or it describes a tree that does not
    exist. `--full` now derives a per-phase record instead of writing back onto `args`.
    """
    invocation = ScreenRun.from_args(_args(prune_to_endpoints=False))
    phase5 = dataclasses.replace(invocation, resume=True, rescreen=False,
                                 prune_to_endpoints=True)

    assert provenance(MODE, invocation, argv=["--full"])["flags"]["prune_to_endpoints"] is False
    assert provenance(MODE, phase5, argv=["--full"])["flags"]["prune_to_endpoints"] is True
    # ...and deriving it left the record phase 1 was handed alone.
    assert invocation.prune_to_endpoints is False


def test_provenance_carries_every_digest_a_checkpoint_agrees_with():
    out = provenance(MODE, ScreenRun.from_args(_args()), argv=["--source", "x"])
    assert out["rules_digest"] == "rules-digest"
    assert out["values_digest"] == "values-digest"
    assert out["licenses_digest"] == "licences-digest"
    assert out["argv"] == ["--source", "x"]
    assert out["screened_at"].endswith("+00:00")


def test_binding_rule_is_the_negation_of_the_flag():
    on = provenance(MODE, ScreenRun.from_args(_args()), argv=[])
    off = provenance(MODE, ScreenRun.from_args(_args(allow_unequal_bindings=True)), argv=[])
    assert on["flags"]["binding_rule"] is True
    assert off["flags"]["binding_rule"] is False


def test_shim_form_rule_is_the_negation_of_the_flag():
    """R20 is recorded the way R13 is, and for the same reason: a record that cannot say
    whether the rule was enforced cannot be reproduced."""
    on = provenance(MODE, ScreenRun.from_args(_args()), argv=[])
    off = provenance(MODE, ScreenRun.from_args(_args(allow_shim_form_drift=True)), argv=[])
    assert on["flags"]["shim_form_rule"] is True
    assert off["flags"]["shim_form_rule"] is False


def test_tree_flags_are_recorded_as_strings_or_null(tmp_path):
    out = provenance(MODE, ScreenRun.from_args(_args(vectors=tmp_path)), argv=[])
    assert out["flags"]["vectors"] == str(tmp_path.resolve())
    assert out["flags"]["binding_source"] is None
