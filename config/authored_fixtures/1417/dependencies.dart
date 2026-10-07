// GENERATED FIXTURE SKELETON -- spm-fixture-v2
//
// Declarations lifted out of this group's transplants so that ONE fixture serves every role in
// it. That is the point of the file: the same values mount for both endpoints of every
// contrast, so a measured difference is attributable to the edit and not to the scaffolding.
//
// HOW THE VALUES GOT HERE. They are not authored by hand and not invented by the generator.
// Each one is resolved by a pre-registered hierarchy and the rule that fired is recorded, per
// binding, in this group's `fixture_provenance.json`:
//
//   relocated        the value really was in the application; `spm isolate` moved it here
//                    verbatim. Do not "tidy" one -- it is a measurement input.
//   upstream_literal not relocated, but the repository declares it at this group's anchor
//                    commit; taken verbatim, with `file@sha` recorded.
//   protocol_constant neither of the above; the committed table in `config/fixture_policy.json`.
//                    Collection cardinality is one declared constant, corpus-wide.
//   maximal_branch   a bool/enum/nullability that decides WHICH subtree renders takes the arm
//                    that renders more. This one OVERRIDES a relocated value, and says so.
//
// WHAT REMAINS TRUE REGARDLESS OF WHO OR WHAT FILLS A SLOT:
//
//   * The same values serve every role in the group. That is what makes the stubbing
//     symmetric across a pair, which is what makes a measured difference attributable to
//     the edit rather than to the scaffolding.
//   * Fixed collection cardinality. A list of 3 in one place and 10 in another is a change
//     in tree size, and tree size is the dependent variable.
//   * Deterministic values only: no `Random`, no `DateTime.now()`, no I/O, no network, no
//     animation controllers left ticking.
//   * Keep `extends` and `implements` clauses exactly as they are. `spm analyze` decides
//     widget versus value object by walking the supertype chain, so a stand-in that stops
//     extending its widget base silently moves allocations into `valueObjectAllocCount`.
//   * Fill before measuring, then freeze. A fixture edited after seeing a result is a
//     fixture the result cannot be defended against.
//
// A slot the hierarchy cannot resolve keeps its `// TODO: value` and is NOT guessed.
// `scripts/fixture_gate.py` then refuses the group, so an unfilled fixture cannot reach the
// device.
//
// This file is a pure function of the mine plus two committed tables, and is regenerated as
// long as it is untouched. The first HAND edit makes it yours: the screen sees the file no
// longer matches the hash it recorded, copies it into config/authored_fixtures/, and never
// generates over it again -- including after a prune deletes this directory, which is how
// the hash alone used to lose an edit. `scripts/authored_fixtures.py --list` says which
// groups the corpus no longer derives from the mine; `--release <group>` hands one back.
// ignore_for_file: unused_import, unused_element, unused_field
part of generated_widget;


// SEEDS -- the values the generated `initState` reads, for which `spm isolate`
// could build none. It declares each of these `late` and leaves it unassigned on
// purpose: a fabricated default would be measured as though it were the value that
// was really there. Assign one below and every role in this group gets it.

// The subject of every role in this group: one Vikunja project. `Project` is a
// declaration-only stand-in whose constructor stores nothing, so the values live on its
// getters below and this is a plain construction -- one allocation, in `initState`, outside
// the measured rebuild. Giving the stand-in real fields would be a change of structure, not
// of value, so it is not made here.
Project fixtureProject = Project();

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class Project {
  Project({
    dynamic id,
    dynamic owner,
    dynamic parentProjectId,
    dynamic description,
    dynamic title,
    dynamic created,
    dynamic updated,
  });
  Project.fromJson(dynamic json);
  // A project as the Vikunja API returns one. `title` is the only field the group
  // renders; the rest are filled so the stand-in is internally consistent, not to
  // change what is measured.
  dynamic get id => 12;
  dynamic get owner => const <String, dynamic>{
    'id': 3,
    'username': 'jdoe',
    'name': 'Jane Doe',
  };
  // 0 is Vikunja's "no parent": this project is itself a parent, which is the case
  // `buildSubProjectSelector` exists for. It is a value, not an unfilled slot.
  dynamic get parentProjectId => 0;
  dynamic get description =>
      'Marketing site relaunch: content audit, new design system, staged rollout '
      'behind a feature flag before the public cutover.';
  dynamic get title => 'Website Relaunch';
  dynamic get created => DateTime.utc(2024, 3, 11, 9, 42, 17);
  dynamic get updated => DateTime.utc(2024, 5, 2, 16, 8, 5);
  dynamic toJSON() => <String, dynamic>{};
  // Left null on purpose: `buildSubProjectSelector` spreads this into a `ListView`,
  // so how many elements it holds IS tree size -- the dependent variable -- and the
  // null arm is the one the mine recorded. Filling it is a methodology decision,
  // not a value fill.
  dynamic get subprojects => null;
  set subprojects(dynamic _) {}
}
