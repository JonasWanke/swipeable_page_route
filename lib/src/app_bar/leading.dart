import 'dart:ui';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'app_bar.dart';
import 'state.dart';

class AnimatedLeading extends AnimatedAppBarPart {
  const AnimatedLeading(MorphingState state) : super(state);

  @override
  Widget build(BuildContext context) {
    final parentLeading = _resolveLeading(parent);
    final childLeading = _resolveLeading(child);

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

  Widget _resolveLeading(EndState state) {
    if (state.appBar.leading != null ||
        !state.appBar.automaticallyImplyLeading) {
      return state.appBar.leading;
    }

    if (state.context.scaffoldOrNull?.hasDrawer ?? false) {
      return _DrawerButton();
    } else {
      final parentRoute = state.context.modalRoute;
      if (parentRoute?.canPop ?? false) {
        return parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog
            ? CloseButton()
            : BackButton();
      }
    }
    return null;
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
