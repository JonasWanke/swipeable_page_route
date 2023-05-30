import 'dart:ui';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:list_diff/list_diff.dart';

import 'app_bar.dart';
import 'state.dart';

class AnimatedActions extends MultiChildRenderObjectWidget {
  factory AnimatedActions(MorphingState state) {
    final parentIconTheme = state.parent.actionsIconTheme;
    final childIconTheme = state.child.actionsIconTheme;
    final parentActions = state.parent.appBar.actions ?? [];
    final childActions = state.child.appBar.actions ?? [];
    Iterable<Operation<Widget>> difference = diffSync(
      parentActions,
      childActions,
      areEqual: Widget.canUpdate,
    );

    // We convert the list of [Operation]s into a sequence of groups with either
    // children being the same in parent and child ([_ActionGroupType.stays]) or
    // children changing (missing or new items in child compared to parent;
    // [_ActionGroupType.changes]).
    final groups = <_ActionGroupType>[];
    final children = <_AnimatedActionsParentDataWidget>[];

    // Current index in parentActions.
    var parentIndex = 0;
    // Current index in childActions.
    var childIndex = 0;
    // Current index in the merged state of both.
    var changeIndex = 0;

    bool itemsLeft() =>
        parentIndex < parentActions.length || childIndex < childActions.length;

    void tryMatchStaysGroup() {
      final groupIndex = groups.length;
      var anyMatch = false;
      while ((difference.isEmpty || difference.first.index != changeIndex) &&
          itemsLeft()) {
        children
          ..add(_AnimatedActionsParentDataWidget(
            position: _ActionPosition.child,
            groupIndex: groupIndex,
            child: IconTheme.merge(
              data: childIconTheme,
              child: childActions[childIndex],
            ),
          ))
          ..add(_AnimatedActionsParentDataWidget(
            position: _ActionPosition.parent,
            groupIndex: groupIndex,
            child: IconTheme.merge(
              data: parentIconTheme,
              child: parentActions[parentIndex],
            ),
          ));
        parentIndex++;
        childIndex++;
        changeIndex++;

        anyMatch = true;
      }
      if (anyMatch) {
        groups.add(_ActionGroupType.stays);
      }
    }

    void tryMatchChangeGroup() {
      final groupIndex = groups.length;
      var anyMatch = false;
      while (difference.isNotEmpty &&
          difference.first.index == changeIndex &&
          itemsLeft()) {
        if (difference.first.isInsertion) {
          children.add(_AnimatedActionsParentDataWidget(
            position: _ActionPosition.child,
            groupIndex: groupIndex,
            child: IconTheme.merge(
              data: childIconTheme,
              child: childActions[childIndex],
            ),
          ));
          childIndex++;
          changeIndex++;
        } else {
          assert(difference.first.isDeletion);
          children.add(_AnimatedActionsParentDataWidget(
            position: _ActionPosition.parent,
            groupIndex: groupIndex,
            child: IconTheme.merge(
              data: parentIconTheme,
              child: parentActions[parentIndex],
            ),
          ));
          parentIndex++;
        }

        difference = difference.skip(1);
        anyMatch = true;
      }
      if (anyMatch) {
        groups.add(_ActionGroupType.changes);
      }
    }

    while (itemsLeft()) {
      tryMatchStaysGroup();
      tryMatchChangeGroup();
    }

    return AnimatedActions._(
      t: state.t,
      groups: groups,
      children: children,
    );
  }
  const AnimatedActions._({
    required this.t,
    required List<_ActionGroupType> groups,
    required List<_AnimatedActionsParentDataWidget> children,
  })  : _groups = groups,
        super(children: children);

  final double t;
  final List<_ActionGroupType> _groups;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _AnimatedActionsLayout(t: t, groups: _groups);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) {
    (renderObject as _AnimatedActionsLayout)
      ..t = t
      ..groups = _groups;
  }
}

class _AnimatedActionsParentDataWidget
    extends ParentDataWidget<_AnimatedActionsParentData> {
  const _AnimatedActionsParentDataWidget({
    required this.position,
    required this.groupIndex,
    required super.child,
  });

  final _ActionPosition position;
  final int groupIndex;

  @override
  Type get debugTypicalAncestorWidgetClass => _AnimatedActionsLayout;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is _AnimatedActionsParentData);
    final parentData = renderObject.parentData! as _AnimatedActionsParentData;

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
  _ActionPosition? position;
  int? groupIndex;
}

class _AnimatedActionsLayout
    extends AnimatedAppBarLayout<_AnimatedActionsParentData> {
  _AnimatedActionsLayout({
    super.t,
    required List<_ActionGroupType> groups,
  }) : _groups = groups;

  List<_ActionGroupType> _groups;
  List<_ActionGroupType> get groups => _groups;
  set groups(List<_ActionGroupType> value) {
    if (_groups == value) return;

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
      _parentChildren.map((c) => c.getMinIntrinsicWidth(height)).sum,
      _childChildren.map((c) => c.getMinIntrinsicWidth(height)).sum,
      t,
    )!;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return lerpDouble(
      _parentChildren.map((c) => c.getMaxIntrinsicWidth(height)).sum,
      _childChildren.map((c) => c.getMaxIntrinsicWidth(height)).sum,
      t,
    )!;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return lerpDouble(
      _parentChildren.map((c) => c.getMinIntrinsicHeight(width)).minOrNull ?? 0,
      _childChildren.map((c) => c.getMinIntrinsicHeight(width)).minOrNull ?? 0,
      t,
    )!;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return lerpDouble(
      _parentChildren.map((c) => c.getMaxIntrinsicHeight(width)).maxOrNull ?? 0,
      _childChildren.map((c) => c.getMaxIntrinsicHeight(width)).maxOrNull ?? 0,
      t,
    )!;
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
      if (child.data.position! == _ActionPosition.parent) {
        groupWidths[groupIndex!] += width * (1 - t);
        groupParentWidths[groupIndex] += width;
      } else {
        groupWidths[groupIndex!] += width * t;
        groupChildWidths[groupIndex] += width;
      }
    }

    size = Size(groupWidths.sum, constraints.maxHeight);

    final parentChildren = _parentChildren.toList();
    final childChildren = _childChildren.toList();

    var x = 0.0;
    for (var i = 0; i < groups.length; i++) {
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
      }[parentData.position!]!;

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
      parentData! as _AnimatedActionsParentData;
}
