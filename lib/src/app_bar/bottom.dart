import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'app_bar.dart';
import 'state.dart';

class AnimatedBottom extends AnimatedAppBarPart implements PreferredSizeWidget {
  const AnimatedBottom(MorphingState state) : super(state);

  @override
  Size get preferredSize => Size.fromHeight(preferredHeight);

  double get preferredHeight => lerpDouble(
      _resolvePreferredHeight(parent), _resolvePreferredHeight(child), t);
  double _resolvePreferredHeight(EndState state) =>
      state.appBar.bottom?.preferredSize?.height ?? 0;

  @override
  Widget build(BuildContext context) {
    final hasParent = parent.appBar.bottom != null;
    final hasChild = child.appBar.bottom != null;
    if (!hasParent && !hasChild) {
      return SizedBox();
    }

    if (hasParent &&
        hasChild &&
        Widget.canUpdate(parent.appBar.bottom, child.appBar.bottom)) {
      // Do a simple crossfade.
      return SizedBox(
        height: preferredHeight,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              top: null,
              child: Opacity(opacity: 1 - t, child: parent.appBar.bottom),
            ),
            Positioned.fill(
              top: null,
              child: Opacity(opacity: t, child: child.appBar.bottom),
            ),
          ],
        ),
      );
    }

    // Fade out the parent and then fade in the child.
    final parentEnd = hasChild ? 0.5 : 1;
    final childStart = hasParent ? 0.5 : 0;
    return SizedBox(
      height: preferredHeight,
      child: Stack(
        children: <Widget>[
          if (hasParent && t < parentEnd)
            Positioned.fill(top: null, child: parent.appBar.bottom),
          if (hasChild && t > childStart)
            Positioned.fill(top: null, child: child.appBar.bottom),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: _buildScrimGradient(
                  hasParent: hasParent,
                  hasChild: hasChild,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Gradient _buildScrimGradient({
    @required bool hasParent,
    @required bool hasChild,
  }) {
    final triangleT = math.min(t, 1 - t) * 2;
    final backgroundColor = state.backgroundColor;

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        if (hasParent && hasChild)
          backgroundColor.withOpacity(triangleT)
        else if (hasParent)
          backgroundColor.withOpacity(t)
        else if (hasChild)
          backgroundColor.withOpacity(1 - t),
        backgroundColor.withAlpha(0),
      ],
      stops: [
        if (hasParent && hasChild) triangleT else 0.0,
        1,
      ],
    );
  }
}
