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
// long as it is untouched. The first HAND edit makes it yours: the screen records its hash,
// sees the difference, and never overwrites it again.
// ignore_for_file: unused_import, unused_element, unused_field
part of generated_widget;


// LIFTED BINDINGS -- the scope's initial state, which `spm isolate` 0.7.0 moves out
// of the application and into a fixture block of its own. Most of these carry the
// value that was really there, relocated rather than invented, and are reproduced
// here verbatim: do not "tidy" one, it is a measurement input.
//
// The ones marked TODO are the exception. Where the binding came from the
// application and no value existed to move, the block gets an empty collection or a
// null, and how many elements you put in one IS tree size -- the dependent variable.
// That is a decision, and it is why they are hoisted: filled in once here, the whole
// group mounts from identical values, so a measured difference is attributable to
// the edit rather than to the scaffolding.

List<BlogWithSize> fixtureBlogs = List<BlogWithSize>.generate(3, (_) => BlogWithSize());

TextEditingController fixtureTextEditingController = TextEditingController();

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class BlogWithSize {
  const BlogWithSize({
    dynamic title,
    dynamic description,
    dynamic bgColor,
    dynamic width,
    dynamic height,
  });
  dynamic get title => 'Design Systems';
  dynamic get description => 'A practical guide to building consistent UI';
  dynamic get bgColor => const Color(0xFF474A57);
  dynamic get width => 150.0;
  dynamic get height => 140.0;
}

class StaggeredGridView extends StatelessWidget {
  final dynamic children;
  StaggeredGridView({
    super.key,
    dynamic scrollDirection,
    dynamic reverse,
    dynamic controller,
    dynamic primary,
    dynamic physics,
    dynamic shrinkWrap,
    dynamic padding,
    dynamic gridDelegate,
    dynamic addAutomaticKeepAlives,
    dynamic addRepaintBoundaries,
    this.children,
    dynamic restorationId,
  });
  StaggeredGridView.builder({
    super.key,
    dynamic scrollDirection,
    dynamic reverse,
    dynamic controller,
    dynamic primary,
    dynamic physics,
    dynamic shrinkWrap,
    dynamic padding,
    dynamic gridDelegate,
    dynamic itemBuilder,
    dynamic itemCount,
    dynamic addAutomaticKeepAlives,
    dynamic addRepaintBoundaries,
    dynamic restorationId,
  }) : children = null;
  const StaggeredGridView.custom({
    super.key,
    dynamic scrollDirection,
    dynamic reverse,
    dynamic controller,
    dynamic primary,
    dynamic physics,
    dynamic shrinkWrap,
    dynamic padding,
    dynamic restorationId,
    dynamic gridDelegate,
    dynamic childrenDelegate,
    dynamic addAutomaticKeepAlives,
  }) : children = null;
  StaggeredGridView.count({
    super.key,
    dynamic scrollDirection,
    dynamic reverse,
    dynamic controller,
    dynamic primary,
    dynamic physics,
    dynamic shrinkWrap,
    dynamic padding,
    dynamic crossAxisCount,
    dynamic mainAxisSpacing,
    dynamic crossAxisSpacing,
    dynamic addAutomaticKeepAlives,
    dynamic addRepaintBoundaries,
    this.children,
    dynamic staggeredTiles,
    dynamic restorationId,
  });
  StaggeredGridView.countBuilder({
    super.key,
    dynamic scrollDirection,
    dynamic reverse,
    dynamic controller,
    dynamic primary,
    dynamic physics,
    dynamic shrinkWrap,
    dynamic padding,
    dynamic crossAxisCount,
    dynamic itemBuilder,
    dynamic staggeredTileBuilder,
    dynamic itemCount,
    dynamic mainAxisSpacing,
    dynamic crossAxisSpacing,
    dynamic addAutomaticKeepAlives,
    dynamic addRepaintBoundaries,
    dynamic restorationId,
  }) : children = null;
  StaggeredGridView.extent({
    super.key,
    dynamic scrollDirection,
    dynamic reverse,
    dynamic controller,
    dynamic primary,
    dynamic physics,
    dynamic shrinkWrap,
    dynamic padding,
    dynamic maxCrossAxisExtent,
    dynamic mainAxisSpacing,
    dynamic crossAxisSpacing,
    dynamic addAutomaticKeepAlives,
    dynamic addRepaintBoundaries,
    this.children,
    dynamic staggeredTiles,
    dynamic restorationId,
  });
  StaggeredGridView.extentBuilder({
    super.key,
    dynamic scrollDirection,
    dynamic reverse,
    dynamic controller,
    dynamic primary,
    dynamic physics,
    dynamic shrinkWrap,
    dynamic padding,
    dynamic maxCrossAxisExtent,
    dynamic itemBuilder,
    dynamic staggeredTileBuilder,
    dynamic itemCount,
    dynamic mainAxisSpacing,
    dynamic crossAxisSpacing,
    dynamic addAutomaticKeepAlives,
    dynamic addRepaintBoundaries,
    dynamic restorationId,
  }) : children = null;
  @override
  Widget build(BuildContext context) => Stack(
    children: children is List<Widget>
        ? children as List<Widget>
        : const <Widget>[],
  );
  dynamic get gridDelegate => const _Stub();
  dynamic get childrenDelegate => const _Stub();
  dynamic get addAutomaticKeepAlives => false;
  Widget buildChildLayout(dynamic context) => const SizedBox.shrink();
}

class StaggeredTile {
  const StaggeredTile.count(
    dynamic crossAxisCellCount,
    dynamic mainAxisCellCount,
  );
  const StaggeredTile.extent(
    dynamic crossAxisCellCount,
    dynamic mainAxisExtent,
  );
  const StaggeredTile.fit(dynamic crossAxisCellCount);
  dynamic get crossAxisCellCount => 0;
  dynamic get mainAxisCellCount => null;
  dynamic get mainAxisExtent => null;
  dynamic get fitContent => false;
}

class SvgPicture extends StatelessWidget {
  const SvgPicture(
    dynamic bytesLoader, {
    super.key,
    dynamic width,
    dynamic height,
    dynamic fit,
    dynamic alignment,
    dynamic matchTextDirection,
    dynamic allowDrawingOutsideViewBox,
    dynamic placeholderBuilder,
    dynamic colorFilter,
    dynamic semanticsLabel,
    dynamic excludeFromSemantics,
    dynamic clipBehavior,
    dynamic theme,
    dynamic cacheColorFilter,
  });
  SvgPicture.asset(
    dynamic assetName, {
    super.key,
    dynamic matchTextDirection,
    dynamic bundle,
    dynamic package,
    dynamic width,
    dynamic height,
    dynamic fit,
    dynamic alignment,
    dynamic allowDrawingOutsideViewBox,
    dynamic placeholderBuilder,
    dynamic semanticsLabel,
    dynamic excludeFromSemantics,
    dynamic clipBehavior,
    dynamic theme,
    dynamic colorFilter,
    dynamic color,
    dynamic colorBlendMode,
    dynamic cacheColorFilter,
  });
  SvgPicture.network(
    dynamic url, {
    super.key,
    dynamic headers,
    dynamic width,
    dynamic height,
    dynamic fit,
    dynamic alignment,
    dynamic matchTextDirection,
    dynamic allowDrawingOutsideViewBox,
    dynamic placeholderBuilder,
    dynamic colorFilter,
    dynamic color,
    dynamic colorBlendMode,
    dynamic semanticsLabel,
    dynamic excludeFromSemantics,
    dynamic clipBehavior,
    dynamic cacheColorFilter,
    dynamic theme,
    dynamic httpClient,
  });
  SvgPicture.file(
    dynamic file, {
    super.key,
    dynamic width,
    dynamic height,
    dynamic fit,
    dynamic alignment,
    dynamic matchTextDirection,
    dynamic allowDrawingOutsideViewBox,
    dynamic placeholderBuilder,
    dynamic colorFilter,
    dynamic color,
    dynamic colorBlendMode,
    dynamic semanticsLabel,
    dynamic excludeFromSemantics,
    dynamic clipBehavior,
    dynamic theme,
    dynamic cacheColorFilter,
  });
  SvgPicture.memory(
    dynamic bytes, {
    super.key,
    dynamic width,
    dynamic height,
    dynamic fit,
    dynamic alignment,
    dynamic matchTextDirection,
    dynamic allowDrawingOutsideViewBox,
    dynamic placeholderBuilder,
    dynamic colorFilter,
    dynamic color,
    dynamic colorBlendMode,
    dynamic semanticsLabel,
    dynamic excludeFromSemantics,
    dynamic clipBehavior,
    dynamic theme,
    dynamic cacheColorFilter,
  });
  SvgPicture.string(
    dynamic string, {
    super.key,
    dynamic width,
    dynamic height,
    dynamic fit,
    dynamic alignment,
    dynamic matchTextDirection,
    dynamic allowDrawingOutsideViewBox,
    dynamic placeholderBuilder,
    dynamic colorFilter,
    dynamic color,
    dynamic colorBlendMode,
    dynamic semanticsLabel,
    dynamic excludeFromSemantics,
    dynamic clipBehavior,
    dynamic theme,
    dynamic cacheColorFilter,
  });
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
  static dynamic get defaultPlaceholderBuilder => const _Stub();
  static set defaultPlaceholderBuilder(dynamic _) {}
  static dynamic get svgByteDecoder => const _Stub();
  static dynamic get svgStringDecoder => const _Stub();
  static dynamic get svgByteDecoderOutsideViewBox => const _Stub();
  static dynamic get svgStringDecoderOutsideViewBox => const _Stub();
  dynamic get width => null;
  dynamic get height => null;
  dynamic get fit => const _Stub();
  dynamic get alignment => const _Stub();
  dynamic get pictureProvider => const _Stub();
  dynamic get placeholderBuilder => null;
  dynamic get matchTextDirection => false;
  dynamic get allowDrawingOutsideViewBox => false;
  dynamic get semanticsLabel => null;
  dynamic get excludeFromSemantics => false;
  dynamic get clipBehavior => const _Stub();
  dynamic get colorFilter => null;
  dynamic get cacheColorFilter => false;
  dynamic get bytesLoader => const _Stub();
}

const dynamic black = Color(0xFF000000);

const dynamic trout = Color(0xFF474A57);

const dynamic white = Color(0xFFFFFFFF);

const dynamic wood_smoke = Color(0xFF18191F);

class _Stub {
  const _Stub();

  int get length => 0;
  bool get isEmpty => true;
  bool get isNotEmpty => false;
  Iterator<dynamic> get iterator => const Iterable<dynamic>.empty().iterator;

  dynamic operator [](Object? key) => const _Stub();
  dynamic operator +(Object? other) => const _Stub();
  bool operator <(Object? other) => false;
  bool operator >(Object? other) => false;
  bool operator <=(Object? other) => false;
  bool operator >=(Object? other) => false;

  @override
  bool operator ==(Object other) => other is _Stub;

  @override
  int get hashCode => 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => const _Stub();

  @override
  String toString() => '';
}

class StaggeredGrid extends StatelessWidget {
  final dynamic children;
  StaggeredGrid.custom({
    super.key,
    dynamic delegate,
    dynamic mainAxisSpacing,
    dynamic crossAxisSpacing,
    dynamic axisDirection,
    this.children,
  });
  StaggeredGrid.count({
    super.key,
    dynamic crossAxisCount,
    dynamic mainAxisSpacing,
    dynamic crossAxisSpacing,
    dynamic axisDirection,
    this.children,
  });
  StaggeredGrid.extent({
    super.key,
    dynamic maxCrossAxisExtent,
    dynamic mainAxisSpacing,
    dynamic crossAxisSpacing,
    dynamic axisDirection,
    this.children,
  });
  @override
  Widget build(BuildContext context) => Stack(
    children: children is List<Widget>
        ? children as List<Widget>
        : const <Widget>[],
  );
  dynamic get delegate => const _Stub();
  dynamic get mainAxisSpacing => 0.0;
  dynamic get crossAxisSpacing => 0.0;
  dynamic get axisDirection => null;
  dynamic createRenderObject(dynamic context) => const _Stub();
  void updateRenderObject(dynamic context, dynamic renderObject) {}
}

class StaggeredGridTile extends StatelessWidget {
  final dynamic child;
  const StaggeredGridTile._({
    super.key,
    dynamic crossAxisCellCount,
    dynamic mainAxisCellCount,
    dynamic mainAxisExtent,
    this.child,
  });
  const StaggeredGridTile.count({
    super.key,
    dynamic crossAxisCellCount,
    dynamic mainAxisCellCount,
    this.child,
  });
  const StaggeredGridTile.extent({
    super.key,
    dynamic crossAxisCellCount,
    dynamic mainAxisExtent,
    this.child,
  });
  const StaggeredGridTile.fit({
    super.key,
    dynamic crossAxisCellCount,
    this.child,
  });
  @override
  Widget build(BuildContext context) =>
      child is Widget ? child as Widget : const SizedBox.shrink();
  dynamic get crossAxisCellCount => 0;
  dynamic get mainAxisCellCount => null;
  dynamic get mainAxisExtent => null;
  dynamic get debugTypicalAncestorWidgetClass => const _Stub();
  void applyParentData(dynamic renderObject) {}
}
