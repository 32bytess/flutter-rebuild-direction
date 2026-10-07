/// Splitting a mined transplant into the code that was measured and the fixture that has
/// to be written by hand before it can run.
///
/// WHY.
///
/// `spm isolate` leaves four things in every `rev_*.dart` that a device run needs to have
/// settled before it can mount:
///
///   * LIFTED BINDINGS -- 0.7.0's fixture block, everything after the first banner and
///     before the next. 0.7.0 drops `initState`/`didChangeDependencies` and relocates what
///     they seeded here, so this block is the whole of a scope's initial state at the top
///     level of the file. Most entries carry the value that was really there, moved rather
///     than invented; where the binding came from the application and no value existed to
///     move, it holds an empty collection or a `null`, and how many elements go in one is
///     tree size.
///   * SEEDS -- top-level `late` declarations with no initialiser, which the generated
///     `initState` assigns the scope's fields from. What is left of the pre-0.7.0 shape:
///     0.7.0 keeps it only where no value of the binding's type could be built, and reports
///     the name in `unseededBindings`.
///   * DECLARATION-ONLY STAND-INS -- everything after the second banner. Bodies throw.
///   * UNRESOLVED-REFERENCE STAND-INS -- everything after the third banner, all `dynamic`.
///     Top-level constants in either stand-in block are initialised to `null`, which is a
///     value the run needs just as much as a seed is.
///
/// Arm 1 solved this with one hand-written `dependencies.dart` per group, shared by
/// `base.dart` and all 8 mutations. This pass produces the same shape mechanically: it
/// moves all three into a separate file so one edit serves every role in the group, and it
/// never invents a value -- a generated value that changes tree size manufactures the
/// effect the study measures.
///
/// WHY A `part`, NOT AN IMPORT.
///
/// Arm 1's fixture could be a library of its own because a human wrote it and naturally
/// named everything publicly. A mined one cannot. 0.7.0's lifted bindings are public
/// (`fixtureListMessage`) and would survive the move, but nothing else here would: the
/// stand-ins refer to private classes that stay behind in the transplant, and a private name
/// moved into another library stops being visible. A `part` shares the library's privacy, so
/// every identifier stays byte-identical to what was mined and nothing is renamed to make it
/// reachable. The lifted bindings then come along for free rather than needing an
/// arrangement of their own -- which matters, because splitting them off into an imported
/// library would put a scope's initial state in a different file from the stand-ins that
/// same state is typed against.
///
/// The library-name form (`part of generated_widget;`) rather than the URI form is what
/// lets ONE fixture serve every role: the URI form would have to name `rev_007_ab12cd34.dart`
/// and would therefore be per-role, which is the whole thing this pass exists to avoid.
/// The staged file is always `lib/generated_widget.dart` (`device_runner/runner.py`), so
/// the library name is the one part of the layout that does not move.
///
/// ORDER. Normalisation runs FIRST and the hoist is computed against its output, so the
/// offsets this file works with are the offsets of the text that will actually be written.
/// Doing it the other way round would leave every hoist span stale by however much
/// `normalise` had shortened the file above it.
library;

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'facts.dart';
import 'normalise.dart';
import 'widget_fields.dart';

/// Banner prefixes `spm isolate` writes above each generated block. Matched at line start
/// only, and used solely to find the boundary: what MOVES is always whole declarations
/// taken from the AST, never a text span.
///
/// The fixture block is 0.7.0's and comes FIRST in every file that has one -- 850 of the
/// 850 mined files carrying both. It is scaffolding exactly as the two stand-in blocks are,
/// so `standInStart` takes the earliest of the three rather than the earliest of the two.
const kFixtureBanner = '// Fixture block';
const kDeclarationBanner = '// Declaration-only stand-ins';
const kUnresolvedBanner = '// Stand-ins for references';

/// The library every role is staged as, and the file the fixture is written to.
const kLibraryName = 'generated_widget';
const kFixtureFile = 'dependencies.dart';

/// One declaration on its way out of the transplant.
class Hoisted {
  final String name;

  /// `seed`, `declaration` or `unresolved` -- which section of the fixture it belongs to.
  final String section;

  /// Verbatim source, exactly as it will be written to the fixture. Byte-identical so
  /// `extends` and `implements` clauses survive: `spm analyze` decides widget versus value
  /// object by walking the supertype chain, and a stand-in that quietly stops extending its
  /// widget base moves allocations into `valueObjectAllocCount`.
  final String text;

  /// True when the declaration carries no usable value: a `late` seed with no initialiser,
  /// or a top-level constant standing in at `null`. These are what a human fills in.
  final bool needsValue;

  /// For a class, mixin or extension: everything before the body's `{`, trimmed. Null for
  /// anything else.
  ///
  /// A stand-in is RECONSTRUCTED from the call sites the role happens to reach, so two roles
  /// legitimately produce different member lists for the same type -- one revision touches
  /// `AsyncValue.requireValue` and its sibling does not. Splitting the declaration lets the
  /// caller union the members instead of calling that a contradiction, which it is not. A
  /// header that differs IS one: `AsyncValue<T>` and `AsyncValue<ValueT>` cannot share
  /// members that name the parameter.
  final String? header;

  /// Members keyed by what makes them the same member: a name, a getter/setter role, a
  /// constructor's name. Null when [header] is.
  final List<({String name, String text})>? members;

  /// Which of THIS declaration's names a measured rebuild can reach. See [_Reach].
  ///
  /// A list rather than a flag because [name] joins a multi-name declaration with commas --
  /// `int a, b;` is one record naming two bindings, and one of them can feed a widget while
  /// the other only ever gets assigned at mount.
  final List<String> reaching;

  Hoisted(
    this.name,
    this.section,
    this.text,
    this.needsValue, {
    this.header,
    this.members,
    this.reaching = const [],
  });

  Map<String, Object?> toJson() => {
    'name': name,
    'section': section,
    'text': text,
    'needsValue': needsValue,
    'reaching': reaching,
    if (header != null) 'header': header,
    if (members != null)
      'members': [
        for (final m in members!) {'name': m.name, 'text': m.text},
      ],
  };
}

/// What makes two members the same member. Two roles' reconstructions of one type are
/// merged member by member, so a key that collided would silently drop one of them and a key
/// that split would emit both.
String memberKey(ClassMember member) {
  if (member is MethodDeclaration) {
    final role = member.isGetter ? 'get ' : (member.isSetter ? 'set ' : '');
    return '$role${member.name.lexeme}';
  }
  if (member is ConstructorDeclaration)
    return 'new ${member.name?.lexeme ?? ''}';
  if (member is FieldDeclaration) {
    return 'field ${member.fields.variables.map((v) => v.name.lexeme).join(',')}';
  }
  // Anything else -- an unnamed member shape this does not model -- keys on its own source,
  // so it can only ever merge with an identical one.
  return member.toSource();
}

/// The header and members of a class-like declaration, or null if it is not one.
///
/// Enums are deliberately excluded: their constants are part of the type's identity, and
/// unioning two different constant lists would invent an enum neither role declared.
///
/// Analyzer 14 moved the members behind a `ClassBody`; analyzer 13 has `members` and
/// `leftBracket` on the declaration itself. Read dynamically for the same reason
/// [declarationNameToken] does -- a static read does not compile against the other version.
({String header, List<({String name, String text})> members})? classLike(
  CompilationUnitMember member,
  String text,
) {
  if (member is! ClassDeclaration &&
      member is! MixinDeclaration &&
      member is! ExtensionDeclaration) {
    return null;
  }
  final dynamic declaration = member;
  List<ClassMember> members;
  int bodyStart;
  try {
    final dynamic body = declaration.body;
    members = (body.members as Iterable).cast<ClassMember>().toList();
    bodyStart = (body as AstNode).offset;
  } on NoSuchMethodError {
    members = (declaration.members as Iterable).cast<ClassMember>().toList();
    bodyStart = (declaration.leftBracket as Token).offset;
  }
  return (
    header: text.substring(member.offset, bodyStart).trimRight(),
    members: [
      for (final m in members)
        (name: memberKey(m), text: text.substring(m.offset, m.end)),
    ],
  );
}

class FixtureSplit {
  /// The file with normalisation applied and nothing hoisted -- what the export writes when
  /// its group gets no fixture.
  final String plainText;

  /// The file with normalisation applied, the hoisted declarations removed, and the
  /// `library` / `part` directives inserted.
  final String text;

  final Map<String, int> counts;
  final List<String> unknownImports;
  final List<Hoisted> hoisted;

  /// The file's own import directives, verbatim. A fixture is a `part` and so has no
  /// imports of its own: it sees the library's. Two roles in one group can differ in what
  /// they import, and a declaration hoisted out of one has to compile inside the other, so
  /// the caller unions these across the group and injects what is missing.
  final List<String> imports;

  FixtureSplit(
    this.plainText,
    this.text,
    this.counts,
    this.unknownImports,
    this.hoisted,
    this.imports,
  );
}

/// Offsets of every line that starts one of the generated banners, in `text`.
({int fixture, int declaration, int unresolved}) _banners(String text) {
  var fixture = -1;
  var declaration = -1;
  var unresolved = -1;
  var lineStart = 0;
  while (lineStart < text.length) {
    var lineEnd = text.indexOf('\n', lineStart);
    if (lineEnd < 0) lineEnd = text.length;
    if (fixture < 0 && text.startsWith(kFixtureBanner, lineStart)) {
      fixture = lineStart;
    }
    if (declaration < 0 && text.startsWith(kDeclarationBanner, lineStart)) {
      declaration = lineStart;
    }
    if (unresolved < 0 && text.startsWith(kUnresolvedBanner, lineStart)) {
      unresolved = lineStart;
    }
    lineStart = lineEnd + 1;
  }
  return (fixture: fixture, declaration: declaration, unresolved: unresolved);
}

/// Offset where `spm isolate`'s generated blocks begin, or -1 if the file carries none.
/// Everything from here to EOF is scaffolding the extractor wrote, not code the commit
/// contained, so the screening rules must not read it as evidence about the scope, and the
/// near-duplicate hash must not compare it.
///
/// Takes the EARLIEST of the three banners. `spm` emits them fixture, declaration,
/// unresolved, but nothing in the format guarantees that order, and a rule that read half
/// the scaffolding would be worse than one that read none.
///
/// 0.7.0 is why the fixture block is in here. It relocates a scope's whole initial state
/// into that block, and leaving it out cost two things:
///
///   * R2 and R3 read the ACTIVE region, so a `Stream` or a `File` the application used to
///     supply was read as evidence that the scope rebuilds on one. Only those two: R1, R4,
///     R5 and R6 are unit-wide by design and a lifted `AnimationController` still fires R1.
///     No mined verdict actually moved -- a lifted binding mirrors a type the scope already
///     uses -- but nothing prevented one.
///   * The near-duplicate hash ran to EOF, so it compared the VALUES a binding was seeded
///     with alongside the tree they build, and two transplants of one identical widget tree
///     hashed apart because a lifted `int` differed. That one moved a great many verdicts:
///     R7 was firing on 3 groups of 320.
int standInStart(String text) {
  final b = _banners(text);
  var earliest = -1;
  for (final offset in [b.fixture, b.declaration, b.unresolved]) {
    if (offset < 0) continue;
    if (earliest < 0 || offset < earliest) earliest = offset;
  }
  return earliest;
}

/// The token carrying a declaration's own name, across both analyzer versions the package
/// supports.
///
/// Analyzer 14 moved `ClassDeclaration`, `EnumDeclaration` and `ExtensionTypeDeclaration`
/// onto a `ClassNamePart` child and dropped their `name` getter; analyzer 13 has the getter
/// and no such child. `spm` 0.5.1 hit the same wall on `ExtensionTypeDeclaration` and
/// resolved it the same way -- read the child both versions expose, and fall back to the
/// getter for the declarations that never grew one (`MixinDeclaration`, `FunctionDeclaration`,
/// the type aliases). The fallback is a dynamic call on purpose: a static one does not
/// compile against the version that removed the getter.
Token? declarationNameToken(AstNode node) {
  for (final child in node.childEntities) {
    if (child is ClassNamePart) return child.typeName;
  }
  try {
    final dynamic name = (node as dynamic).name;
    if (name is Token) return name;
  } on NoSuchMethodError {
    return null;
  }
  return null;
}

/// Names a top-level declaration introduces.
///
/// An unnamed extension declares nothing callable by name, so it is left where it is -- as
/// is anything else this cannot name, since a fixture entry with no name cannot be unioned
/// against the other roles in the group.
List<String> declaredNames(CompilationUnitMember member) {
  if (member is TopLevelVariableDeclaration) {
    return [for (final v in member.variables.variables) v.name.lexeme];
  }
  final token = declarationNameToken(member);
  return token == null ? const [] : [token.lexeme];
}

/// A `late` top-level declaration with no initialiser: the generated `initState` reads it,
/// and nothing gives it a value.
bool _isSeed(CompilationUnitMember member) =>
    member is TopLevelVariableDeclaration &&
    member.variables.isLate &&
    member.variables.variables.every((v) => v.initializer == null);

/// A top-level constant or final standing in at `null`. Not a seed -- it has an initialiser
/// -- but just as unusable at run time, so it is flagged for the same worklist.
bool _isNullConstant(CompilationUnitMember member) =>
    member is TopLevelVariableDeclaration &&
    member.variables.variables.isNotEmpty &&
    member.variables.variables.every(
      (v) => v.initializer != null && v.initializer is NullLiteral,
    );

/// A binding seeded with an EMPTY collection: `[]`, `{}`, `<Row>[]`, `const []`.
///
/// This is the one thing in the fixture block that has to be told apart from the rest.
/// 0.7.0 RELOCATES a value wherever the scope had one -- "a list seeded with twenty rows
/// still builds twenty" -- and that value is the one that was really there, so it is copied
/// verbatim and nothing may touch it. Where the binding came from the application and no
/// value existed to move, the block gets an empty collection instead, and an empty
/// collection is a decision rather than a default: the number of rows in it IS tree size,
/// which is the dependent variable. So these, and only these, carry `// TODO: value`.
bool _isEmptyCollection(CompilationUnitMember member) =>
    member is TopLevelVariableDeclaration &&
    member.variables.variables.isNotEmpty &&
    member.variables.variables.every((v) {
      final init = v.initializer;
      // `TypedLiteral` is exactly these two, with or without explicit type arguments.
      return switch (init) {
        ListLiteral(:final elements) => elements.isEmpty,
        SetOrMapLiteral(:final elements) => elements.isEmpty,
        _ => false,
      };
    });

FixtureSplit? split(
  String source,
  CompilationUnit unit, {
  bool pruneImports = true,
  bool liftFields = true,
  LiftMode liftMode = LiftMode.constructor,
}) {
  final normalised = normalise(source, unit, pruneImports: pruneImports);
  var text = normalised.text;
  var parsed = parseString(content: text, throwIfDiagnostics: false);
  if (parsed.errors.any((d) => d.severity.name == 'ERROR')) return null;

  // The widget's constructor fields become fixture bindings BEFORE anything is hoisted, so
  // the declarations it adds are hoisted by the same loop, in the same section, as the seeds
  // `spm isolate` left behind -- and so `_Reach` sees the mount assignments it writes. A
  // re-parse rather than an edit to `reparsed`: every offset below is an offset into the
  // text that gets written, and the lift has just moved them.
  final lift = liftFields
      ? liftWidgetFields(text, parsed.unit, mode: liftMode)
      : (text: text, fields: const <LiftedField>[]);
  if (lift.fields.isNotEmpty) {
    text = lift.text;
    parsed = parseString(content: text, throwIfDiagnostics: false);
    if (parsed.errors.any((d) => d.severity.name == 'ERROR')) return null;
  }
  final reparsed = parsed.unit;

  final banners = _banners(text);
  final reach = _Reach(text, reparsed);
  final hoisted = <Hoisted>[];
  final spans = <({int start, int end})>[];

  // Where the fixture block ends: at whichever stand-in banner comes next, or EOF. The
  // block needs its own upper bound rather than a `>` test, because it comes FIRST -- a
  // bare `start > banners.fixture` would swallow both stand-in blocks with it.
  final liftedEnd = [
    banners.declaration,
    banners.unresolved,
    text.length,
  ].where((o) => o >= 0 && o > banners.fixture).reduce((a, b) => a < b ? a : b);

  for (final member in reparsed.declarations) {
    final start = member.offset;
    final String? section;
    if (_isSeed(member)) {
      section = 'seed';
    } else if (banners.unresolved >= 0 && start > banners.unresolved) {
      section = 'unresolved';
    } else if (banners.declaration >= 0 && start > banners.declaration) {
      section = 'declaration';
    } else if (banners.fixture >= 0 &&
        start > banners.fixture &&
        start < liftedEnd) {
      section = 'lifted';
    } else {
      section = null;
    }
    if (section == null) continue;

    final names = declaredNames(member);
    if (names.isEmpty) continue;
    final needsValue = section == 'seed' ||
        _isNullConstant(member) ||
        _isEmptyCollection(member);
    final parts = classLike(member, text);
    hoisted.add(
      Hoisted(
        names.join(','),
        section,
        text.substring(start, member.end),
        needsValue,
        header: parts?.header,
        members: parts?.members,
        reaching: reach.of(names),
      ),
    );
    spans.add((start: start, end: member.end));
  }

  // The banner comments go with the declarations they introduce: leaving them behind would
  // caption an empty space, and leaving the first one behind would make a re-run treat
  // everything below it as hoistable all over again.
  for (final offset in [banners.fixture, banners.declaration, banners.unresolved]) {
    if (offset < 0) continue;
    var end = offset;
    while (end < text.length && text.startsWith('//', end)) {
      final lineEnd = text.indexOf('\n', end);
      if (lineEnd < 0) {
        end = text.length;
        break;
      }
      end = lineEnd + 1;
    }
    spans.add((start: offset, end: end));
  }

  final imports = [
    for (final d in reparsed.directives)
      if (d is ImportDirective) text.substring(d.offset, d.end),
  ];

  if (hoisted.isEmpty) {
    return FixtureSplit(
      text,
      text,
      normalised.counts,
      normalised.unknownImports,
      const [],
      imports,
    );
  }

  spans.sort((a, b) => a.start.compareTo(b.start));
  var residual = text;
  var previousStart = text.length + 1;
  for (final span in spans.reversed) {
    if (span.end > previousStart)
      continue; // overlapping; the outer span already removed it
    residual = residual.replaceRange(span.start, span.end, '');
    previousStart = span.start;
  }

  // `library` before every directive, `part` after the last one -- the order the grammar
  // requires. A transplant with no directives at all gets both above its first declaration.
  final anchor = reparsed.directives.isEmpty
      ? (reparsed.declarations.isEmpty
            ? text.length
            : reparsed.declarations.first.offset)
      : reparsed.directives.first.offset;
  final partAnchor = reparsed.directives.isEmpty
      ? anchor
      : reparsed.directives.last.end;
  // Anchors are offsets into `text`, and every removed span sits below `partAnchor` in the
  // files this runs on -- the banners and the seeds are always at the tail. Assert it
  // rather than assume it: an anchor inside a removed span would splice a directive into
  // the middle of something.
  if (partAnchor > residual.length || anchor > partAnchor) {
    // An anchor inside a span that was removed: there is no place to put the directives
    // that joins the two files, which happens only when the transplant is nothing BUT
    // stand-ins and therefore has no scope to measure. Hand back the unsplit file rather
    // than failing the batch -- the group simply gets no fixture.
    return FixtureSplit(
      text,
      text,
      normalised.counts,
      normalised.unknownImports,
      const [],
      imports,
    );
  }

  residual = residual.replaceRange(
    partAnchor,
    partAnchor,
    "\npart '$kFixtureFile';\n",
  );
  residual = residual.replaceRange(
    anchor,
    anchor,
    'library $kLibraryName;\n\n',
  );
  // Hoisting the tail of a file leaves behind the blank lines that separated what was
  // there. One trailing newline, so a re-export compares equal to itself.
  residual = '${residual.trimRight()}\n';

  return FixtureSplit(
    text,
    residual,
    normalised.counts,
    normalised.unknownImports,
    hoisted,
    imports,
  );
}

/// Which fixture bindings a measured rebuild can actually reach.
///
/// R13 (`scripts/screen_samples.py`) excludes a pair whose endpoints hoist different binding
/// sets, and then has to say which KIND of difference it removed, because the two mean
/// opposite things. A binding `build` reads is part of the edit: the widget it feeds is
/// already in the pair's delta vector, so excluding the pair discards a human edit. A binding
/// `build` never reads is assigned once at mount, outside the `setState` that `buildSpan`
/// times, and cannot reach the dependent variable at all.
///
/// That split was computed downstream by three regexes over the split's text: `build` to END
/// OF FILE as a stand-in for what `build` reaches, `^(\w+) = (\w+);$` to recover the
/// generated assignment, and a word-boundary search for the name.
///
/// THE SLAB IS THE DEFECT, and it is not a small one. `build` to end of file is only a
/// superset of `build`'s reach when the helpers it calls are declared BELOW it. Dart style
/// puts `build` last in a `State` class, after `initState` and after the `_buildXCard()`
/// helpers, so in practice the slab starts too late and misses them. Group `0586` is the
/// shape: `build` calls `_buildTrackingCard()` declared 70 lines above it, and
/// `fixtureTrackingEnabled` feeds a `SwitchListTile(value:)` inside that helper. The regex
/// called it inert; it is part of the tree.
///
/// Measured on the 224 endpoint files R13 runs on: 74 of 535 bindings change classification,
/// 72 of them inert -> reaching. The regex was systematically UNDER-counting the bindings
/// `build` reads, which is the flattering direction for R13 -- it understated how many real
/// contrasts the rule discards. The two that move the other way are correct too: `0879`'s
/// `fixtureOnStartNewChat` is only ever passed to `onPressed:`, an interaction callback whose
/// body never runs inside a measured rebuild.
///
/// Two further reasons, independent of the defect:
///
///   * the walk already exists -- [FactCollector] regions plus `_propagateRegions` are
///     exactly "reachable from `build` through the helpers it calls", and R2/R3 already read
///     them, so the regexes were a second implementation of a solved problem;
///   * the assignment regex is exhaustive only because spm's generator happens to emit
///     `a = b;` on one line, and the fixture-value fill protocol is about to rewrite that
///     generator. Nothing downstream would have caught the silent degradation.
///
/// [Region.rebuild] ALONE is the right question, not `activeNames`. `Region.lifecycle` --
/// `initState`, `didChangeDependencies`, field initialisers -- is precisely the "assigned
/// once at mount" case this split exists to call inert, and the generated assignment is
/// itself a lifecycle reference, so including it would mark every binding as reaching
/// `build`.
///
/// Matching is by NAME, like everything else in this package, which over-links: a local that
/// shadows a fixture binding still counts as a reference to it. Same direction the regex
/// erred in, and the safe one -- it keeps a binding classified as part of the edit, and the
/// consequence of that is a pair reported as a real loss rather than as scaffolding noise.
class _Reach {
  _Reach(String source, CompilationUnit unit) {
    final collector = FactCollector();
    // Before `collectNames`, or every fact lands in `Region.rebuild` and `reaching` comes
    // back true for everything -- vacuous in the same way an empty binding set is.
    collector.indexRegions(unit, source);
    collector.collectNames(unit);
    _rebuild = collector.facts.region(Region.rebuild).names;
    _fieldOf = _mountAssignments(unit, collector);
  }

  late final Set<String> _rebuild;

  /// fixture name -> the field the generated mount code assigns it to.
  late final Map<String, String> _fieldOf;

  /// The subset of [names] a rebuild reaches, directly or through the field it seeds.
  List<String> of(Iterable<String> names) => [
    for (final n in names)
      if (_rebuild.contains(n) || _rebuild.contains(_fieldOf[n] ?? n)) n,
  ];

  /// `field = fixtureName;` in code that runs at mount.
  ///
  /// The binding R13 compares on is the FIXTURE name, and that is not the name `build`
  /// mentions -- `build` reads the field. Region-bounded rather than `initState`-bounded so
  /// that `didChangeDependencies`, or wherever a future generator puts the assignment, is
  /// covered by the same rule that decides what "at mount" means everywhere else.
  static Map<String, String> _mountAssignments(
    CompilationUnit unit,
    FactCollector collector,
  ) {
    final visitor = _MountAssignments(collector);
    unit.accept(visitor);
    return visitor.fieldOf;
  }
}

class _MountAssignments extends RecursiveAstVisitor<void> {
  _MountAssignments(this.collector);
  final FactCollector collector;
  final fieldOf = <String, String>{};

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    final lhs = node.leftHandSide;
    final rhs = node.rightHandSide;
    if (lhs is SimpleIdentifier &&
        rhs is SimpleIdentifier &&
        collector.regionAt(node.offset) == Region.lifecycle) {
      fieldOf[rhs.name] = lhs.name;
    }
    super.visitAssignmentExpression(node);
  }
}
