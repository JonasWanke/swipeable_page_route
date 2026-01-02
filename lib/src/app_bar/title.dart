import 'dart:math' as math;
import 'dart:ui';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'app_bar.dart';
import 'state.dart';

class AnimatedTitle extends MultiChildRenderObjectWidget {
  AnimatedTitle(MorphingState state, {super.key})
    : t = state.t,
      super(children: [_createChild(state.parent), _createChild(state.child)]);

  final double t;

  static Widget _createChild(EndState state) {
    var style = state.titleTextStyle;
    if (style?.color != null) {
      style = style!.copyWith(
        color: style.color!.withValues(alpha: state.opacity),
      );
    }

    return _AnimatedTitleParentDataWidget(
      hasLeading: state.leading != null,
      child: DefaultTextStyle.merge(
        style: style,
        child: state.appBar.title ?? const SizedBox.shrink(),
      ),
    );
  }

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _AnimatedTitleLayout(t: t);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) => (renderObject as _AnimatedTitleLayout).t = t;
}

class _AnimatedTitleParentDataWidget
    extends ParentDataWidget<_AnimatedTitleParentData> {
  const _AnimatedTitleParentDataWidget({
    required this.hasLeading,
    required super.child,
  });

  final bool hasLeading;

  @override
  Type get debugTypicalAncestorWidgetClass => _AnimatedTitleLayout;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is _AnimatedTitleParentData);
    final parentData = renderObject.parentData! as _AnimatedTitleParentData;
    if (parentData.hasLeading == hasLeading) return;

    parentData.hasLeading = hasLeading;
    final targetParent = renderObject.parent;
    if (targetParent is RenderObject) targetParent.markNeedsLayout();
  }
}

class _AnimatedTitleParentData extends ContainerBoxParentData<RenderBox> {
  bool? hasLeading;
}

class _AnimatedTitleLayout
    extends AnimatedAppBarLayout<_AnimatedTitleParentData> {
  _AnimatedTitleLayout({super.t});

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! _AnimatedTitleParentData) {
      child.parentData = _AnimatedTitleParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      children.map((c) => c.getMinIntrinsicWidth(height)).max;
  @override
  double computeMaxIntrinsicWidth(double height) =>
      children.map((c) => c.getMaxIntrinsicWidth(height)).max;
  @override
  double computeMinIntrinsicHeight(double width) =>
      children.map((c) => c.getMinIntrinsicHeight(width)).max;
  @override
  double computeMaxIntrinsicHeight(double width) =>
      children.map((c) => c.getMaxIntrinsicHeight(width)).max;

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void performLayout() {
    assert(!sizedByParent);

    final parent = firstChild!;
    final child = parent.data.nextSibling!;

    parent.layout(constraints, parentUsesSize: true);
    child.layout(constraints, parentUsesSize: true);
    size = parent.size.coerceAtLeast(child.size);

    parent.data.offset = Offset(
      lerpDouble(0, -kToolbarHeight, t)! +
          (parent.data.hasLeading! ? 0 : -kToolbarHeight),
      (size.height - parent.size.height) / 2,
    );
    child.data.offset = Offset(
      lerpDouble(kToolbarHeight, 0, t)! +
          (child.data.hasLeading! ? 0 : -kToolbarHeight),
      (size.height - child.size.height) / 2,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final parent = firstChild!;
    final child = parent.data.nextSibling!;

    context
      ..pushOpacity(
        parent.data.offset + offset,
        math.max<double>(0, 1 - t * 2).opacityToAlpha,
        (context, offset) => context.paintChild(parent, offset),
      )
      ..pushOpacity(
        child.data.offset + offset,
        math.max<double>(0, t * 2 - 1).opacityToAlpha,
        (context, offset) => context.paintChild(child, offset),
      );
  }
}

extension _ParentData on RenderBox {
  _AnimatedTitleParentData get data => parentData! as _AnimatedTitleParentData;
}
