import 'dart:ui';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';

import 'app_bar.dart';

class AnimatedLeading extends AnimatedAppBarPart {
  const AnimatedLeading(super.state);

  static const _halfInterval = Interval(0.5, 1);

  @override
  Widget build(BuildContext context) {
    if (parent.leading == null && child.leading == null) {
      return const SizedBox();
    }

    final canUpdate = parent.leading != null &&
        child.leading != null &&
        Widget.canUpdate(parent.leading!, child.leading!);

    return Stack(
      children: <Widget>[
        if (parent.leading != null)
          Positioned.fill(
            child: Transform.translate(
              offset: canUpdate
                  ? Offset.zero
                  : Offset(lerpDouble(0, -kToolbarHeight, t)!, 0),
              child: Opacity(
                opacity: canUpdate ? 1 - t : _halfInterval.transform(1 - t),
                child: IconTheme.merge(
                  data: parent.overallIconTheme,
                  child: parent.leading!,
                ),
              ),
            ),
          ),
        if (child.leading != null)
          Positioned.fill(
            child: Transform.translate(
              offset: canUpdate
                  ? Offset.zero
                  : Offset(lerpDouble(kToolbarHeight, 0, t)!, 0),
              child: Opacity(
                opacity: canUpdate ? t : _halfInterval.transform(t),
                child: IconTheme.merge(
                  data: child.overallIconTheme,
                  child: child.leading!,
                ),
              ),
            ),
          ),
      ],
    );
  }

  static Widget? resolveLeading(BuildContext context, AppBar appBar) {
    if (appBar.leading != null || !appBar.automaticallyImplyLeading) {
      return appBar.leading;
    }

    if (context.scaffoldOrNull?.hasDrawer ?? false) {
      return const _DrawerButton();
    } else {
      final parentRoute = context.getModalRoute<dynamic>();
      if (parentRoute?.canPop ?? false) {
        return parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog
            ? const CloseButton()
            : const BackButton();
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
      icon: const Icon(Icons.menu),
      onPressed: context.scaffold.openDrawer,
      tooltip: context.materialLocalizations.openAppDrawerTooltip,
    );
  }
}
