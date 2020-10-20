import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'actions.dart';
import 'bottom.dart';
import 'leading.dart';
import 'state.dart';
import 'title.dart';

const kHalfInterval = Interval(0.5, 1);

/// An adapted version of [AppBar] that morphs while navigating.
class MorphingAppBar extends StatelessWidget implements PreferredSizeWidget {
  MorphingAppBar({
    Key key,
    this.heroTag = 'MorphingAppBar',
    this.leading,
    this.automaticallyImplyLeading = true,
    this.title,
    this.actions,
    this.flexibleSpace,
    this.bottom,
    this.elevation,
    this.shape,
    this.backgroundColor,
    this.brightness,
    this.iconTheme,
    this.actionsIconTheme,
    this.textTheme,
    this.primary = true,
    this.centerTitle,
    this.titleSpacing = NavigationToolbar.kMiddleSpacing,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
  })  : assert(heroTag != null),
        assert(automaticallyImplyLeading != null),
        assert(elevation == null || elevation >= 0.0),
        assert(primary != null),
        assert(titleSpacing != null),
        assert(toolbarOpacity != null),
        assert(bottomOpacity != null),
        preferredSize = Size.fromHeight(
            kToolbarHeight + (bottom?.preferredSize?.height ?? 0.0)),
        super(key: key);

  /// Tag used for the internally created [Hero] widget.
  final Object heroTag;

  /// See [AppBar.leading]
  final Widget leading;

  /// See [AppBar.automaticallyImplyLeading]
  final bool automaticallyImplyLeading;

  /// See [AppBar.title]
  final Widget title;

  /// See [AppBar.actions]
  final List<Widget> actions;

  /// See [AppBar.flexibleSpace]
  final Widget flexibleSpace;

  /// See [AppBar.bottom]
  final PreferredSizeWidget bottom;

  /// See [AppBar.elevation]
  final double elevation;

  /// See [AppBar.shape]
  final ShapeBorder shape;

  /// See [AppBar.backgroundColor]
  final Color backgroundColor;

  /// See [AppBar.brightness]
  final Brightness brightness;

  /// See [AppBar.iconTheme]
  final IconThemeData iconTheme;

  /// See [AppBar.actionsIconTheme]
  final IconThemeData actionsIconTheme;

  /// See [AppBar.textTheme]
  final TextTheme textTheme;

  /// See [AppBar.primary]
  final bool primary;

  /// See [AppBar.centerTitle]
  final bool centerTitle;

  /// See [AppBar.titleSpacing]
  final double titleSpacing;

  /// See [AppBar.toolbarOpacity]
  final double toolbarOpacity;

  /// See [AppBar.bottomOpacity]
  final double bottomOpacity;

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
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
        shape: shape,
        backgroundColor: backgroundColor,
        brightness: brightness,
        iconTheme: iconTheme,
        actionsIconTheme: actionsIconTheme,
        textTheme: textTheme,
        primary: primary,
        centerTitle: centerTitle,
        titleSpacing: titleSpacing,
        toolbarOpacity: toolbarOpacity,
        bottomOpacity: bottomOpacity,
      ),
    );
  }

  Widget _flightShuttleBuilder(
    BuildContext context,
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
    @required this.parent,
    @required this.child,
    @required this.animation,
  })  : assert(parent != null),
        assert(child != null),
        assert(
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
      bottom: AnimatedBottom(state),
      elevation:
          lerpDouble(_resolveElevation(parent), _resolveElevation(child), t),
      shape: ShapeBorder.lerp(parent.appBar.shape, child.appBar.shape, t),
      brightness: state.brightness,
      backgroundColor: state.backgroundColor,
      // iconTheme & actionsIconTheme are applied in AnimatedLeading &
      // AnimatedActions directly to differentiate between parent & child.
      // Value is the same for parent and child, so it doesn't matter which one
      // we use.
      primary: parent.appBar.primary,
    );
  }

  double _resolveElevation(EndState state) =>
      state.appBar.elevation ?? state.appBarTheme.elevation ?? 4;
}

abstract class AnimatedAppBarPart extends StatelessWidget {
  const AnimatedAppBarPart(this.state) : assert(state != null);

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
  })  : assert(t != null),
        _t = t;

  double _t;
  double get t => _t;
  set t(double value) {
    assert(value != null);
    if (_t == value) {
      return;
    }

    _t = value;
    markNeedsLayout();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
