import 'dart:math' as math;
import 'dart:ui';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
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
  double get scrolledUnderElevation {
    return lerpDouble(
      parent.scrolledUnderElevation,
      child.scrolledUnderElevation,
      t,
    )!;
  }

  ScrollNotificationPredicate get notificationPredicate => t < 0.5
      ? parent.appBar.notificationPredicate
      : child.appBar.notificationPredicate;

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

  bool get forceMaterialTransparency => t < 0.5
      ? parent.forceMaterialTransparency
      : child.forceMaterialTransparency;

  Clip? get clipBehavior => t < 0.5 ? parent.clipBehavior : child.clipBehavior;

  /// Interpolate between colors in Oklab space, where `null` values are treated
  /// as transparent.
  static Color _lerpColor(Color? a, Color? b, double t) {
    if (a == null && b == null) return Colors.transparent;

    return _OklabColor.lerp(
          a == null ? null : _OklabColor.fromRgb(a),
          b == null ? null : _OklabColor.fromRgb(b),
          t,
        )?.toRgb() ??
        Colors.transparent;
  }

  FlexibleSpaceBarSettings? get flexibleSpaceBarSettings {
    final parentSettings = parent.flexibleSpaceBarSettings;
    final childSettings = child.flexibleSpaceBarSettings;
    if (parentSettings == null && childSettings == null) return null;

    return FlexibleSpaceBarSettings(
      toolbarOpacity: lerpDouble(
        parentSettings?.toolbarOpacity,
        childSettings?.toolbarOpacity,
        t,
      )!,
      minExtent: lerpDouble(
        parentSettings?.minExtent,
        childSettings?.minExtent,
        t,
      )!,
      maxExtent: lerpDouble(
        parentSettings?.maxExtent,
        childSettings?.maxExtent,
        t,
      )!,
      currentExtent: lerpDouble(
        parentSettings?.currentExtent,
        childSettings?.currentExtent,
        t,
      )!,
      isScrolledUnder: t < 0.5
          ? parentSettings?.isScrolledUnder
          : childSettings?.isScrolledUnder,
      hasLeading:
          t < 0.5 ? parentSettings?.hasLeading : childSettings?.hasLeading,
      child: const SizedBox(),
    );
  }
}

extension type _OklabColor(
    ({double alpha, double l, double a, double b}) components) {
  factory _OklabColor.fromRgb(Color color) {
    final r = _srgbComponentToLinear(color.r);
    final g = _srgbComponentToLinear(color.g);
    final b = _srgbComponentToLinear(color.b);

    // https://bottosson.github.io/posts/oklab/#converting-from-linear-srgb-to-oklab

    final l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b;
    final m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b;
    final s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b;

    final l_ = math.pow(l, 1 / 3);
    final m_ = math.pow(m, 1 / 3);
    final s_ = math.pow(s, 1 / 3);

    return _OklabColor(
      (
        alpha: color.a,
        // ignore: double-literal-format
        l: 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_,
        // ignore: double-literal-format
        a: 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_,
        // ignore: double-literal-format
        b: 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_,
      ),
    );
  }

  static double _srgbComponentToLinear(double component) {
    // https://bottosson.github.io/posts/colorwrong/#what-can-we-do%3F
    return component >= 0.0031308
        ? (1.055 * math.pow(component, 1.0 / 2.4)) - 0.055
        : 12.92 * component;
  }

  static _OklabColor? lerp(_OklabColor? x, _OklabColor? y, double t) {
    return switch ((x, y)) {
      (null, null) => null,
      (final x?, null) => x.scaleAlpha(1 - t),
      (null, final y?) => y.scaleAlpha(t),
      (final x?, final y?) => _OklabColor(
          (
            alpha: lerpDouble(x.components.alpha, y.components.alpha, t)!,
            l: lerpDouble(x.components.l, y.components.l, t)!,
            a: lerpDouble(x.components.a, y.components.a, t)!,
            b: lerpDouble(x.components.b, y.components.b, t)!,
          ),
        ),
    };
  }

  _OklabColor scaleAlpha(double factor) =>
      withAlpha(clampDouble(components.alpha * factor, 0, 1));
  _OklabColor withAlpha(double alpha) {
    return _OklabColor(
      (alpha: alpha, l: components.l, a: components.a, b: components.b),
    );
  }

  Color toRgb() {
    final c = components;

    // https://bottosson.github.io/posts/oklab/#converting-from-linear-srgb-to-oklab

    final l_ = c.l + 0.3963377774 * c.a + 0.2158037573 * c.b;
    final m_ = c.l - 0.1055613458 * c.a - 0.0638541728 * c.b;
    // ignore: double-literal-format
    final s_ = c.l - 0.0894841775 * c.a - 1.2914855480 * c.b;

    final l = l_ * l_ * l_;
    final m = m_ * m_ * m_;
    final s = s_ * s_ * s_;

    final r = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s;
    final g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s;
    // ignore: double-literal-format
    final b = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s;

    return Color.from(
      alpha: components.alpha,
      red: _srgbComponentFromLinear(r),
      green: _srgbComponentFromLinear(g),
      blue: _srgbComponentFromLinear(b),
    );
  }

  static double _srgbComponentFromLinear(double component) {
    // https://bottosson.github.io/posts/colorwrong/#what-can-we-do%3F
    return (component >= 0.04045)
        ? math.pow((component + 0.055) / (1 + 0.055), 2.4).toDouble()
        : component / 12.92;
  }
}

@immutable
class EndState {
  EndState(BuildContext context, this.appBar)
      : theme = context.theme,
        leading = AnimatedLeading.resolveLeading(context, appBar),
        flexibleSpaceBarSettings = context
            .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();

  final ThemeData theme;
  AppBarThemeData get appBarTheme => theme.appBarTheme;
  final FlexibleSpaceBarSettings? flexibleSpaceBarSettings;

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

  bool get forceMaterialTransparency => appBar.forceMaterialTransparency;

  Clip? get clipBehavior => appBar.clipBehavior;
}
