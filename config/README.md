# config

The inputs that decide what gets measured. The arm-2 corpus is built from the mine plus the files in this folder, nothing
else.

| file | written by | edit by hand? |
|---|---|---|
| `fixture_policy.json` | me | yes: the value for each primitive type, and the lists of types it will not fill |
| `license_policy.json` | me | yes: the allowed SPDX licences, how each is recognised, and an alias map |
| `fixture_values.json` | `python -m scripts.fixture_values --apply` | no. It is merged, never replaced. To fix a rule, correct it and rerun with `--reresolve` |
| `license_provenance.jsonl` | `python3 -m scripts.mining license-provenance` | no. Each row records a check that the shipped transplant is byte-identical to what spm 0.7.1 produces |
| `maximal_branch.json` | `python -m scripts.maximal_branch --apply` | no. It keeps the history of overridden values, and a hand edit would erase it |
| `authored_fixtures/` | me, by editing a group's `dependencies.dart`; copied here automatically | yes, see below |
| `render_exclusions.json` | `python3 -m scripts.render_gate --apply` | only to record something the screenshots cannot show, with the reason in `evidence` |
| `measured_freeze.json` | `python3 -m scripts.screen.freeze --seed` | no. The only edit is `--release <gid> --reason "..."` |

`license_provenance.jsonl` names its build on purpose. The corpus was mined with spm 0.7.0, which counts inlined package
declarations but does not name them. The field that names them first appeared in 0.7.1, which was not yet on pub.dev at the time, so
the runs used a checkout at `../spm-publish`; `pubspec.yaml` now pins 0.7.2 from pub.dev. A row is only usable where 0.7.1 reproduced the 0.7.0 transplant byte for byte.
Anything else is "unattributed" and rule R17 fires.

## Authored fixtures

**Authored fixtures and the use of a language model.** Where the generated `dependencies.dart` of an arm-2 group
would not mount or left display values empty, it was completed by an *authored* fixture. These files were drafted
with a large language model assistant, Claude Sonnet 5, under instructions given in the prompt rather than a written
protocol: realistic literals for display strings and dates; no added widget, logic or function body; no change to a
value that selects the larger branch or to an extracted feature. The instructions were not applied identically to
every group, and the author reviewed and accepted every file. The comment header at the top of each
`dependencies.dart` is template text written by the skeleton generator; for an authored group its account of where
the values came from (and the `fixture_provenance.json` it refers to) does not apply. The headers are left as they
are because these files are the exact bytes that were measured, pinned by hash in `config/measured_freeze.json`.
`python3 -m scripts.authored_fixtures --list` lists the authored groups.

These files contain text taken from third-party applications. Their source, licence and the copy in the data repository are
described in [`authored_fixtures/NOTICE.md`](authored_fixtures/NOTICE.md).


A fixture the generator wrote is regenerated on every screen. A fixture I edited by hand must not be. The store in
`authored_fixtures/<gid>/dependencies.dart` (with `index.json` holding the hash, date and reason) is the safe copy, kept
where a prune cannot reach it. The first tool that sees a fixture no longer matching its recorded hash copies it there, so
editing the Dart file is enough.

```bash
python3 -m scripts.authored_fixtures --list                # which groups are authored
python3 -m scripts.authored_fixtures --adopt 0082 0254     # adopt edits made before the store existed
python3 -m scripts.authored_fixtures --release 0314        # give the group back to the generator
```

`index.json` also records the group's `rev_*.dart` file names. They are content-addressed, so they identify the scope. If
the roles under an id have changed, the fixture is not restored and the group is generated instead.

A group in the store is not a pure function of the mine and the policy files, so a rebuild from nothing is only
byte-identical apart from the store. `--list` gives the number to quote. The fixture values were drafted with the help of
an LLM, under rules I set, and checked by me.

## Rebuilding from nothing

```bash
python3 -m scripts.screen_samples --source probe_v2/samples_v2 --dest new_samples \
        --records new_samples --markdown --full --from-nothing
```

This deletes `new_samples/` and the two generated tables, refuses if anything there was authored or measured, rebuilds
everything, and then checks the result: the regenerated `fixture_values.json` must match the committed one byte for byte,
`maximal_branch.json` must match on its derived content, and the corpus counts must match the published ones. If a check
fails, it rejects the corpus instead of printing a diff. It needs the mine's clones, which are not in this release.

To debug one step, the phases can be run separately:

```bash
python3 -m scripts.fixture_values --init
python3 -m scripts.screen_samples --source probe_v2/samples_v2 --dest new_samples \
        --records new_samples --rescreen --markdown --prune
python3 -m scripts.fixture_values --root new_samples --eligible-only --apply
python3 -m scripts.screen_samples ...                          # again, so the store agrees
python3 -m scripts.maximal_branch --root new_samples --eligible-only --init --apply
python3 -m scripts.screen_samples ... --resume --prune-to-endpoints   # keep only the measured roles
```

Two screen passes are needed because the value fill works on a corpus that has to exist already. The prune goes last and
cannot be undone: the fill reads the roles off disk, so pruning earlier could change a stored value. Do not use `--resume`
in the rebuild above. The checkpoints fold in the digest of the values table, so after `--init` they are all stale by
design.

If you change `fixture_policy.json`, its digest (`values_version()`) changes and every affected checkpoint is invalidated.
That is the intended signal. Do not get around it by editing a generated `dependencies.dart`.

## Render gate

Every screening rule reads source code. This one reads what the phone drew. A transplant can assign a generated `_Stub`
to a typed slot through `dynamic`, and no analysis step complains, but on the phone `build` throws and Flutter paints a red
`RenderErrorBox`, so the measured time is the error box's. `scripts/render_gate.py` looks at each role's raw log and
screenshot for this, using two independent signs:

- the raw log: a stack frame inside the transplanted library means the throw is the role's own.
- the screenshot: the band below the app bar is the error box's colour, or one flat colour.

It does not simply check for grey, because the export deliberately replaces images with a grey rectangle. The error box
over a white Scaffold is (196, 196, 196) and the export's grey is (224, 224, 224), and the gate only looks at the narrow band
around the first.

`R21_renders_error` excludes a role whose error box was measured: that is an exact measurement of a different widget.
`R22_renders_nothing` only annotates (`--strict` excludes), because one flat colour does not say why. A role with neither
screenshot nor log is "unknown", never "ok".

## The freeze

A row in `performance.jsonl` describes particular bytes. If a later re-screen changes those bytes, the row stays and
silently describes code that is no longer there. `measured_freeze.json` pins every file of every measured group, and
`screen/export.py` checks it at the four places that can change them. The check is on the write, so a re-export that
produces identical bytes never triggers it.

```bash
python3 -m scripts.screen.freeze --seed          # pin every measured group
python3 -m scripts.screen.freeze --verify        # report drift, change nothing
python3 -m scripts.screen.freeze --release 0508 --reason "renders RenderErrorBox"
```

`--release` does not say the group was wrong. It records that the rows for the group no longer describe what is on disk and
the group needs re-measuring.

## Two rules that are easy to break

Every value in `fixture_policy.json` is an inert JSON scalar (`String`, `int`, `double`, `num`, `bool`).
`fixture_values.dart_literal()` is the one place a value becomes Dart. A type the table does not fill must be named in
`out_of_scope`, not just left out, otherwise rule R16 cannot tell a declared refusal from a typo and the rebuild check stops
catching it.

Verdicts depend on a rule's `id`, never on its wording. The reason text may be reworded freely, but the ids may not change.
