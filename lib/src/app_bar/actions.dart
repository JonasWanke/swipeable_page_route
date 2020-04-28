import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:dartx/dartx.dart';
import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:swipeable_page_route/src/app_bar/app_bar.dart';

import 'state.dart';

class AnimatedActions extends MultiChildRenderObjectWidget {
  factory AnimatedActions(MorphingState state) {
    // final difference = await diff<Widget>(
    //   state.parent.appBar.actions ?? [],
    //   state.child.appBar.actions ?? [],
    //   spawnIsolate: false,
    //   areEqual: Widget.canUpdate,
    //   getHashCode: (widget) => hashValues(widget.runtimeType, widget.key),
    // );
    if (state.parent.appBar.actions?.isEmpty != false) {
      return AnimatedActions._(
        t: state.t,
        groups: [_ActionGroupType.changes],
        children: <Widget>[
          _AnimatedActionsParentDataWidget(
            position: _ActionPosition.child,
            groupIndex: 0,
            child: state.child.appBar.actions.first,
          ),
          _AnimatedActionsParentDataWidget(
            position: _ActionPosition.child,
            groupIndex: 0,
            child: state.child.appBar.actions.second,
          ),
          _AnimatedActionsParentDataWidget(
            position: _ActionPosition.child,
            groupIndex: 0,
            child: state.child.appBar.actions.third,
          ),
        ],
      );
    }

    final children = [
      _AnimatedActionsParentDataWidget(
        position: _ActionPosition.parent,
        groupIndex: 0,
        child: state.parent.appBar.actions.first,
      ),
      _AnimatedActionsParentDataWidget(
        position: _ActionPosition.parent,
        groupIndex: 1,
        child: state.parent.appBar.actions.second,
      ),
      _AnimatedActionsParentDataWidget(
        position: _ActionPosition.parent,
        groupIndex: 3,
        child: state.parent.appBar.actions.third,
      ),
      _AnimatedActionsParentDataWidget(
        position: _ActionPosition.child,
        groupIndex: 1,
        child: state.child.appBar.actions.first,
      ),
      _AnimatedActionsParentDataWidget(
        position: _ActionPosition.child,
        groupIndex: 2,
        child: state.child.appBar.actions.second,
      ),
      _AnimatedActionsParentDataWidget(
        position: _ActionPosition.child,
        groupIndex: 3,
        child: state.child.appBar.actions.third,
      ),
    ];
    final groups = [
      _ActionGroupType.changes,
      _ActionGroupType.stays,
      _ActionGroupType.changes,
      _ActionGroupType.stays,
    ];
    return AnimatedActions._(
      t: state.t,
      groups: groups,
      children: children,
    );
  }
  AnimatedActions._({
    @required this.t,
    @required List<_ActionGroupType> groups,
    @required List<Widget> children,
  })  : assert(t != null),
        assert(groups != null),
        _groups = groups,
        super(children: children);

  final double t;
  final List<_ActionGroupType> _groups;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _AnimatedActionsLayout(t: t, groups: _groups);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _AnimatedActionsLayout renderObject,
  ) {
    renderObject
      ..t = t
      ..groups = _groups;
  }
}

class _AnimatedActionsParentDataWidget
    extends ParentDataWidget<AnimatedActions> {
  const _AnimatedActionsParentDataWidget({
    Key key,
    @required this.position,
    @required this.groupIndex,
    @required Widget child,
  })  : assert(position != null),
        assert(groupIndex != null),
        super(key: key, child: child);

  final _ActionPosition position;
  final int groupIndex;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is _AnimatedActionsParentData);
    final _AnimatedActionsParentData parentData = renderObject.parentData;

    var needsLayout = false;
    if (parentData.position != position) {
      parentData.position = position;
      needsLayout = true;
    }
    if (parentData.groupIndex != groupIndex) {
      parentData.groupIndex = groupIndex;
      needsLayout = true;
    }
    if (needsLayout) {
      final targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }
  }
}

enum _ActionPosition { parent, child }
enum _ActionGroupType { stays, changes }

class _AnimatedActionsParentData extends ContainerBoxParentData<RenderBox> {
  _ActionPosition position;
  int groupIndex;
}

class _AnimatedActionsLayout
    extends AnimatedAppBarLayout<_AnimatedActionsParentData> {
  _AnimatedActionsLayout({
    double t = 0,
    @required List<_ActionGroupType> groups,
  })  : assert(groups != null),
        _groups = groups,
        super(t: t);

  List<_ActionGroupType> _groups;
  List<_ActionGroupType> get groups => _groups;
  set groups(List<_ActionGroupType> value) {
    assert(value != null);
    if (_groups == value) {
      return;
    }

    _groups = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! _AnimatedActionsParentData) {
      child.parentData = _AnimatedActionsParentData();
    }
  }

  Iterable<RenderBox> get _parentChildren =>
      children.where((c) => c.data.position == _ActionPosition.parent);
  Iterable<RenderBox> get _childChildren =>
      children.where((c) => c.data.position == _ActionPosition.child);

  @override
  double computeMinIntrinsicWidth(double height) {
    return lerpDouble(
      _parentChildren.sumBy((c) => c.getMinIntrinsicWidth(height)),
      _childChildren.sumBy((c) => c.getMinIntrinsicWidth(height)),
      t,
    );
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return lerpDouble(
      _parentChildren.sumBy((c) => c.getMaxIntrinsicWidth(height)),
      _childChildren.sumBy((c) => c.getMaxIntrinsicWidth(height)),
      t,
    );
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return lerpDouble(
      _parentChildren.map((c) => c.getMinIntrinsicHeight(width)).min() ?? 0,
      _childChildren.map((c) => c.getMinIntrinsicHeight(width)).min() ?? 0,
      t,
    );
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return lerpDouble(
      _parentChildren.map((c) => c.getMaxIntrinsicHeight(width)).max() ?? 0,
      _childChildren.map((c) => c.getMaxIntrinsicHeight(width)).max() ?? 0,
      t,
    );
  }

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void performLayout() {
    assert(!sizedByParent);

    final groupWidths = List.generate(groups.length, (_) => 0.0);
    final groupParentWidths = List.generate(groups.length, (_) => 0.0);
    final groupChildWidths = List.generate(groups.length, (_) => 0.0);

    final childConstraints = BoxConstraints(
      minHeight: constraints.maxHeight,
      maxHeight: constraints.maxHeight,
    );
    for (final child in children) {
      child.layout(childConstraints, parentUsesSize: true);

      final groupIndex = child.data.groupIndex;
      final width = child.size.width;
      groupWidths[groupIndex] += width;
      if (child.data.position == _ActionPosition.parent) {
        groupParentWidths[groupIndex] += width;
      } else {
        groupChildWidths[groupIndex] += width;
      }
    }

    size = Size(groupWidths.sum(), constraints.maxHeight);

    final parentChildren = _parentChildren.toList();
    final childChildren = _childChildren.toList();

    var x = 0.0;
    for (final i in groups.indices) {
      final groupWidth = groupWidths[i];
      final center = x + groupWidth / 2;

      var childX = center - groupChildWidths[i] / 2;
      for (final child in childChildren.where((c) => c.data.groupIndex == i)) {
        child.data.offset = Offset(childX, 0);
        childX += child.size.width;
      }

      var parentX = center - groupParentWidths[i] / 2;
      for (final child in parentChildren.where((c) => c.data.groupIndex == i)) {
        child.data.offset = Offset(parentX, 0);
        parentX += child.size.width;
      }

      x += groupWidth;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    for (final child in children) {
      final parentData = child.data;

      final opacity = {
        _ActionPosition.parent: 1 - t,
        _ActionPosition.child: t,
      }[parentData.position];
      assert(opacity != null);

      context.pushOpacity(
        parentData.offset + offset,
        opacity.opacityToAlpha,
        (context, offset) => context.paintChild(child, offset),
      );
    }
  }
}

extension _ParentData on RenderBox {
  _AnimatedActionsParentData get data =>
      parentData as _AnimatedActionsParentData;
}
