"""The render gate: what the device drew, read back off the artifacts a campaign wrote.

Every fixture here is SYNTHESISED -- a PNG built byte by byte, a log written line by line --
because the point of the module is that it reads real device output, and a test that fed it
its own parsed structures would only be testing the classifier's arithmetic.
"""

from __future__ import annotations

import struct
import zlib
from pathlib import Path

import pytest

from scripts import render_gate, render_png
from scripts.screen import rules


def write_png(path: Path, rgb, width: int = 64, height: int = 64, band=None) -> Path:
    """A solid RGBA PNG, optionally with a different colour over rows [band) of the height."""
    raw = bytearray()
    for y in range(height):
        raw.append(0)                                  # filter type 0, none
        colour = band[1] if band and band[0][0] <= y < band[0][1] else rgb
        raw += bytes([*colour, 255]) * width

    def chunk(kind: bytes, payload: bytes) -> bytes:
        return (struct.pack(">I", len(payload)) + kind + payload
                + struct.pack(">I", zlib.crc32(kind + payload) & 0xFFFFFFFF))

    path.write_bytes(
        render_png.PNG_MAGIC
        + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
        + chunk(b"IDAT", zlib.compress(bytes(raw)))
        + chunk(b"IEND", b""))
    return path


ERROR_BOX = (196, 196, 196)
MATERIAL_SURFACE = (254, 247, 255)
GREY_BOX = (224, 224, 224)          # `--normalise`'s image placeholder. Must NOT fire R21.


def test_the_decoder_reads_a_solid_image(tmp_path):
    png = write_png(tmp_path / "flat.png", MATERIAL_SURFACE)
    total, counts = render_png.region_histogram(png, step=1)
    assert total > 0
    assert counts == {MATERIAL_SURFACE: total}


def test_the_decoder_refuses_what_it_cannot_read(tmp_path):
    """Named, not guessed. A palette PNG decoded as RGB would return plausible nonsense."""
    bad = tmp_path / "bad.png"
    bad.write_bytes(b"not a png at all")
    with pytest.raises(render_png.UnsupportedPng):
        render_png.decode(bad)


def test_the_error_box_is_renders_error(tmp_path):
    png = write_png(tmp_path / "e.png", ERROR_BOX)
    assert render_gate.classify({"shot_evidence": render_gate.shot_evidence(png)}) \
        == "renders_error"


def test_a_flat_surface_is_renders_nothing(tmp_path):
    png = write_png(tmp_path / "n.png", MATERIAL_SURFACE)
    assert render_gate.classify({"shot_evidence": render_gate.shot_evidence(png)}) \
        == "renders_nothing"


def test_the_normalised_image_placeholder_is_not_an_error(tmp_path):
    """`--normalise` REPLACES every image with `Colors.grey.shade300`, so a grey rectangle is
    a desired export artifact. A gate that keyed on "is grey" would condemn the whole corpus;
    this one keys on the error box's own composite, which is 28 steps darker."""
    png = write_png(tmp_path / "g.png", GREY_BOX)
    evidence = render_gate.shot_evidence(png)
    assert evidence["error_grey"] == 0.0
    assert render_gate.classify({"shot_evidence": evidence}) == "renders_nothing"


def test_an_error_box_over_part_of_the_screen_still_fires(tmp_path):
    """One dead list row is still a measurement of the error box, so the share threshold is
    low and the DOMINANT colour is not what decides it."""
    png = write_png(tmp_path / "part.png", MATERIAL_SURFACE, band=((40, 56), ERROR_BOX))
    evidence = render_gate.shot_evidence(png)
    assert evidence["dominant"] == list(MATERIAL_SURFACE)
    assert render_gate.classify({"shot_evidence": evidence}) == "renders_error"


def test_a_mixed_screen_is_ok(tmp_path):
    png = write_png(tmp_path / "ok.png", MATERIAL_SURFACE, band=((40, 56), (12, 34, 56)))
    assert render_gate.classify({"shot_evidence": render_gate.shot_evidence(png)}) == "ok"


def test_no_evidence_is_unknown_not_ok():
    """The census is a floor. A role nobody photographed is not a role that passed."""
    assert render_gate.classify({}) == "unknown"
    assert render_gate.classify({"shot_evidence": {"shot": "x.png", "error": "boom"}}) \
        == "unknown"


LOG = """\
D/SurfaceView( 8693): UPDATE Surface(name=SurfaceView[com.example.benchmark_container])
I/flutter ( 8693): type '_Stub' is not a subtype of type 'String'
I/flutter ( 8693): #0      _GeneratedWidgetState.build (package:benchmark_container/generated_widget.dart:65)
I/flutter ( 8693): #1      StatefulElement.build (package:flutter/src/widgets/framework.dart:5931)
"""


def test_the_log_names_the_throw(tmp_path):
    log = tmp_path / "e0.log"
    log.write_text(LOG)
    assert render_gate.build_exception(log) == \
        "type '_Stub' is not a subtype of type 'String'"


def test_a_throw_from_the_framework_alone_is_not_the_role(tmp_path):
    """Frame zero must be inside the transplanted library. A `pumpAndSettle` timeout or a
    harness error prints a trace too, and neither says the role drew wrong."""
    log = tmp_path / "e1.log"
    log.write_text(LOG.replace("package:benchmark_container/generated_widget.dart",
                               "package:flutter_test/src/widget_tester.dart"))
    assert render_gate.build_exception(log) is None


def test_the_log_outranks_a_healthy_looking_screenshot(tmp_path):
    """The shot is taken after `traceAction`; a role that threw on first build and recovered
    would photograph clean. The trace is what names the throw, so it wins."""
    png = write_png(tmp_path / "fine.png", MATERIAL_SURFACE, band=((40, 56), (12, 34, 56)))
    assert render_gate.classify({"exception": "boom",
                                 "shot_evidence": render_gate.shot_evidence(png)}) \
        == "renders_error"


def test_the_rule_ids_agree_with_the_screener():
    """Two modules, two string literals, one verdict. A rename in one alone would make the
    table's rows unreachable from the screen without failing anything else."""
    assert render_gate.RENDER_ERROR_RULE == rules.RENDER_ERROR_RULE
    assert render_gate.RENDER_NOTHING_RULE == rules.RENDER_NOTHING_RULE
    assert rules.RENDER_ERROR_RULE in rules.reasons()
    assert rules.RENDER_NOTHING_RULE in rules.reasons()


def test_only_the_error_rule_excludes_by_default():
    hard = rules.hard_set(strict=False, keep_unpairable=False, require_finished=True)
    assert rules.RENDER_ERROR_RULE in hard
    assert rules.RENDER_NOTHING_RULE not in hard
    strict = rules.hard_set(strict=True, keep_unpairable=False, require_finished=True)
    assert rules.RENDER_NOTHING_RULE in strict


def test_an_absent_table_is_inert_and_still_versioned(tmp_path, monkeypatch):
    """A corpus screened before any device campaign has no table, and both rules must be
    silent. The digest still has to MOVE when the table first appears, or the checkpoints
    taken while it was absent would resume across its arrival."""
    monkeypatch.setattr(render_gate, "TABLE", tmp_path / "absent.json")
    assert render_gate.load() == {}
    absent = render_gate.version()
    (tmp_path / "absent.json").write_text('{"groups": {}}')
    assert render_gate.version() != absent


def test_the_table_folds_devices_and_keeps_the_worse_verdict():
    surveyed = {
        "0719": {
            "redmi9t": {"rev_001": {"verdict": "renders_nothing",
                                    "shot_evidence": {"dominant": [254, 247, 255]}}},
            "pilot": {"rev_001": {"verdict": "renders_error", "exception": "boom"}},
            "unrecorded": {"rev_002": {"verdict": "ok"}},
        }
    }
    rows = render_gate.table_rows(surveyed)
    assert rows["0719"]["rev_001"]["verdict"] == "renders_error"
    assert rows["0719"]["rev_001"]["devices"] == ["pilot", "redmi9t"]
    assert "rev_002" not in rows["0719"]          # `ok` is not a row


# ---- the SPM_DUMP_ERRORS witness ---------------------------------------------------------
#
# Profile mode collapses repeated errors to "Multiple exceptions (N) were detected during the
# running of the current test" and prints no exception and no stack for any of them. That is
# the entire log for 12 of the roles this gate condemns on pixels: the screenshot proves the
# role drew RenderErrorBox, and nothing on disk says what threw.

DUMP_LOG = """\
I/flutter ( 8693): Multiple exceptions (31) were detected during the running of the current test
I/flutter ( 8693): [SPM:err] type '_Stub' is not a subtype of type 'ThemeMode'
I/flutter ( 8693): [SPM:err] #0      _GeneratedWidgetState.build (package:benchmark_container/generated_widget.dart:97)
I/flutter ( 8693): [SPM:err] #1      StatefulElement.build (package:flutter/src/widgets/framework.dart:5931)
"""


def test_the_dump_line_names_the_throw(tmp_path):
    log = tmp_path / "e0.log"
    log.write_text(DUMP_LOG)
    assert render_gate.build_exception(log) == \
        "type '_Stub' is not a subtype of type 'ThemeMode'"


def test_a_dump_frame_is_not_mistaken_for_the_message(tmp_path):
    """The frames are printed under the same prefix, so the first `[SPM:err]` line that is a
    frame must be skipped rather than returned as the exception."""
    log = tmp_path / "e1.log"
    log.write_text("I/flutter ( 1): [SPM:err] #0      Foo.build (package:x/y.dart:1)\n"
                   "I/flutter ( 1): [SPM:err] Bad state: no element\n")
    assert render_gate.build_exception(log) == "Bad state: no element"


def test_the_dump_witness_works_without_a_transplant_frame(tmp_path):
    """The whole point: these roles have no `#0` inside generated_widget.dart to walk back
    from, which is why the logcat-scraping path returns nothing for them."""
    log = tmp_path / "e2.log"
    log.write_text("I/flutter ( 1): Multiple exceptions (62) were detected\n"
                   "I/flutter ( 1): [SPM:err] Null check operator used on a null value\n")
    assert render_gate.build_exception(log) == "Null check operator used on a null value"


# ---- the merge ---------------------------------------------------------------------------
#
# A pass normally covers the ELIGIBLE ENDPOINTS, and 44 of the 106 roles condemned on
# 2026-09-15 are not endpoints -- they stopped being endpoints precisely BECAUSE R21 excluded
# their contrasts. Replacing the table from such a pass would drop them, R21 would stop firing,
# their contrasts would come back, and the corpus would re-admit roles known to draw an error
# box. The exclusion would have erased its own evidence.

def _pass(gid: str, role: str, verdict: str) -> dict:
    return {gid: {"redmi9t": {role: {"verdict": verdict, "exception": "boom"}}}}


PRIOR = {
    "0452": {"rev_002_46f1fb92": {"verdict": "renders_error", "devices": ["redmi9t"],
                                  "evidence": {"exception": "old"}}},
    "0719": {"rev_002_a87eb48e": {"verdict": "renders_error", "devices": ["redmi9t"],
                                  "evidence": {"exception": "old"}}},
}


def test_a_role_the_pass_never_saw_keeps_its_verdict():
    surveyed = _pass("0452", "rev_002_46f1fb92", "ok")
    merged = render_gate.merge(render_gate.table_rows(surveyed), surveyed, PRIOR)
    assert "0719" in merged, "a group outside this pass was dropped from the table"
    assert merged["0719"]["rev_002_a87eb48e"]["verdict"] == "renders_error"


def test_a_role_the_pass_saw_render_is_cleared():
    surveyed = _pass("0452", "rev_002_46f1fb92", "ok")
    merged = render_gate.merge(render_gate.table_rows(surveyed), surveyed, PRIOR)
    assert "0452" not in merged, "a repaired role must lose its row"


def test_a_role_the_pass_saw_still_throwing_keeps_a_row():
    surveyed = _pass("0452", "rev_002_46f1fb92", "renders_error")
    merged = render_gate.merge(render_gate.table_rows(surveyed), surveyed, PRIOR)
    assert merged["0452"]["rev_002_46f1fb92"]["verdict"] == "renders_error"
    assert merged["0452"]["rev_002_46f1fb92"]["evidence"]["exception"] == "boom", \
        "the new evidence should replace the old, not the other way round"


def test_unknown_cannot_clear_a_verdict():
    """`unknown` means no screenshot and no log -- no evidence at all. Letting it clear a row
    would make a pass that found nothing indistinguishable from one that found a clean render.
    """
    surveyed = _pass("0452", "rev_002_46f1fb92", "unknown")
    merged = render_gate.merge(render_gate.table_rows(surveyed), surveyed, PRIOR)
    assert merged["0452"]["rev_002_46f1fb92"]["verdict"] == "renders_error"


def test_observed_names_only_what_carried_evidence():
    surveyed = {"0452": {"redmi9t": {
        "a": {"verdict": "ok"}, "b": {"verdict": "unknown"},
        "c": {"verdict": "renders_nothing"}}}}
    assert render_gate.observed(surveyed) == {("0452", "a"), ("0452", "c")}


def test_a_row_says_which_root_saw_it(tmp_path):
    surveyed = _pass("0452", "rev_002_46f1fb92", "renders_error")
    rows = render_gate.table_rows(surveyed, tmp_path / "dataset-validate")
    assert rows["0452"]["rev_002_46f1fb92"]["observed_in"].endswith("dataset-validate")


# ---- the debug error box ------------------------------------------------------------------
#
# `device_runner shots` builds DEBUG, and `RenderErrorBox.backgroundColor` is
# `Color(0xF0900000)` under `assert` and `Color(0xF0C0C0C0)` otherwise (SDK
# `rendering/error.dart`). A gate that knew only the grey would score every debug error box as
# `ok` -- silent, and permissive, which is the worst way for a gate to be wrong.

DEBUG_ERROR_BOX = (151, 15, 15)      # 0xF0900000 over the white Scaffold
ERROR_TEXT = (255, 255, 102)         # 0xFFFFFF66, the debug error text


def test_the_debug_error_box_is_renders_error(tmp_path):
    png = write_png(tmp_path / "d.png", DEBUG_ERROR_BOX)
    assert render_gate.classify({"shot_evidence": render_gate.shot_evidence(png)}) \
        == "renders_error"


def test_the_debug_box_with_its_text_is_still_renders_error(tmp_path):
    """Debug draws yellow monospace over the box, so `flat` drops below the
    `renders_nothing` threshold. The red SHARE is what has to decide, not flatness."""
    png = write_png(tmp_path / "dt.png", DEBUG_ERROR_BOX, band=((20, 44), ERROR_TEXT))
    evidence = render_gate.shot_evidence(png)
    assert evidence["flat"] < render_gate.FLAT
    assert render_gate.classify({"shot_evidence": evidence}) == "renders_error"


def test_an_ordinary_dark_red_widget_is_not_the_error_box(tmp_path):
    """Material's `red700` is (211, 47, 47) and an app is entitled to fill a screen with it.
    The band is tight around (151, 15, 15) so a real red does not land in it."""
    png = write_png(tmp_path / "r.png", (211, 47, 47))
    evidence = render_gate.shot_evidence(png)
    assert evidence["error_red"] == 0.0
    assert render_gate.classify({"shot_evidence": evidence}) == "renders_nothing"


def test_the_two_boxes_are_counted_apart(tmp_path):
    """Which box appeared says which binary drew it, so they are never pooled."""
    grey = render_gate.shot_evidence(write_png(tmp_path / "g.png", ERROR_BOX))
    red = render_gate.shot_evidence(write_png(tmp_path / "rr.png", DEBUG_ERROR_BOX))
    assert (grey["error_grey"], grey["error_red"]) == (1.0, 0.0)
    assert (red["error_grey"], red["error_red"]) == (0.0, 1.0)


def test_a_row_records_the_build_that_drew_it():
    surveyed = {"0719": {"redmi9t": {"rev_001": {"verdict": "renders_error",
                                                 "exception": "boom"}}}}
    row = render_gate.table_rows(surveyed, None, "debug")["0719"]["rev_001"]
    assert row["build_mode"] == "debug"


def test_evidence_written_before_the_red_signature_still_classifies():
    """A row from the 2026-09-15 profile campaign has no `error_red` key at all."""
    old = {"shot": "x.png", "dominant": [196, 196, 196], "flat": 1.0, "error_grey": 1.0}
    assert render_gate.classify({"shot_evidence": old}) == "renders_error"
