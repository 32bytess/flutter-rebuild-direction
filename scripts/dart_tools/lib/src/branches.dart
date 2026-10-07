/// Conditionals, and how much each arm renders.
///
/// WHY THIS EXISTS.
///
/// `scripts/maximal_branch.py` gives a branch-selecting fixture binding the value that
/// selects the arm rendering MORE non-const widgets. Until this library it computed that
/// with a regex over raw source and a hand-rolled brace matcher -- the same construction
/// `screen_samples` retired on 2026-08-20, and it had the failure modes this package's
/// entry point already documents. Four of them were measured on the real corpus:
///
///   * `(?<![\w.])([A-Z]\w*)\s*\(` counts any capitalised call. On one transplant it put
///     `TextStyle`, `AppInfo`, `Color`, `EdgeInsets`, `BoxDecoration`, `BorderRadius` and
///     `InputDecoration` into a "widget" count -- 13 of 28 matches were not widgets.
///   * A flat source count cannot see that one `Card(...)` inside an `itemBuilder` is one
///     source widget and N runtime widgets, so the arm that renders more can score lower.
///   * `\bif\s*\(` finds only `IfStatement`. Ternaries and collection `if` elements -- both
///     ordinary Flutter, and both present in the deciding groups -- were invisible.
///   * `const` was detected by a six-character lookback, so `const   Foo(` read as non-const.
///
/// WHAT IS REPORTED, AND WHAT IS NOT DECIDED HERE.
///
/// This library reports counts. It does not choose a literal and does not know what a
/// fixture binding is: the decision rule, the binding vocabulary and the `undecidable`
/// policy stay in `scripts/maximal_branch.py`, the same split `rules.dart` describes for
/// screening. What crosses the boundary is per-arm evidence.
///
/// `unknown` is a first-class outcome. A user-defined type cannot be classified without
/// resolving the transplant, and a mined transplant does not resolve. So a name in neither
/// generated set is counted as `unknown` and reported; it is never assumed to be a widget.
library;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'widgets.g.dart';

/// Named constructors that build children lazily, per element, on demand.
const _kLazyConstructors = <String>{'builder', 'separated', 'custom'};

/// Named arguments that mark a per-element builder, whatever the constructor is called.
const _kLazyArguments = <String>{
  'itemBuilder',
  'separatorBuilder',
  'itemCount',
  'childrenDelegate',
  'findChildIndexCallback',
};

/// Delegates that construct children lazily when handed to a sliver.
const _kLazyDelegates = <String>{
  'SliverChildBuilderDelegate',
  'SliverChildListDelegate',
};

/// What one arm of a conditional instantiates.
class ArmCounts {
  /// Non-const instantiations of a known Flutter `Widget` subtype.
  int widgets = 0;

  /// Non-const instantiations of a known Flutter class that is NOT a widget --
  /// `TextStyle`, `EdgeInsets`. The feature schema counts these as `valueObjectAllocCount`,
  /// a different quantity, so they are reported apart rather than summed in.
  int valueObjects = 0;

  /// Capitalised instantiations in neither generated set: user types, and `dart:` classes
  /// outside the scanned Flutter libraries. Reported, never counted as widgets.
  int unknown = 0;

  /// Const widget instantiations. Excluded from `widgets` because a const subtree is
  /// canonicalised and skipped by reconciliation, so it carries no per-rebuild cost --
  /// which is also why `treeNonConstWidgetCount` excludes them.
  int constWidgets = 0;

  /// Whether this arm builds children lazily. An arm that does renders a viewport window
  /// sized by the device, not a number this pass can compute, so a caller comparing two
  /// arms cannot rank them on `widgets` alone.
  bool hasLazyBuilder = false;

  Map<String, Object> toJson() => {
        'widgets': widgets,
        'valueObjects': valueObjects,
        'unknown': unknown,
        'constWidgets': constWidgets,
        'hasLazyBuilder': hasLazyBuilder,
      };
}

/// One conditional and both its arms.
class BranchRecord {
  BranchRecord(this.kind, this.condition, this.conditionNames, this.offset, this.thenArm,
      this.elseArm);

  /// `if`, `ternary` or `ifElement` -- the last two were invisible to the regex this
  /// library replaces, so the caller is told which kind it is looking at.
  final String kind;

  /// The condition exactly as written, from `toSource()` rather than a regex slice.
  final String condition;

  /// Every simple identifier the condition names. The caller asks "does this conditional
  /// depend on field X" and a substring test over `condition` would answer yes for
  /// `showAllAppsToggle` when asked about `showAllApps`.
  final List<String> conditionNames;

  final int offset;
  final ArmCounts thenArm;
  final ArmCounts elseArm;

  Map<String, Object> toJson() => {
        'kind': kind,
        'condition': condition,
        'conditionNames': conditionNames,
        'offset': offset,
        'then': thenArm.toJson(),
        'else': elseArm.toJson(),
      };
}

/// Counts one arm. Runs over that arm's subtree only, so a nested conditional's arms are
/// included in the enclosing arm's totals -- which is correct, the enclosing arm does
/// render them -- while still being reported separately as their own record.
class _ArmCounter extends RecursiveAstVisitor<void> {
  final counts = ArmCounts();

  /// Lexical const nesting. `const Foo(Bar())` makes `Bar()` const too, and parse-only
  /// there is no other way to know it.
  var _constDepth = 0;

  void _record(String? name, {required bool isConst}) {
    if (name == null || name.isEmpty) return;
    final first = name[0];
    if (first.toUpperCase() != first) return; // not a type reference
    if (kWidgetNames.contains(name)) {
      if (isConst || _constDepth > 0) {
        counts.constWidgets++;
      } else {
        counts.widgets++;
      }
      return;
    }
    if (kNonWidgetNames.contains(name)) {
      if (!isConst && _constDepth == 0) counts.valueObjects++;
      return;
    }
    if (!isConst && _constDepth == 0) counts.unknown++;
  }

  void _noteLazy(String? typeName, String? constructorName) {
    if (constructorName != null && _kLazyConstructors.contains(constructorName)) {
      counts.hasLazyBuilder = true;
    }
    if (typeName != null && _kLazyDelegates.contains(typeName)) {
      counts.hasLazyBuilder = true;
    }
  }

  void _noteLazyArguments(ArgumentList arguments) {
    for (final argument in arguments.arguments) {
      // `NamedArgument.name` is a Token in analyzer 14; the older `NamedExpression`
      // carried a Label. Nothing here depends on which, beyond reading the lexeme.
      if (argument is NamedArgument && _kLazyArguments.contains(argument.name.lexeme)) {
        counts.hasLazyBuilder = true;
      }
    }
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name.lexeme;
    final constructorName = node.constructorName.name?.name;
    _record(typeName, isConst: node.isConst);
    _noteLazy(typeName, constructorName);
    _noteLazyArguments(node.argumentList);
    if (node.isConst) {
      _constDepth++;
      super.visitInstanceCreationExpression(node);
      _constDepth--;
    } else {
      super.visitInstanceCreationExpression(node);
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Unresolved, a bare `Container(...)` parses as a method invocation rather than an
    // instance creation -- the same reason `facts.dart` watches this node type. A named
    // constructor `ListView.builder(...)` arrives here too, with `ListView` as the target.
    final target = node.target;
    if (target == null) {
      _record(node.methodName.name, isConst: false);
      // `SliverChildBuilderDelegate(...)` arrives with no target, so the delegate check
      // has to run on the method name here as well as on a constructor target below.
      _noteLazy(node.methodName.name, null);
      _noteLazyArguments(node.argumentList);
    } else if (target is SimpleIdentifier) {
      _record(target.name, isConst: false);
      _noteLazy(target.name, node.methodName.name);
      _noteLazyArguments(node.argumentList);
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitListLiteral(ListLiteral node) {
    if (node.isConst) {
      _constDepth++;
      super.visitListLiteral(node);
      _constDepth--;
    } else {
      super.visitListLiteral(node);
    }
  }

  @override
  void visitSetOrMapLiteral(SetOrMapLiteral node) {
    if (node.isConst) {
      _constDepth++;
      super.visitSetOrMapLiteral(node);
      _constDepth--;
    } else {
      super.visitSetOrMapLiteral(node);
    }
  }
}

class _NameCollector extends RecursiveAstVisitor<void> {
  final names = <String>{};

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    names.add(node.name);
    super.visitSimpleIdentifier(node);
  }
}

List<String> _names(AstNode node) {
  final collector = _NameCollector();
  node.accept(collector);
  return collector.names.toList()..sort();
}

ArmCounts _count(AstNode? node) {
  final counter = _ArmCounter();
  node?.accept(counter);
  return counter.counts;
}

/// Every conditional in the unit, in source order, plus the plain identifier assignments
/// that tell a caller which field a fixture binding was mounted into.
class BranchCollector extends RecursiveAstVisitor<void> {
  final branches = <BranchRecord>[];

  /// `{'target': 'showAllApps', 'value': 'fixtureShowAllApps'}` for every `a = b;` and
  /// `T a = b;` where both sides are bare identifiers. `maximal_branch` used to recover
  /// these with `(\w+)\s*=\s*name\s*;` over raw source, which matches inside comments
  /// and string literals like every other scan this library replaces.
  final assignments = <Map<String, String>>[];

  void _note(String target, Expression? value) {
    if (value is SimpleIdentifier) {
      assignments.add({'target': target, 'value': value.name});
    }
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    final left = node.leftHandSide;
    if (left is SimpleIdentifier) _note(left.name, node.rightHandSide);
    super.visitAssignmentExpression(node);
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    _note(node.name.lexeme, node.initializer);
    super.visitVariableDeclaration(node);
  }

  @override
  void visitIfStatement(IfStatement node) {
    branches.add(BranchRecord(
      'if',
      node.expression.toSource(),
      _names(node.expression),
      node.offset,
      _count(node.thenStatement),
      _count(node.elseStatement),
    ));
    super.visitIfStatement(node);
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    branches.add(BranchRecord(
      'ternary',
      node.condition.toSource(),
      _names(node.condition),
      node.offset,
      _count(node.thenExpression),
      _count(node.elseExpression),
    ));
    super.visitConditionalExpression(node);
  }

  @override
  void visitIfElement(IfElement node) {
    // `if (x) Foo() else Bar()` inside a `children: [...]`. Ordinary Flutter, and the
    // shape a scanner looking for `if\s*\(` in statement position never sees.
    branches.add(BranchRecord(
      'ifElement',
      node.expression.toSource(),
      _names(node.expression),
      node.offset,
      _count(node.thenElement),
      _count(node.elseElement),
    ));
    super.visitIfElement(node);
  }
}

/// The branch rows for one parsed unit.
Map<String, Object> collectBranches(CompilationUnit unit) {
  final collector = BranchCollector();
  unit.accept(collector);
  return {
    'branches': [for (final branch in collector.branches) branch.toJson()],
    'assignments': collector.assignments,
  };
}
