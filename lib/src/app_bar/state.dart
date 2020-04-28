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

  Color get backgroundColor {
    assert(parent.backgroundColor.isOpaque);
    assert(child.backgroundColor.isOpaque);

    return Color.lerp(parent.backgroundColor, child.backgroundColor, t);
  }
}

@immutable
class EndState {
  EndState(this.context, this.appBar)
      : assert(context != null),
        assert(appBar != null),
        leading = AnimatedLeading.resolveLeading(context, appBar);

  final BuildContext context;
  final AppBar appBar;

  ThemeData get theme => context.theme;
  AppBarTheme get appBarTheme => theme.appBarTheme;

  double get opacity {
    return Interval(0.25, 1, curve: Curves.fastOutSlowIn)
        .transform(appBar.toolbarOpacity);
  }

  final Widget leading;
  Color get backgroundColor =>
      appBar.backgroundColor ?? appBarTheme.color ?? theme.primaryColor;
}
