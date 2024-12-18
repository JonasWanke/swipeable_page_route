import 'dart:math' as math;

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'app_bar.dart';
import 'state.dart';

class AnimatedFlexibleSpace extends MultiChildRenderObjectWidget {
  AnimatedFlexibleSpace(MorphingState state)
      : t = state.t,
        super(
          children: [
            state.parent.appBar.flexibleSpace ?? const SizedBox(),
            state.child.appBar.flexibleSpace ?? const SizedBox(),
          ],
        );

  final double t;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _AnimatedFlexibleSpaceLayout(t: t);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) =>
      (renderObject as _AnimatedFlexibleSpaceLayout).t = t;
}

class _AnimatedFlexibleSpaceParentData
    extends ContainerBoxParentData<RenderBox> {}

class _AnimatedFlexibleSpaceLayout
    extends AnimatedAppBarLayout<_AnimatedFlexibleSpaceParentData> {
  _AnimatedFlexibleSpaceLayout({super.t});

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! _AnimatedFlexibleSpaceParentData) {
      child.parentData = _AnimatedFlexibleSpaceParentData();
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

    parent.data.offset = Offset(0, (size.height - parent.size.height) / 2);
    child.data.offset = Offset(0, (size.height - child.size.height) / 2);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final parent = firstChild!;
    final child = parent.data.nextSibling!;

    context
      ..pushOpacity(
        offset,
        math.max<double>(0, 1 - t).opacityToAlpha,
        (context, offset) => context.paintChild(parent, offset),
      )
      ..pushOpacity(
        offset,
        math.max<double>(0, t).opacityToAlpha,
        (context, offset) => context.paintChild(child, offset),
      );
  }
}

extension _ParentData on RenderBox {
  _AnimatedFlexibleSpaceParentData get data =>
      parentData! as _AnimatedFlexibleSpaceParentData;
}
