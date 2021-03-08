import 'dart:ui';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'leading.dart';

@immutable
class MorphingState {
  const MorphingState({
    required this.parent,
    required this.child,
    required this.t,
  });

  final EndState parent;
  final EndState child;
  final double t;

  double get elevation => lerpDouble(parent.elevation, child.elevation, t)!;
  Color get shadowColor => _lerpColor(parent.shadowColor, child.shadowColor, t);
  ShapeBorder? get shape => ShapeBorder.lerp(parent.shape, child.shape, t);

  Color get backgroundColor =>
      _lerpColor(parent.backgroundColor, child.backgroundColor, t);
  Color get foregroundColor =>
      _lerpColor(parent.foregroundColor, child.foregroundColor, t);

  IconThemeData get iconTheme =>
      IconThemeData.lerp(parent.overallIconTheme, child.overallIconTheme, t);
  IconThemeData get actionsIconTheme =>
      IconThemeData.lerp(parent.actionsIconTheme, child.actionsIconTheme, t);

  bool get centerTitle => t < 0.5 ? parent.centerTitle : child.centerTitle;
  bool get excludeHeaderSemantics =>
      t < 0.5 ? parent.excludeHeaderSemantics : child.excludeHeaderSemantics;

  double get titleSpacing =>
      lerpDouble(parent.titleSpacing, child.titleSpacing, t)!;
  double get toolbarOpacity => lerpDouble(parent.opacity, child.opacity, t)!;
  double get bottomOpacity =>
      lerpDouble(parent.bottomOpacity, child.bottomOpacity, t)!;

  double get toolbarHeight =>
      lerpDouble(parent.toolbarHeight, child.toolbarHeight, t)!;
  double get leadingWidth =>
      lerpDouble(parent.leadingWidth, child.leadingWidth, t)!;

  TextStyle? get toolbarTextStyle =>
      TextStyle.lerp(parent.toolbarTextStyle, child.toolbarTextStyle, t);
  TextStyle? get titleTextStyle =>
      TextStyle.lerp(parent.titleTextStyle, child.titleTextStyle, t);

  SystemUiOverlayStyle get systemOverlayStyle =>
      t < 0.5 ? parent.systemOverlayStyle : child.systemOverlayStyle;

  static Color _lerpColor(Color a, Color b, double t) =>
      HSVColor.lerp(HSVColor.fromColor(a), HSVColor.fromColor(b), t)!.toColor();
}

@immutable
class EndState {
  EndState(BuildContext context, this.appBar)
      : theme = context.theme,
        leading = AnimatedLeading.resolveLeading(context, appBar);

  final ThemeData theme;
  AppBarTheme get appBarTheme => theme.appBarTheme;

  final AppBar appBar;

  final Widget? leading;

  double get elevation => appBar.elevation ?? appBarTheme.elevation ?? 4;
  Color get shadowColor =>
      appBar.shadowColor ?? appBarTheme.shadowColor ?? Colors.black;
  ShapeBorder? get shape => appBar.shape;

  Color get backgroundColor {
    return appBar.backgroundColor ??
        appBarTheme.backgroundColor ??
        (theme.colorScheme.brightness == Brightness.dark
            ? theme.colorScheme.surface
            : theme.colorScheme.primary);
  }

  Color get foregroundColor {
    return appBar.foregroundColor ??
        appBarTheme.foregroundColor ??
        (theme.colorScheme.brightness == Brightness.dark
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onPrimary);
  }

  IconThemeData get overallIconTheme {
    return appBar.iconTheme ??
        appBarTheme.iconTheme ??
        theme.iconTheme.copyWith(color: foregroundColor);
  }

  IconThemeData get actionsIconTheme {
    return appBar.actionsIconTheme ??
        appBarTheme.actionsIconTheme ??
        overallIconTheme;
  }

  bool get centerTitle {
    if (appBar.centerTitle != null) return appBar.centerTitle!;
    if (appBarTheme.centerTitle != null) return appBarTheme.centerTitle!;
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return false;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return appBar.actions == null || appBar.actions!.length < 2;
    }
  }

  bool get excludeHeaderSemantics => appBar.excludeHeaderSemantics;

  double get titleSpacing {
    return appBar.titleSpacing ??
        appBarTheme.titleSpacing ??
        NavigationToolbar.kMiddleSpacing;
  }

  double get opacity => appBar.toolbarOpacity;
  double get bottomOpacity => appBar.bottomOpacity;

  double get toolbarHeight => appBar.toolbarHeight ?? kToolbarHeight;
  double get leadingWidth => appBar.leadingWidth ?? kToolbarHeight;

  TextStyle? get toolbarTextStyle {
    return appBar.toolbarTextStyle ??
        appBarTheme.toolbarTextStyle ??
        theme.textTheme.bodyText2?.copyWith(color: foregroundColor);
  }

  TextStyle? get titleTextStyle {
    return appBar.titleTextStyle ??
        appBarTheme.titleTextStyle ??
        theme.textTheme.headline6?.copyWith(color: foregroundColor);
  }

  SystemUiOverlayStyle get systemOverlayStyle =>
      appBar.systemOverlayStyle ??
      appBarTheme.systemOverlayStyle ??
      backgroundColor.contrastSystemUiOverlayStyle;
}
