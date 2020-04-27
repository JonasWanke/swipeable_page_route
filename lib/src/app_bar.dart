import 'dart:math' as math;
import 'dart:ui';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';

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

    final fromState = _EndState(fromContext, appBarFromContext(fromContext));
    final toState = _EndState(toContext, appBarFromContext(toContext));

    return _AnimatedAppBar(
      parent: direction == HeroFlightDirection.push ? fromState : toState,
      child: direction == HeroFlightDirection.push ? toState : fromState,
      animation: animation,
    );
  }
}

class _AnimatedAppBar extends AnimatedWidget {
  const _AnimatedAppBar({
    @required this.parent,
    @required this.child,
    @required this.animation,
  })  : assert(parent != null),
        assert(child != null),
        super(listenable: animation);

  final _EndState parent;
  final _EndState child;

  final Animation<double> animation;
  double get t => animation.value;

  @override
  Widget build(BuildContext context) {
    final state = _State(parent: parent, child: child, t: t);

    return AppBar(
      leading: _AnimatedLeading(state),
      // We manually determine the leadings to be able to animate between them.
      automaticallyImplyLeading: false,
      bottom: _AnimatedBottom(state),
      elevation: lerpDouble(parent.elevation, child.elevation, t),
      shape: ShapeBorder.lerp(parent.appBar.shape, child.appBar.shape, t),
      backgroundColor: state.backgroundColor,
    );
  }
}

class _AnimatedLeading extends _AnimatedAppBarPart {
  const _AnimatedLeading(_State state) : super(state);

  @override
  Widget build(BuildContext context) {
    final parentLeading = parent.leading;
    final childLeading = child.leading;

    if (parentLeading is _DrawerButton && childLeading is _DrawerButton) {
      return parentLeading;
    }
    if (parentLeading is CloseButton && childLeading is CloseButton) {
      return parentLeading;
    }
    if (parentLeading is BackButton && childLeading is BackButton) {
      // TODO: color
      return parentLeading;
    }

    return Stack(
      children: <Widget>[
        if (parentLeading != null)
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(lerpDouble(0, -kToolbarHeight, t), 0),
              child: Opacity(
                opacity: 1 - t,
                child: parentLeading,
              ),
            ),
          ),
        if (childLeading != null)
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(lerpDouble(kToolbarHeight, 0, t), 0),
              child: Opacity(
                opacity: t,
                child: childLeading,
              ),
            ),
          ),
      ],
    );
  }
}

class _DrawerButton extends StatelessWidget {
  const _DrawerButton();

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return IconButton(
      icon: Icon(Icons.menu),
      onPressed: context.scaffold.openDrawer,
      tooltip: context.materialLocalizations.openAppDrawerTooltip,
    );
  }
}

class _AnimatedBottom extends _AnimatedAppBarPart
    implements PreferredSizeWidget {
  const _AnimatedBottom(_State state) : super(state);

  double get preferredHeight =>
      lerpDouble(parent.bottomPreferredHeight, child.bottomPreferredHeight, t);
  @override
  Size get preferredSize => Size.fromHeight(preferredHeight);

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

abstract class _AnimatedAppBarPart extends StatelessWidget {
  const _AnimatedAppBarPart(this.state) : assert(state != null);

  final _State state;

  _EndState get parent => state.parent;
  _EndState get child => state.child;
  double get t => state.t;
}

@immutable
class _State {
  const _State({
    @required this.parent,
    @required this.child,
    @required this.t,
  })  : assert(parent != null),
        assert(child != null),
        assert(t != null);

  final _EndState parent;
  final _EndState child;
  final double t;

  Color get backgroundColor {
    assert(parent.backgroundColor.isOpaque);
    assert(child.backgroundColor.isOpaque);

    return Color.lerp(parent.backgroundColor, child.backgroundColor, t);
  }
}

@immutable
class _EndState {
  const _EndState(this.context, this.appBar)
      : assert(context != null),
        assert(appBar != null);

  final BuildContext context;
  final AppBar appBar;

  ThemeData get theme => context.theme;
  AppBarTheme get appBarTheme => theme.appBarTheme;

  Widget get leading {
    if (appBar.leading != null || !appBar.automaticallyImplyLeading) {
      return appBar.leading;
    }

    if (context.scaffoldOrNull?.hasDrawer ?? false) {
      return _DrawerButton();
    } else {
      final parentRoute = context.modalRoute;
      if (parentRoute?.canPop ?? false) {
        return parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog
            ? CloseButton()
            : BackButton();
      }
    }
    return null;
  }

  double get bottomPreferredHeight => appBar.bottom?.preferredSize?.height ?? 0;
  double get elevation => appBar.elevation ?? appBarTheme.elevation ?? 4;
  Color get backgroundColor =>
      appBar.backgroundColor ?? appBarTheme.color ?? theme.primaryColor;
}
