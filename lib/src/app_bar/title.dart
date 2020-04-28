import 'dart:ui';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'state.dart';

class AnimatedTitle extends MultiChildRenderObjectWidget {
  AnimatedTitle(MorphingState state)
      : assert(state != null),
        t = state.t,
        super(
          children: [
            _createChild(state.parent),
            _createChild(state.child),
          ],
        );

  final double t;

  static Widget _createChild(EndState state) {
    final title = state.appBar.title;
    if (title == null) {
      return SizedBox();
    }

    var style = state.appBar.textTheme?.title ??
        state.appBarTheme.textTheme?.title ??
        state.theme.primaryTextTheme.title;
    if (style?.color != null) {
      style = style.copyWith(color: style.color.withOpacity(state.opacity));
    }

    return DefaultTextStyle(style: style, child: title);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _AnimatedTitleLayout(t: t);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _AnimatedTitleLayout renderObject,
  ) {
    renderObject.t = t;
  }
}

class _AnimatedTitleParentData extends ContainerBoxParentData<RenderBox> {}

class _AnimatedTitleLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _AnimatedTitleParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _AnimatedTitleParentData> {
  _AnimatedTitleLayout({
    double t = 0,
  })  : assert(t != null),
        _t = t;

  double _t;
  double get t => _t;
  set t(double value) {
    assert(value != null);
    if (_t == value) {
      return;
    }

    _t = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! _AnimatedTitleParentData) {
      child.parentData = _AnimatedTitleParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      children.map((c) => c.getMinIntrinsicWidth(height)).max();

  @override
  double computeMaxIntrinsicWidth(double height) =>
      children.map((c) => c.getMaxIntrinsicWidth(height)).max();

  @override
  double computeMinIntrinsicHeight(double width) =>
      children.map((c) => c.getMinIntrinsicHeight(width)).max();

  @override
  double computeMaxIntrinsicHeight(double width) =>
      children.map((c) => c.getMaxIntrinsicHeight(width)).max();

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void performLayout() {
    assert(!sizedByParent);

    final parent = firstChild;
    final parentData = parent.parentData as _AnimatedTitleParentData;
    final child = parentData.nextSibling;
    final childData = child.parentData as _AnimatedTitleParentData;

    parent.layout(constraints, parentUsesSize: true);
    child.layout(constraints, parentUsesSize: true);
    size = parent.size.coerceAtLeast(child.size);

    parentData.offset = Offset(
      lerpDouble(0, -kToolbarHeight, t),
      (size.height - parent.size.height) / 2,
    );
    childData.offset = Offset(
      lerpDouble(kToolbarHeight, 0, t),
      (size.height - child.size.height) / 2,
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final parent = firstChild;
    final parentData = parent.parentData as _AnimatedTitleParentData;
    final child = parentData.nextSibling;
    final childData = child.parentData as _AnimatedTitleParentData;

    context
      ..pushOpacity(
        parentData.offset + offset,
        (1 - 2 * t).coerceAtLeast(0).opacityToAlpha,
        (context, offset) => context.paintChild(parent, offset),
      )
      ..pushOpacity(
        childData.offset + offset,
        (2 * t - 1).coerceAtLeast(0).coerceAtLeast(0).opacityToAlpha,
        (context, offset) => context.paintChild(child, offset),
      );
  }
}
