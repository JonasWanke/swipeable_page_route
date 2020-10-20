import 'dart:ui';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'leading.dart';

@immutable
class MorphingState {
  const MorphingState({
    @required this.parent,
    @required this.child,
    @required this.t,
  })  : assert(parent != null),
        assert(child != null),
        assert(t != null);

  final EndState parent;
  final EndState child;
  final double t;

  Brightness get brightness =>
      t < 0.5 ? parent.appBar.brightness : child.appBar.brightness;
  Color get backgroundColor =>
      Color.lerp(parent.backgroundColor, child.backgroundColor, t);
}

@immutable
class EndState {
  EndState(BuildContext context, this.appBar)
      : assert(context != null),
        theme = context.theme,
        assert(appBar != null),
        leading = AnimatedLeading.resolveLeading(context, appBar);

  final ThemeData theme;
  AppBarTheme get appBarTheme => theme.appBarTheme;

  final AppBar appBar;

  double get opacity {
    return Interval(0.25, 1, curve: Curves.fastOutSlowIn)
        .transform(appBar.toolbarOpacity);
  }

  final Widget leading;
  IconThemeData get iconTheme {
    final overallIconTheme =
        appBar.iconTheme ?? appBarTheme.iconTheme ?? theme.primaryIconTheme;
    return overallIconTheme.copyWith(
      opacity: opacity * (overallIconTheme.opacity ?? 1.0),
    );
  }

  Color get backgroundColor =>
      appBar.backgroundColor ?? appBarTheme.color ?? theme.primaryColor;
}
