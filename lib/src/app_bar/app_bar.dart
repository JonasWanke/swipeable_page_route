import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'actions.dart';
import 'bottom.dart';
import 'leading.dart';
import 'state.dart';
import 'title.dart';

/// An adapted version of [AppBar] that morphs while navigating.
class MorphingAppBar extends StatelessWidget implements PreferredSizeWidget {
  MorphingAppBar({
    super.key,
    this.heroTag = 'MorphingAppBar',
    this.leading,
    this.automaticallyImplyLeading = true,
    this.title,
    this.actions,
    this.flexibleSpace,
    this.bottom,
    this.elevation,
    this.shadowColor,
    this.shape,
    this.backgroundColor,
    this.foregroundColor,
    this.iconTheme,
    this.actionsIconTheme,
    this.primary = true,
    this.centerTitle,
    this.excludeHeaderSemantics = false,
    this.titleSpacing,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
    this.toolbarHeight,
    this.leadingWidth,
    this.toolbarTextStyle,
    this.titleTextStyle,
    this.systemOverlayStyle,
  })  : assert(elevation == null || elevation >= 0.0),
        preferredSize = Size.fromHeight(
          toolbarHeight ?? kToolbarHeight + (bottom?.preferredSize.height ?? 0),
        );

  /// Tag used for the internally created [Hero] widget.
  // ignore: no-object-declaration
  final Object heroTag;

  /// See [AppBar.leading]
  final Widget? leading;

  /// See [AppBar.automaticallyImplyLeading]
  final bool automaticallyImplyLeading;

  /// See [AppBar.title]
  final Widget? title;

  /// See [AppBar.actions]
  final List<Widget>? actions;

  /// See [AppBar.flexibleSpace]
  final Widget? flexibleSpace;

  /// See [AppBar.bottom]
  final PreferredSizeWidget? bottom;

  /// See [AppBar.elevation]
  final double? elevation;

  /// See [AppBar.shadowColor]
  final Color? shadowColor;

  /// See [AppBar.shape]
  final ShapeBorder? shape;

  /// See [AppBar.backgroundColor]
  final Color? backgroundColor;

  /// See [AppBar.foregroundColor]
  final Color? foregroundColor;

  /// See [AppBar.iconTheme]
  final IconThemeData? iconTheme;

  /// See [AppBar.actionsIconTheme]
  final IconThemeData? actionsIconTheme;

  /// See [AppBar.primary]
  final bool primary;

  /// See [AppBar.centerTitle]
  final bool? centerTitle;

  /// See [AppBar.excludeHeaderSemantics]
  final bool excludeHeaderSemantics;

  /// See [AppBar.titleSpacing]
  final double? titleSpacing;

  /// See [AppBar.toolbarOpacity]
  final double toolbarOpacity;

  /// See [AppBar.bottomOpacity]
  final double bottomOpacity;

  @override
  final Size preferredSize;

  /// See [AppBar.toolbarHeight]
  final double? toolbarHeight;

  /// See [AppBar.leadingWidth]
  final double? leadingWidth;

  /// See [AppBar.toolbarTextStyle]
  final TextStyle? toolbarTextStyle;

  /// See [AppBar.titleTextStyle]
  final TextStyle? titleTextStyle;

  /// See [AppBar.systemOverlayStyle]
  final SystemUiOverlayStyle? systemOverlayStyle;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final actualBackgroundColor = backgroundColor ??
        theme.appBarTheme.backgroundColor ??
        (theme.colorScheme.brightness == Brightness.dark
            ? theme.colorScheme.surface
            : theme.colorScheme.primary);
    final actualSystemOverlayStyle = systemOverlayStyle ??
        context.theme.appBarTheme.systemOverlayStyle ??
        actualBackgroundColor.contrastSystemUiOverlayStyle;

    return Hero(
      tag: heroTag,
      flightShuttleBuilder: _flightShuttleBuilder,
      transitionOnUserGestures: true,
      child: AppBar(
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        title: title,
        actions: actions,
        flexibleSpace: flexibleSpace,
        bottom: bottom,
        elevation: elevation,
        shadowColor: shadowColor,
        shape: shape,
        backgroundColor: actualBackgroundColor,
        foregroundColor: foregroundColor,
        iconTheme: iconTheme,
        actionsIconTheme: actionsIconTheme,
        primary: primary,
        centerTitle: centerTitle,
        excludeHeaderSemantics: excludeHeaderSemantics,
        titleSpacing: titleSpacing,
        toolbarOpacity: toolbarOpacity,
        bottomOpacity: bottomOpacity,
        toolbarHeight: toolbarHeight,
        leadingWidth: leadingWidth,
        toolbarTextStyle: toolbarTextStyle,
        titleTextStyle: titleTextStyle,
        systemOverlayStyle: actualSystemOverlayStyle,
      ),
    );
  }

  Widget _flightShuttleBuilder(
    BuildContext _,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromContext,
    BuildContext toContext,
  ) {
    AppBar appBarFromContext(BuildContext context) {
      assert(context.widget is Hero);
      final hero = context.widget as Hero;
      assert(hero.child is AppBar);
      return hero.child as AppBar;
    }

    final fromState = EndState(fromContext, appBarFromContext(fromContext));
    final toState = EndState(toContext, appBarFromContext(toContext));

    return _AnimatedAppBar(
      parent: direction == HeroFlightDirection.push ? fromState : toState,
      child: direction == HeroFlightDirection.push ? toState : fromState,
      animation: animation,
    );
  }
}

class _AnimatedAppBar extends AnimatedWidget {
  _AnimatedAppBar({
    required this.parent,
    required this.child,
    required this.animation,
  })  : assert(
          parent.appBar.primary == child.appBar.primary,
          "Can't morph between a primary and a non-primary AppBar.",
        ),
        super(listenable: animation);

  final EndState parent;
  final EndState child;

  final Animation<double> animation;
  double get t => animation.value;

  @override
  Widget build(BuildContext context) {
    final state = MorphingState(parent: parent, child: child, t: t);

    return AppBar(
      leading: AnimatedLeading(state),
      // We manually determine the leadings to be able to animate between them.
      automaticallyImplyLeading: false,
      title: AnimatedTitle(state),
      actions: [AnimatedActions(state)],
      // TODO(JonasWanke): Animate `flexibleSpace`
      bottom: AnimatedBottom(state),
      elevation: state.elevation,
      shadowColor: state.shadowColor,
      shape: state.shape,
      backgroundColor: state.backgroundColor,
      foregroundColor: state.foregroundColor,
      iconTheme: state.iconTheme,
      actionsIconTheme: state.actionsIconTheme,
      // The value is the same for parent and child, so it doesn't matter which
      // one we use.
      primary: parent.appBar.primary,
      centerTitle: state.centerTitle,
      excludeHeaderSemantics: state.excludeHeaderSemantics,
      titleSpacing: state.titleSpacing,
      toolbarOpacity: state.toolbarOpacity,
      bottomOpacity: state.bottomOpacity,
      toolbarHeight: state.toolbarHeight,
      leadingWidth: state.leadingWidth,
      toolbarTextStyle: state.toolbarTextStyle,
      titleTextStyle: state.titleTextStyle,
      systemOverlayStyle: state.systemOverlayStyle,
    );
  }
}

abstract class AnimatedAppBarPart extends StatelessWidget {
  const AnimatedAppBarPart(this.state);

  final MorphingState state;

  EndState get parent => state.parent;
  EndState get child => state.child;
  double get t => state.t;
}

class AnimatedAppBarLayout<
        ParentDataType extends ContainerBoxParentData<RenderBox>>
    extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ParentDataType>,
        RenderBoxContainerDefaultsMixin<RenderBox, ParentDataType> {
  AnimatedAppBarLayout({
    double t = 0,
  }) : _t = t;

  double _t;
  double get t => _t;
  set t(double value) {
    if (_t == value) return;

    _t = value;
    markNeedsLayout();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
