import 'dart:ui';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:flutter_color_models/flutter_color_models.dart';
// import 'package:okcolor/okcolor.dart';

import 'color.dart';
import 'leading.dart';

@immutable
class EndState {
  final ThemeData theme;
  final AppBar appBar;
  final Widget? leading;
  EndState(BuildContext context, this.appBar)
      : theme = context.theme,
        leading = AnimatedLeading.resolveLeading(context, appBar);

  IconThemeData get actionsIconTheme {
    return appBar.actionsIconTheme ??
        appBarTheme.actionsIconTheme ??
        appBar.iconTheme ??
        appBarTheme.iconTheme ??
        (theme.useMaterial3
            ? IconThemeData(
                color: appBar.foregroundColor ??
                    appBarTheme.foregroundColor ??
                    theme.colorScheme.onSurfaceVariant,
                size: 24,
              )
            : null) ??
        overallIconTheme;
  }

  AppBarTheme get appBarTheme => theme.appBarTheme;
  Color get backgroundColor {
    return appBar.backgroundColor ??
        appBarTheme.backgroundColor ??
        (theme.useMaterial3
            ? theme.colorScheme.surface
            : theme.colorScheme.brightness == Brightness.dark
                ? theme.colorScheme.surface
                : theme.colorScheme.primary);
  }

  double get bottomOpacity => appBar.bottomOpacity;

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

  Clip? get clipBehavior => appBar.clipBehavior;

  double get elevation =>
      appBar.elevation ?? appBarTheme.elevation ?? (theme.useMaterial3 ? 0 : 4);

  bool get excludeHeaderSemantics => appBar.excludeHeaderSemantics;

  bool get forceMaterialTransparency => appBar.forceMaterialTransparency;

  Color get foregroundColor {
    return appBar.foregroundColor ??
        appBarTheme.foregroundColor ??
        (theme.useMaterial3
            ? theme.colorScheme.onSurface
            : theme.colorScheme.brightness == Brightness.dark
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onPrimary);
  }

  double get leadingWidth => appBar.leadingWidth ?? kToolbarHeight;

  double get opacity => appBar.toolbarOpacity;

  IconThemeData get overallIconTheme {
    return appBar.iconTheme ??
        appBarTheme.iconTheme ??
        (theme.useMaterial3 ? const IconThemeData(size: 24) : theme.iconTheme)
            .copyWith(color: foregroundColor);
  }

  double? get scrolledUnderElevation {
    return appBar.elevation ??
        appBarTheme.elevation ??
        (theme.useMaterial3 ? 3 : null);
  }

  Color get shadowColor {
    return appBar.shadowColor ??
        appBarTheme.shadowColor ??
        (theme.useMaterial3 ? Colors.transparent : Colors.black);
  }

  ShapeBorder? get shape => appBar.shape;
  Color? get surfaceTintColor {
    return appBar.surfaceTintColor ??
        appBarTheme.surfaceTintColor ??
        (theme.useMaterial3 ? theme.colorScheme.surfaceTint : null);
  }

  SystemUiOverlayStyle get systemOverlayStyle =>
      appBar.systemOverlayStyle ??
      appBarTheme.systemOverlayStyle ??
      backgroundColor.contrastSystemUiOverlayStyle;

  double get titleSpacing {
    return appBar.titleSpacing ??
        appBarTheme.titleSpacing ??
        NavigationToolbar.kMiddleSpacing;
  }

  TextStyle? get titleTextStyle {
    return appBar.titleTextStyle ??
        appBarTheme.titleTextStyle ??
        theme.textTheme.titleLarge?.copyWith(color: foregroundColor);
  }

  double get toolbarHeight =>
      appBar.toolbarHeight ?? (theme.useMaterial3 ? 64 : kToolbarHeight);

  TextStyle? get toolbarTextStyle {
    return appBar.toolbarTextStyle ??
        appBarTheme.toolbarTextStyle ??
        theme.textTheme.bodyMedium?.copyWith(color: foregroundColor);
  }
}

@immutable
class MorphingState {
  final EndState parent;
  final EndState child;
  final double t;
  const MorphingState({
    required this.parent,
    required this.child,
    required this.t,
  });

  IconThemeData get actionsIconTheme =>
      IconThemeData.lerp(parent.actionsIconTheme, child.actionsIconTheme, t);
  Color get backgroundColor =>
      _lerpColor(parent.backgroundColor, child.backgroundColor, t);

  double get bottomOpacity =>
      lerpDouble(parent.bottomOpacity, child.bottomOpacity, t)!;

  bool get centerTitle => t < 0.5 ? parent.centerTitle : child.centerTitle;
  Clip? get clipBehavior => t < 0.5 ? parent.clipBehavior : child.clipBehavior;
  double get elevation => lerpDouble(parent.elevation, child.elevation, t)!;

  bool get excludeHeaderSemantics =>
      t < 0.5 ? parent.excludeHeaderSemantics : child.excludeHeaderSemantics;
  bool get forceMaterialTransparency => t < 0.5
      ? parent.forceMaterialTransparency
      : child.forceMaterialTransparency;

  Color get foregroundColor =>
      _lerpColor(parent.foregroundColor, child.foregroundColor, t);
  IconThemeData get iconTheme =>
      IconThemeData.lerp(parent.overallIconTheme, child.overallIconTheme, t);

  double get leadingWidth =>
      lerpDouble(parent.leadingWidth, child.leadingWidth, t)!;
  ScrollNotificationPredicate get notificationPredicate => t < 0.5
      ? parent.appBar.notificationPredicate
      : child.appBar.notificationPredicate;

  double get scrolledUnderElevation {
    return lerpDouble(
      parent.scrolledUnderElevation,
      child.scrolledUnderElevation,
      t,
    )!;
  }

  Color get shadowColor => _lerpColor(parent.shadowColor, child.shadowColor, t);
  ShapeBorder? get shape => ShapeBorder.lerp(parent.shape, child.shape, t);

  Color get surfaceTintColor =>
      _lerpColor(parent.surfaceTintColor, child.surfaceTintColor, t);
  SystemUiOverlayStyle get systemOverlayStyle =>
      t < 0.5 ? parent.systemOverlayStyle : child.systemOverlayStyle;

  double get titleSpacing =>
      lerpDouble(parent.titleSpacing, child.titleSpacing, t)!;
  TextStyle? get titleTextStyle =>
      TextStyle.lerp(parent.titleTextStyle, child.titleTextStyle, t);

  double get toolbarHeight =>
      lerpDouble(parent.toolbarHeight, child.toolbarHeight, t)!;

  double get toolbarOpacity => lerpDouble(parent.opacity, child.opacity, t)!;

  TextStyle? get toolbarTextStyle =>
      TextStyle.lerp(parent.toolbarTextStyle, child.toolbarTextStyle, t);

  // double pow(double base, double exponent) {
  //   return double.parse(dartMath.pow(base, exponent).toStringAsFixed(10));
  // }

  /// Interpolate between colors in Oklab space, where `null` values are treated
  /// as transparent.
  static Color _lerpColor(Color? a, Color? b, double t) {
    if (a == null && b == null) return Colors.transparent;

    final aLinear = a?.srgbToLinear();
    final bLinear = b?.srgbToLinear();

    final aRed = aLinear?.r ?? 0;
    final aGreen = aLinear?.g ?? 0;
    final aBlue = aLinear?.b ?? 0;
    final aAlpha = aLinear?.a ?? 0;

    final bRed = bLinear?.r ?? 0;
    final bGreen = bLinear?.g ?? 0;
    final bBlue = bLinear?.b ?? 0;
    final bAlpha = bLinear?.a ?? 0;

    final red = (aRed + (bRed - aRed) * t).round().clamp(0, 255);
    final green = (aGreen + (bGreen - aGreen) * t).round().clamp(0, 255);
    final blue = (aBlue + (bBlue - aBlue) * t).round().clamp(0, 255);
    final alpha = (aAlpha + (bAlpha - aAlpha) * t).round().clamp(0, 255);

    return Color.fromARGB(alpha, red, green, blue).linearToSrgb();
  }
}
