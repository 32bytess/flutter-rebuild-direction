/// Lifting a transplanted widget's constructor fields into the group's shared fixture.
///
/// WHY.
///
/// `spm isolate` copies the commit's own `GeneratedWidget` constructor verbatim, so a scope
/// whose widget declared `required this.title` emits
/// `const GeneratedWidget({required this.title, Key? key})` and nothing can write
/// `GeneratedWidget()`. To give the runner something to mount, the extractor adds a
/// `GeneratedWidget.fixture()` whose initialisers it INVENTS -- `title = ''` -- and, when a
/// field has a type it cannot build a value for, emits no such constructor at all
/// (`transplant_extractor.dart` `_buildFixtureConstructor` returns the empty string).
///
/// Both halves are defects, and they are the same defect:
///
///   * An invented value is a measurement input that nobody declared. It is not hoisted, so
///     it is not in `dependencies.dart`, not recorded in `fixture_provenance.json`, not
///     visible to `scripts/fixture_gate.py`, and cannot be filled by hand. Two roles in one
///     group can carry different ones and the fixture-clash check will not see it, because
///     it compares fixtures and this value is not in the fixture.
///   * A field whose type nothing could build loses the constructor entirely, and the role
///     cannot be mounted at all. 540 roles across 74 groups of the 2026-09 mine are in that
///     state, and the screen never noticed: `revisions.jsonl` carries no `fixtureConstructor`
///     column, so 8 of them reached the exported corpus.
///
/// WHAT THIS DOES.
///
/// Every constructor field becomes a binding in the group's shared fixture, reached the same
/// way the scope's own relocated state already is -- a `late` field on the `State`, assigned
/// in `initState` from a top-level fixture name:
///
///     late String fixtureTitle;          // dependencies.dart, hand-filled
///
///     class _GeneratedWidgetState ... {
///       late String title;
///       void initState() { super.initState(); title = fixtureTitle; }
///       Widget build(...) => Text(title);   // was widget.title
///     }
///
/// That is the shape `spm isolate` 0.7.0 already emits for the scope's own initial state
/// (`index = fixtureIndex`), so a lifted constructor field is indistinguishable downstream
/// from a lifted `State` field: `_Reach` picks the assignment up through the same
/// `_MountAssignments` walk, `_isSeed` classifies the declaration through the same test, the
/// fixture gate refuses an unfilled one through the same `// TODO: value`, and R13 compares
/// it through the same binding set.
///
/// THE COPIED CONSTRUCTOR GOES, in state mode, and the widget's fields go with it. Once the
/// `State` declares every lifted field and `build` reads those, the fields on the widget are
/// dead weight and the constructor that required them is the only thing standing between a
/// mined role and `GeneratedWidget()`:
///
///     class GeneratedWidget extends StatefulWidget {
///       const GeneratedWidget({super.key});
///       ...
///     }
///
/// That is what the corpus needs and did not have. The mount site is fixed and unnamed --
/// `lib/main.dart` and `scripts/reset_lib.sh` both write `body: GeneratedWidget()`, and
/// nothing in the repository ever calls `.fixture()` -- so a role whose commit declared
/// `required this.title` did not compile when it was staged. 61 of the 273 roles exported to
/// `new_samples_v3` were in that state on 2026-09-09.
///
/// `GeneratedWidget.fixture` goes too: the unnamed constructor now does its job. It survives
/// in [LiftMode.constructor], and in a state-mode file [_argumentFreeWidgetEdits] refuses to
/// make bare, where its initialisers READ the fixture bindings instead of inventing values --
/// which also means it can always be emitted, since the binding exists whatever the field's
/// type is.
///
/// A role whose widget field names a binding the file ALREADY declares is untouched by any of
/// this, and keeps the constructor the commit wrote. [_constructorFields] skips such a field,
/// on the reading that it has been lifted once already, and the skip empties `fields` before
/// the widget edits are ever reached. 555 of the 3,899 argument-taking roles in
/// `probe_v2/samples_v2` are in that state on 2026-09-09, almost always because the scope's
/// own `_images` seeded `fixtureImages` and the widget's `images` wants the same name.
/// Sharing the one binding between them is a decision about what the group mounts, not a
/// mechanical rewrite, so it is not taken here.
///
/// WHY `build` IS REWRITTEN, AND WHY THAT IS SAFE.
///
/// `widget.title` becomes `title`, inside the `State` class only. The build body is a
/// measurement input, so this needs an argument and not an assurance. The argument is that no
/// feature counts an identifier access: `helperReferenceCount` is the only feature that
/// visits a bare `SimpleIdentifier`, and `_maybeCountHelperReference` returns early for a
/// `PropertyAccessorElement` that is not an origin declaration -- which is what a plain field
/// resolves to in BOTH shapes. Nothing else in `build_metrics_visitor` reads a
/// `PrefixedIdentifier` at all.
///
/// That is a claim about `spm analyze`, so it is checked rather than believed:
/// `scripts/widget_field_fidelity.py` analyses every exported role before and after the lift
/// and refuses any group whose 14-feature vector moved.
library;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'fixture.dart' show declarationNameToken;

/// One field on its way from the widget's constructor to the group's fixture.
class LiftedField {
  /// The field as the commit declared it: `title`.
  final String name;

  /// The name the `State` reads it under. Almost always [name]; see [_stateName].
  final String local;

  /// The top-level fixture binding: `fixtureTitle`.
  final String binding;

  /// The declared type, verbatim. `String`, `List<String>?`, `AnimationController?`.
  final String type;

  LiftedField(this.name, this.local, this.binding, this.type);
}

/// The lift's result. [text] is unchanged and [fields] empty when there was nothing to do.
typedef LiftResult = ({String text, List<LiftedField> fields});

/// How far the lift goes.
///
/// Both modes hoist every constructor field into a declared fixture binding, and both leave
/// the widget mountable with no argument whatever the field's types are -- that is what fixes
/// the roles the extractor could build no constructor for. They differ in what the MEASURED
/// region ends up looking like, and in how the widget gets mounted:
///
///   * [LiftMode.constructor] leaves the build body byte-identical. `build` goes on reading
///     `widget.title`; what changed is where `title` came from. The fields and the copied
///     constructor stay, and `GeneratedWidget.fixture` is what mounts the role.
///   * [LiftMode.state] additionally gives the `State` a `late final` field per constructor
///     field (bare `late` where the scope's own code assigns that name), assigns it in
///     `initState`, and rewrites `widget.title` to `title` -- the shape `spm isolate` already
///     emits for the scope's own relocated state. The widget is then left with
///     `const GeneratedWidget({super.key})` and nothing else, since the `State` owns the
///     fields and `build` no longer reads them.
///
/// [LiftMode.state] is what the corpus is built in. The cost is the
/// `helperReferenceCount` move below; it is measured by `scripts/widget_field_fidelity.py`
/// and reported as a threat to validity rather than absorbed.
///
/// [LiftMode.state] is NOT feature-neutral, and the difference is not subtle. `State.widget`
/// is itself an explicitly declared widget-returning getter, so `spm analyze` counts every
/// `widget.` access as a helper reference: removing them moves `helperReferenceCount` on any
/// role that had one inside the measured region. Measured on the 2026-09-08 corpus: 20 of 195
/// roles, one feature, `helperReferenceCount` only -- and unequally between the two endpoints
/// of a pair, so the contrast delta moves too. `scripts/widget_field_fidelity.py` is what
/// produced that number and is how any later claim about it must be checked.
enum LiftMode { constructor, state }

const _kStateClass = '_GeneratedWidgetState';
const _kWidgetClass = 'GeneratedWidget';

/// A class's members, across both analyzer versions the package supports.
///
/// Analyzer 14 moved them behind a `ClassBody`; analyzer 13 has them on the declaration.
/// Read dynamically for the same reason `classLike` and `declarationNameToken` do -- a static
/// read does not compile against the other version.
List<ClassMember> classMembers(ClassDeclaration declaration) {
  final dynamic node = declaration;
  try {
    return ((node.body as dynamic).members as Iterable).cast<ClassMember>().toList();
  } on NoSuchMethodError {
    return (node.members as Iterable).cast<ClassMember>().toList();
  }
}

/// The offset just past a class body's opening brace: where an inserted member goes.
int classBodyOpen(ClassDeclaration declaration) {
  final dynamic node = declaration;
  try {
    return ((node.body as dynamic).leftBracket as Token).end;
  } on NoSuchMethodError {
    return (node.leftBracket as Token).end;
  }
}

/// `fixtureTitle` from `title`. Matches the names `spm isolate` 0.7.0 already generates for
/// the scope's own relocated state, so the two kinds of binding are named alike.
String bindingNameFor(String field) {
  final bare = field.startsWith('_') ? field.substring(1) : field;
  if (bare.isEmpty) return 'fixtureValue';
  return 'fixture${bare[0].toUpperCase()}${bare.substring(1)}';
}

/// Lift [unit]'s widget constructor fields into fixture bindings.
///
/// Returns the rewritten source and what was lifted. Idempotent: a file whose bindings are
/// already declared is returned untouched, so re-running the export over `--dest` is a no-op
/// rather than a second lift.
LiftResult liftWidgetFields(
  String text,
  CompilationUnit unit, {
  LiftMode mode = LiftMode.constructor,
}) {
  ClassDeclaration? widget;
  ClassDeclaration? state;
  final topLevel = <String>{};
  for (final d in unit.declarations) {
    if (d is TopLevelVariableDeclaration) {
      for (final v in d.variables.variables) {
        topLevel.add(v.name.lexeme);
      }
      continue;
    }
    if (d is! ClassDeclaration) continue;
    // `declarationNameToken`, not `.name`: analyzer 14 moved a class's name onto a
    // `ClassNamePart` child and dropped the getter. See `fixture.dart`.
    switch (declarationNameToken(d)?.lexeme) {
      case _kWidgetClass:
        widget = d;
      case _kStateClass:
        state = d;
    }
  }
  if (widget == null || state == null) return (text: text, fields: const []);

  final fields = _constructorFields(widget, state, topLevel);
  if (fields.isEmpty) return (text: text, fields: const []);

  // Every edit is an offset span into `text`, applied last-first so the earlier ones keep
  // the offsets they were computed against.
  final edits = <({int start, int end, String text})>[];

  if (mode == LiftMode.state) {
    edits.addAll(_stateEdits(state, fields));
    edits.addAll(_widgetReferenceEdits(state, fields));
  }
  // In state mode the `State` owns every lifted field, so the widget can shed them and take
  // nothing but a key. `_argumentFreeWidgetEdits` returns null for the one file it cannot
  // leave compiling, and that file falls back to the named fixture constructor -- which is
  // also what constructor mode always uses.
  final bare =
      mode == LiftMode.state ? _argumentFreeWidgetEdits(text, widget, fields) : null;
  edits.addAll(bare ?? [_fixtureConstructorEdit(widget, fields)]);
  edits.add(_bindingsEdit(text, fields));

  final ordered = edits.where((e) => e.start >= 0).toList()
    ..sort((a, b) => b.start.compareTo(a.start));
  var out = text;
  for (final e in ordered) {
    out = out.replaceRange(e.start, e.end, e.text);
  }
  return (text: out, fields: fields);
}

/// The widget's own instance fields, minus what is not the commit's data.
///
/// A static is not per-instance state, and a field with no written type cannot be redeclared
/// on the `State` without inferring one -- inference here would be a guess.
///
/// A field named `key` is NOT skipped. `Widget.key` is inherited and never appears as a
/// declaration, so anything reaching this loop under that name is a field the commit itself
/// declared, shadowing it. Skipping it emitted a `GeneratedWidget.fixture` that left a
/// `final Key? key` uninitialised -- group `0526`, which is one of the roles the extractor
/// had already refused a constructor for.
List<LiftedField> _constructorFields(
  ClassDeclaration widget,
  ClassDeclaration state,
  Set<String> topLevel,
) {
  // Members AND locals. A `State` method holding `final herb = ...` is not a contradiction
  // with a widget field of that name -- until `widget.herb` becomes `herb`, at which point
  // the reference resolves to the local and Dart rejects it outright when the local is
  // declared further down the block (`referenced_before_declaration`, group `0358`). The
  // whole class is one namespace for this purpose: a name declared anywhere inside it is
  // taken, wherever the references happen to be.
  final locals = _Locals();
  state.accept(locals);
  final stateNames = {
    for (final m in classMembers(state))
      if (m is FieldDeclaration)
        for (final v in m.fields.variables) v.name.lexeme,
    for (final m in classMembers(state))
      if (m is MethodDeclaration) m.name.lexeme,
    ...locals.names,
  };

  final out = <LiftedField>[];
  for (final member in classMembers(widget)) {
    if (member is! FieldDeclaration || member.isStatic) continue;
    final type = member.fields.type?.toSource();
    if (type == null) continue;
    for (final v in member.fields.variables) {
      final name = v.name.lexeme;
      final binding = bindingNameFor(name);
      // Already lifted -- this is a re-run over an exported tree.
      if (topLevel.contains(binding)) continue;
      out.add(LiftedField(name, _stateName(name, stateNames), binding, type));
    }
  }
  return out;
}

/// Every local variable and parameter declared anywhere in a class.
class _Locals extends RecursiveAstVisitor<void> {
  final names = <String>{};

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    names.add(node.name.lexeme);
    super.visitVariableDeclaration(node);
  }

  // The whole list rather than one parameter kind: analyzer 14 reshaped the individual
  // parameter classes, and `FormalParameter.name` is the getter both versions keep.
  @override
  void visitFormalParameterList(FormalParameterList node) {
    for (final parameter in node.parameters) {
      final name = parameter.name?.lexeme;
      if (name != null) names.add(name);
    }
    super.visitFormalParameterList(node);
  }

  @override
  void visitDeclaredIdentifier(DeclaredIdentifier node) {
    names.add(node.name.lexeme);
    super.visitDeclaredIdentifier(node);
  }
}

/// Every simple name the class ASSIGNS TO, anywhere inside it.
///
/// Read by [_stateEdits] to decide whether a lifted field may be declared `late final`. Only a
/// bare `SimpleIdentifier` target counts: `other.x = 1` and `map['x'] = 1` assign something
/// else that happens to be spelled the same, and treating them as assignments to the field
/// would drop `final` for no reason.
///
/// Compound assignment (`x += 1`) and increment (`x++`, `--x`) are assignments too, and are the
/// forms that would otherwise slip through -- a `late final` counter is the exact shape that
/// compiles under a naive check and fails under the analyzer.
class _Assignments extends RecursiveAstVisitor<void> {
  final names = <String>{};

  void _record(Expression? target) {
    if (target is SimpleIdentifier) names.add(target.name);
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    _record(node.leftHandSide);
    super.visitAssignmentExpression(node);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    _record(node.operand);
    super.visitPostfixExpression(node);
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    _record(node.operand);
    super.visitPrefixExpression(node);
  }
}

/// What the `State` calls the lifted field.
///
/// Its own name, unless the `State` already declares that name -- as a member, a local or a
/// parameter. A scope whose widget declares `final String title` and whose state declares its
/// own `title` is not a contradiction, and shadowing one with the other would change which
/// value `build` reads, or fail to compile outright.
String _stateName(String field, Set<String> taken) {
  if (!taken.contains(field)) return field;
  final bare = field.startsWith('_') ? field.substring(1) : field;
  return 'widget${bare[0].toUpperCase()}${bare.substring(1)}';
}

/// `late final T x;` declarations plus the mount assignments, inserted into the `State` body.
///
/// The assignments go inside `initState` after `super.initState()`, or into one written for
/// the purpose. They must run at mount and nowhere else: `_Reach` reads
/// `Region.lifecycle` to decide that a binding is assigned once rather than per rebuild, and
/// an assignment anywhere else would classify every lifted field as part of the tree.
///
/// `final` WHERE IT IS PROVABLE, bare `late` otherwise. A lifted field is assigned exactly
/// once, by the `initState` written just below, so `late final` is the honest declaration and
/// the one that turns the once-only property into a compile error rather than a comment. It is
/// not unconditional: the name the `State` reads the field under is [LiftedField.local] --
/// the field's own name whenever the `State` had not already taken it -- and a member of the
/// scope's own code may assign that name. `final` there would not compile, and a corpus that
/// fails to build is worse than one carrying a weaker modifier. [_Assignments] answers the
/// question rather than assuming it.
List<({int start, int end, String text})> _stateEdits(
  ClassDeclaration state,
  List<LiftedField> fields,
) {
  final assigned = _Assignments();
  state.accept(assigned);
  String modifier(LiftedField f) =>
      assigned.names.contains(f.local) ? 'late' : 'late final';

  final declarations = [
    for (final f in fields) '  ${modifier(f)} ${f.type} ${f.local};',
  ].join('\n');
  final assignments = [
    for (final f in fields) '    ${f.local} = ${f.binding};',
  ].join('\n');

  for (final member in classMembers(state)) {
    if (member is MethodDeclaration && member.name.lexeme == 'initState') {
      final body = member.body;
      if (body is BlockFunctionBody) {
        // After `super.initState()` when there is one: a lifted field read by an override
        // that runs inside it would otherwise be read before it is assigned.
        final statements = body.block.statements;
        var at = body.block.leftBracket.end;
        for (final s in statements) {
          if (s is ExpressionStatement) {
            final e = s.expression;
            if (e is MethodInvocation &&
                e.target is SuperExpression &&
                e.methodName.name == 'initState') {
              at = s.end;
              break;
            }
          }
        }
        final bodyStart = classBodyOpen(state);
        return [
          (start: at, end: at, text: '\n$assignments'),
          (start: bodyStart, end: bodyStart, text: '\n$declarations\n'),
        ];
      }
    }
  }

  // No `initState` to extend: write one, with the declarations, at the top of the body.
  final at = classBodyOpen(state);
  return [
    (
      start: at,
      end: at,
      text:
        '\n$declarations\n\n'
        '  @override\n'
        '  void initState() {\n'
        '    super.initState();\n'
        '$assignments\n'
        '  }\n',
    ),
  ];
}

/// `widget.title` -> `title`, within the `State` class and nowhere else.
List<({int start, int end, String text})> _widgetReferenceEdits(
  ClassDeclaration state,
  List<LiftedField> fields,
) {
  final byName = {for (final f in fields) f.name: f};
  final visitor = _WidgetAccesses(byName.keys.toSet());
  state.accept(visitor);
  return [
    for (final hit in visitor.hits)
      (start: hit.start, end: hit.end, text: byName[hit.name]!.local),
  ];
}

/// Every `widget.<name>` for a lifted name.
///
/// Both spellings the analyzer produces for it: `PrefixedIdentifier` for a bare
/// `widget.title`, and `PropertyAccess` for the parenthesised or cascaded forms.
class _WidgetAccesses extends RecursiveAstVisitor<void> {
  _WidgetAccesses(this.names);
  final Set<String> names;
  final hits = <({int start, int end, String name})>[];

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (node.prefix.name == 'widget' && names.contains(node.identifier.name)) {
      hits.add((start: node.offset, end: node.end, name: node.identifier.name));
      return;
    }
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    final target = node.target;
    if (target is SimpleIdentifier &&
        target.name == 'widget' &&
        names.contains(node.propertyName.name)) {
      hits.add((start: node.offset, end: node.end, name: node.propertyName.name));
      return;
    }
    super.visitPropertyAccess(node);
  }
}

/// The edits that leave `GeneratedWidget` constructible with no argument at all.
///
/// State mode only, and the last step of the lift: the `State` now declares every lifted
/// field and seeds it in `initState`, and `build` reads those rather than `widget.x`, so the
/// fields on the widget are dead weight and the constructor that required them is the only
/// thing standing between a mined role and `GeneratedWidget()`. Both come out, and so does
/// the `GeneratedWidget.fixture` that existed to work around them.
///
/// That matters because the mount site is fixed and unnamed. `lib/main.dart` and
/// `scripts/reset_lib.sh` both write `body: GeneratedWidget()`, nothing in the repository
/// calls `.fixture()`, and a role whose commit declared `required this.title` therefore did
/// not compile when it was staged.
///
/// Returns NULL rather than a partial rewrite when a field the lift did not take would be
/// left uninitialised -- an untyped `final`, which [_constructorFields] skips because
/// inferring a type here would be a guess, or a field whose binding name the file already
/// declares. Dropping the constructor there would produce a
/// file that does not compile, and `spm analyze` skips a file with errors, so the role would
/// lose the feature vector this whole pass exists to give it. The caller falls back to the
/// fixture constructor for that file, which is the pre-2026-09-09 shape.
///
/// `const` only when nothing is left on the widget to initialise. A surviving field with its
/// own initialiser is not necessarily a constant one, and a `late` field never is.
List<({int start, int end, String text})>? _argumentFreeWidgetEdits(
  String text,
  ClassDeclaration widget,
  List<LiftedField> fields,
) {
  final lifted = {for (final f in fields) f.name};
  final leaving = <FieldDeclaration>[];
  final staying = <FieldDeclaration>[];
  for (final member in classMembers(widget)) {
    if (member is! FieldDeclaration || member.isStatic) continue;
    // All or nothing per declaration: `_constructorFields` skips on the declaration's type,
    // and `final Color bgColor, textColor;` is one type shared by both variables.
    final all =
        member.fields.variables.every((v) => lifted.contains(v.name.lexeme));
    (all ? leaving : staying).add(member);
  }
  if (leaving.isEmpty) return null;

  final unset = staying.any((f) =>
      !f.fields.isLate && f.fields.variables.any((v) => v.initializer == null));
  if (unset) return null;

  final edits = <({int start, int end, String text})>[];
  for (final member in leaving) {
    edits.add(_deleteLines(text, member));
  }

  final source = '${staying.isEmpty ? 'const ' : ''}$_kWidgetClass({super.key});';
  ConstructorDeclaration? unnamed;
  for (final member in classMembers(widget)) {
    if (member is! ConstructorDeclaration) continue;
    if (member.name == null) {
      unnamed = member;
    } else if (member.name!.lexeme == 'fixture') {
      // A re-run over an already-lifted tree, or a transplant `spm isolate` gave one to.
      edits.add(_deleteLines(text, member));
    }
  }
  edits.add(unnamed != null
      ? (start: unnamed.offset, end: unnamed.end, text: source)
      : (
          start: classBodyOpen(widget),
          end: classBodyOpen(widget),
          text: '\n  $source\n'
        ));
  return edits;
}

/// The span of the whole lines [node] sits on, plus the blank ones that follow it.
///
/// A member deleted by its own offsets leaves an indented empty line behind, and the blank
/// line that separated it from the next member becomes a second one. Taking both keeps the
/// widget class looking like something a person would have written, which matters because
/// these files are read and diffed by hand.
({int start, int end, String text}) _deleteLines(String text, AstNode node) {
  var start = node.offset;
  while (start > 0 && text[start - 1] != '\n') {
    final ch = text[start - 1];
    if (ch != ' ' && ch != '\t') break;
    start--;
  }
  var end = node.end;
  while (end < text.length) {
    final line = text.indexOf('\n', end);
    if (line < 0) break;
    if (text.substring(end, line).trim().isNotEmpty) break;
    end = line + 1;
  }
  return (start: start, end: end, text: '');
}

/// `GeneratedWidget.fixture({super.key}) : title = fixtureTitle;`
///
/// Constructor mode's way of mounting the role, and state mode's fallback for the file
/// [_argumentFreeWidgetEdits] refuses. Replaces the extractor's version, whose initialisers
/// were invented, and supplies one where the extractor emitted none. The widget's fields stay
/// `final` and stay initialised -- what they are initialised FROM is now the same declared
/// binding the `State` reads, so the two paths cannot disagree.
({int start, int end, String text}) _fixtureConstructorEdit(
  ClassDeclaration widget,
  List<LiftedField> fields,
) {
  final initialisers = [
    for (final f in fields) '${f.name} = ${f.binding}',
  ].join(', ');
  final source = '\n  $_kWidgetClass.fixture({super.key}) : $initialisers;\n';

  for (final member in classMembers(widget)) {
    if (member is ConstructorDeclaration && member.name?.lexeme == 'fixture') {
      return (start: member.offset, end: member.end, text: source.trim());
    }
  }
  final at = classBodyOpen(widget);
  return (start: at, end: at, text: source);
}

/// The `late` fixture declarations themselves.
///
/// They carry no initialiser, so `fixture.dart`'s `_isSeed` classifies them exactly as it
/// classifies the seeds `spm isolate` leaves behind, they hoist into the group's shared
/// `dependencies.dart` as `// TODO: value`, and `scripts/fixture_gate.py` refuses the group
/// until every one is filled. Nothing here invents a value.
///
/// Written under the fixture banner when the file has one, so that `standInStart` keeps
/// counting them as scaffolding: the screening rules and the near-duplicate hash both stop at
/// the earliest banner, and a binding declaration read as evidence about the scope would be a
/// rule firing on the extractor's own output.
({int start, int end, String text}) _bindingsEdit(
  String text,
  List<LiftedField> fields,
) {
  final declarations = [
    for (final f in fields) 'late ${f.type} ${f.binding};',
  ].join('\n\n');

  const banner = '// Fixture block';
  final at = text.length;
  if (text.contains('\n$banner') || text.startsWith(banner)) {
    return (start: at, end: at, text: '\n$declarations\n');
  }
  return (
    start: at,
    end: at,
    text:
        '\n$banner. Constructor fields lifted out of the transplanted widget, so\n'
        '// that one fixture serves every role in the group and no value is invented\n'
        '// inside a measured file. See lib/src/widget_fields.dart.\n'
        '$declarations\n',
  );
}
