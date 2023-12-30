import 'dart:ui';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_color_models/flutter_color_models.dart';

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
  Color get surfaceTintColor =>
      _lerpColor(parent.surfaceTintColor, child.surfaceTintColor, t);
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

  /// Interpolate between colors in Oklab space, where `null` values are treated
  /// as transparent.
  static Color _lerpColor(Color? a, Color? b, double t) {
    if (a == null && b == null) return Colors.transparent;

    final aAsOklab = a == null ? null : OklabColor.fromColor(a);
    final bAsOklab = b == null ? null : OklabColor.fromColor(b);
    return (aAsOklab ?? bAsOklab!.withAlpha(0))
        .interpolate(bAsOklab ?? aAsOklab!.withAlpha(0), t)
        .toColor();
  }
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

  double get elevation =>
      appBar.elevation ?? appBarTheme.elevation ?? (theme.useMaterial3 ? 0 : 4);
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

  Color? get surfaceTintColor {
    return appBar.surfaceTintColor ??
        appBarTheme.surfaceTintColor ??
        (theme.useMaterial3 ? theme.colorScheme.surfaceTint : null);
  }

  ShapeBorder? get shape => appBar.shape;

  Color get backgroundColor {
    return appBar.backgroundColor ??
        appBarTheme.backgroundColor ??
        (theme.useMaterial3
            ? theme.colorScheme.surface
            : theme.colorScheme.brightness == Brightness.dark
                ? theme.colorScheme.surface
                : theme.colorScheme.primary);
  }

  Color get foregroundColor {
    return appBar.foregroundColor ??
        appBarTheme.foregroundColor ??
        (theme.useMaterial3
            ? theme.colorScheme.onSurface
            : theme.colorScheme.brightness == Brightness.dark
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onPrimary);
  }

  IconThemeData get overallIconTheme {
    return appBar.iconTheme ??
        appBarTheme.iconTheme ??
        (theme.useMaterial3 ? const IconThemeData(size: 24) : theme.iconTheme)
            .copyWith(color: foregroundColor);
  }

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

  double get toolbarHeight =>
      appBar.toolbarHeight ?? (theme.useMaterial3 ? 64 : kToolbarHeight);
  double get leadingWidth => appBar.leadingWidth ?? kToolbarHeight;

  TextStyle? get toolbarTextStyle {
    return appBar.toolbarTextStyle ??
        appBarTheme.toolbarTextStyle ??
        theme.textTheme.bodyMedium?.copyWith(color: foregroundColor);
  }

  TextStyle? get titleTextStyle {
    return appBar.titleTextStyle ??
        appBarTheme.titleTextStyle ??
        theme.textTheme.titleLarge?.copyWith(color: foregroundColor);
  }

  SystemUiOverlayStyle get systemOverlayStyle =>
      appBar.systemOverlayStyle ??
      appBarTheme.systemOverlayStyle ??
      backgroundColor.contrastSystemUiOverlayStyle;
}
