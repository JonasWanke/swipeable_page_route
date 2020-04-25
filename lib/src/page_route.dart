import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:flutter/animation.dart' show Curves;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// This is a stripped-down implementation of [CupertinoPageRoute] that allows
// for swiping back anywhere on the page unless onlySwipeFromEdge is true.

const double _kBackGestureWidth = 48;
const double _kMinFlingVelocity = 1; // Screen widths per second.

// An eyeballed value for the maximum time it takes for a page to animate forward
// if the user releases a page mid swipe.
const int _kMaxDroppedSwipePageForwardAnimationTime = 800; // Milliseconds.

// The maximum time for a page to get reset to it's original position if the
// user releases a page mid swipe.
const int _kMaxPageBackAnimationTime = 300; // Milliseconds.

// Offset from offscreen to the right to fully on screen.
final Animatable<Offset> _kRightMiddleTween = Tween<Offset>(
  begin: Offset(1, 0),
  end: Offset.zero,
);

// Offset from fully on screen to 1/3 offscreen to the left.
final Animatable<Offset> _kMiddleLeftTween = Tween<Offset>(
  begin: Offset.zero,
  end: Offset(-1.0 / 3, 0),
);

class SwipeablePageRoute<T> extends PageRoute<T> {
  SwipeablePageRoute({
    this.onlySwipeFromEdge = false,
    @required this.builder,
    RouteSettings settings,
  })  : assert(onlySwipeFromEdge != null),
        assert(builder != null),
        assert(opaque),
        super(settings: settings, fullscreenDialog: false);

  final bool onlySwipeFromEdge;

  /// Builds the primary contents of the route.
  final WidgetBuilder builder;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 400);

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) =>
      previousRoute is SwipeablePageRoute;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) =>
      nextRoute is SwipeablePageRoute;

  static bool isPopGestureInProgress(PageRoute<dynamic> route) =>
      route.navigator.userGestureInProgress;

  bool get popGestureInProgress => isPopGestureInProgress(this);

  bool get popGestureEnabled => _isPopGestureEnabled(this);

  static bool _isPopGestureEnabled<T>(PageRoute<T> route) {
    // If there's nothing to go back to, then obviously we don't support the
    // back gesture.
    if (route.isFirst) {
      return false;
    }

    // If we're in an animation already, we cannot be manually swiped.
    if (route.animation.status != AnimationStatus.completed) {
      return false;
    }

    // If we're being popped into, we also cannot be swiped until the pop above
    // it completes. This translates to our secondary animation being
    // dismissed.
    if (route.secondaryAnimation.status != AnimationStatus.dismissed) {
      return false;
    }

    // If we're in a gesture already, we cannot start another.
    if (isPopGestureInProgress(route)) {
      return false;
    }

    // Looks like a back gesture would be welcome!
    return true;
  }

  @override
  Widget buildPage(
      BuildContext context, Animation<double> _, Animation<double> __) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: builder(context),
    );
  }

  // Called by _FancyBackGestureDetector when a pop ("back") drag start
  // gesture is detected. The returned controller handles all of the subsequent
  // drag events.
  static _FancyBackGestureController<T> _startPopGesture<T>(
      PageRoute<T> route) {
    assert(_isPopGestureEnabled(route));

    return _FancyBackGestureController<T>(
      navigator: route.navigator,
      controller: route.controller, // protected access
    );
  }

  static Widget buildPageTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      FancyPageTransition(
        primaryRouteAnimation: animation,
        secondaryRouteAnimation: secondaryAnimation,
        // Check if the route has an animation that's currently participating
        // in a back swipe gesture.
        // In the middle of a back gesture drag, let the transition be linear to
        // match finger motions.
        linearTransition: isPopGestureInProgress(route),
        child: _FancyBackGestureDetector<T>(
          onlySwipeFromEdge: (route as SwipeablePageRoute).onlySwipeFromEdge,
          enabledCallback: () => _isPopGestureEnabled<T>(route),
          onStartPopGesture: () => _startPopGesture<T>(route),
          child: child,
        ),
      );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return buildPageTransitions<T>(
        this, context, animation, secondaryAnimation, child);
  }
}

class FancyPageTransition extends StatelessWidget {
  FancyPageTransition({
    Key key,
    @required Animation<double> primaryRouteAnimation,
    @required Animation<double> secondaryRouteAnimation,
    @required this.child,
    @required bool linearTransition,
  })  : assert(linearTransition != null),
        _primaryPositionAnimation = (linearTransition
                ? primaryRouteAnimation
                : CurvedAnimation(
                    parent: primaryRouteAnimation,
                    curve: Curves.linearToEaseOut,
                    reverseCurve: Curves.easeInToLinear,
                  ))
            .drive(_kRightMiddleTween),
        _secondaryPositionAnimation = (linearTransition
                ? secondaryRouteAnimation
                : CurvedAnimation(
                    parent: secondaryRouteAnimation,
                    curve: Curves.linearToEaseOut,
                    reverseCurve: Curves.easeInToLinear,
                  ))
            .drive(_kMiddleLeftTween),
        super(key: key);

  // When this page is coming in to cover another page.
  final Animation<Offset> _primaryPositionAnimation;
  // When this page is becoming covered by another page.
  final Animation<Offset> _secondaryPositionAnimation;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    final textDirection = Directionality.of(context);
    return SlideTransition(
      position: _secondaryPositionAnimation,
      textDirection: textDirection,
      transformHitTests: false,
      child: SlideTransition(
        position: _primaryPositionAnimation,
        textDirection: textDirection,
        child: Material(elevation: 12, child: child),
      ),
    );
  }
}

/// This is the widget side of [_FancyBackGestureController].
///
/// This widget provides a gesture recognizer which, when it determines the
/// route can be closed with a back gesture, creates the controller and
/// feeds it the input from the gesture recognizer.
///
/// The gesture data is converted from absolute coordinates to logical
/// coordinates by this widget.
///
/// The type `T` specifies the return type of the route with which this gesture
/// detector is associated.
class _FancyBackGestureDetector<T> extends StatefulWidget {
  const _FancyBackGestureDetector({
    Key key,
    this.onlySwipeFromEdge = false,
    @required this.enabledCallback,
    @required this.onStartPopGesture,
    @required this.child,
  })  : assert(onlySwipeFromEdge != null),
        assert(enabledCallback != null),
        assert(onStartPopGesture != null),
        assert(child != null),
        super(key: key);

  final bool onlySwipeFromEdge;

  final Widget child;

  final ValueGetter<bool> enabledCallback;

  final ValueGetter<_FancyBackGestureController<T>> onStartPopGesture;

  @override
  _FancyBackGestureDetectorState<T> createState() =>
      _FancyBackGestureDetectorState<T>();
}

class _FancyBackGestureDetectorState<T>
    extends State<_FancyBackGestureDetector<T>> {
  _FancyBackGestureController<T> _backGestureController;

  HorizontalDragGestureRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = HorizontalDragGestureRecognizer(debugOwner: this)
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    assert(mounted);
    assert(_backGestureController == null);
    _backGestureController = widget.onStartPopGesture();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    assert(mounted);
    assert(_backGestureController != null);
    _backGestureController.dragUpdate(
        _convertToLogical(details.primaryDelta / context.size.width));
  }

  void _handleDragEnd(DragEndDetails details) {
    assert(mounted);
    assert(_backGestureController != null);
    _backGestureController.dragEnd(_convertToLogical(
        details.velocity.pixelsPerSecond.dx / context.size.width));
    _backGestureController = null;
  }

  void _handleDragCancel() {
    assert(mounted);
    // This can be called even if start is not called, paired with the "down" event
    // that we don't consider here.
    _backGestureController?.dragEnd(0);
    _backGestureController = null;
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (widget.enabledCallback()) {
      _recognizer.addPointer(event);
    }
  }

  double _convertToLogical(double value) {
    switch (Directionality.of(context)) {
      case TextDirection.rtl:
        return -value;
      case TextDirection.ltr:
        return value;
      default:
        throw StateError('No Directionality ancestor above $this.');
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    // For devices with notches, the drag area needs to be larger on the side
    // that has the notch.
    var dragAreaWidth = Directionality.of(context) == TextDirection.ltr
        ? MediaQuery.of(context).padding.left
        : MediaQuery.of(context).padding.right;
    dragAreaWidth = max(dragAreaWidth, _kBackGestureWidth);

    final listener = Listener(
      onPointerDown: _handlePointerDown,
      behavior: HitTestBehavior.translucent,
    );
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        widget.child,
        if (widget.onlySwipeFromEdge)
          PositionedDirectional(
            start: 0,
            width: dragAreaWidth,
            top: 0,
            bottom: 0,
            child: listener,
          )
        else
          Positioned.fill(child: listener),
      ],
    );
  }
}

class AllowMultipleGestureRecognizer extends HorizontalDragGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }

  @override
  void resolve(GestureDisposition disposition) {
    if (disposition == GestureDisposition.rejected) {
      super.resolve(disposition);
    }
  }

  // @override
  // void handleEvent(PointerEvent event) {
  //   assert(_state != _DragState.ready);
  //   if (!event.synthesized
  //       && (event is PointerDownEvent || event is PointerMoveEvent)) {
  //     final VelocityTracker tracker = _velocityTrackers[event.pointer];
  //     assert(tracker != null);
  //     tracker.addPosition(event.timeStamp, event.localPosition);
  //   }

  //   if (event is PointerMoveEvent) {
  //     if (event.buttons != _initialButtons) {
  //       _giveUpPointer(event.pointer);
  //       return;
  //     }
  //     if (_state == _DragState.accepted) {
  //       _checkUpdate(
  //         sourceTimeStamp: event.timeStamp,
  //         delta: _getDeltaForDetails(event.localDelta),
  //         primaryDelta: _getPrimaryValueFromOffset(event.localDelta),
  //         globalPosition: event.position,
  //         localPosition: event.localPosition,
  //       );
  //     } else {
  //       _pendingDragOffset += OffsetPair(local: event.localDelta, global: event.delta);
  //       _lastPendingEventTimestamp = event.timeStamp;
  //       _lastTransform = event.transform;
  //       final Offset movedLocally = _getDeltaForDetails(event.localDelta);
  //       final Matrix4 localToGlobalTransform = event.transform == null ? null : Matrix4.tryInvert(event.transform);
  //       _globalDistanceMoved += PointerEvent.transformDeltaViaPositions(
  //         transform: localToGlobalTransform,
  //         untransformedDelta: movedLocally,
  //         untransformedEndPosition: event.localPosition,
  //       ).distance * (_getPrimaryValueFromOffset(movedLocally) ?? 1).sign;
  //       if (_hasSufficientGlobalDistanceToAccept)
  //         resolve(GestureDisposition.accepted);
  //     }
  //   }
  //   if (event is PointerUpEvent || event is PointerCancelEvent) {
  //     _giveUpPointer(
  //       event.pointer,
  //       reject: event is PointerCancelEvent || _state ==_DragState.possible,
  //     );
  //   }
  // }
}

class _FancyBackGestureController<T> {
  _FancyBackGestureController({
    @required this.navigator,
    @required this.controller,
  })  : assert(navigator != null),
        assert(controller != null) {
    navigator.didStartUserGesture();
  }

  final AnimationController controller;
  final NavigatorState navigator;

  /// The drag gesture has changed by [delta]. The total range of the drag
  /// should be 0.0 to 1.0.
  void dragUpdate(double delta) {
    controller.value = (controller.value - delta).clamp(0.0001, 0.9999);
  }

  /// The drag gesture has ended with a horizontal motion of [velocity] as a
  /// fraction of screen width per second.
  void dragEnd(double velocity) {
    // Fling in the appropriate direction.
    // AnimationController.fling is guaranteed to take at least one frame.
    const Curve animationCurve = Curves.fastLinearToSlowEaseIn;
    bool animateForward;

    // If the user releases the page before mid screen with sufficient velocity,
    // or after mid screen, we should animate the page out. Otherwise, the page
    // should be animated back in.
    if (velocity.abs() >= _kMinFlingVelocity) {
      animateForward = velocity <= 0;
    } else {
      animateForward = controller.value > 0.5;
    }

    if (animateForward) {
      // The closer the panel is to dismissing, the shorter the animation is.
      // We want to cap the animation time, but we want to use a linear curve
      // to determine it.
      final droppedPageForwardAnimationTime = min(
        lerpDouble(
                _kMaxDroppedSwipePageForwardAnimationTime, 0, controller.value)
            .floor(),
        _kMaxPageBackAnimationTime,
      );
      controller.animateTo(
        1,
        duration: Duration(milliseconds: droppedPageForwardAnimationTime),
        curve: animationCurve,
      );
    } else {
      // This route is destined to pop at this point. Reuse navigator's pop.
      navigator.pop();

      // The popping may have finished inline if already at the target destination.
      if (controller.isAnimating) {
        // Otherwise, use a custom popping animation duration and curve.
        final droppedPageBackAnimationTime = lerpDouble(
                0, _kMaxDroppedSwipePageForwardAnimationTime, controller.value)
            .floor();
        controller.animateBack(
          0,
          duration: Duration(milliseconds: droppedPageBackAnimationTime),
          curve: animationCurve,
        );
      }
    }

    if (controller.isAnimating) {
      // Keep the userGestureInProgress in true state so we don't change the
      // curve of the page transition mid-flight since FancyPageTransition
      // depends on userGestureInProgress.
      AnimationStatusListener animationStatusCallback;
      animationStatusCallback = (status) {
        navigator.didStopUserGesture();
        controller.removeStatusListener(animationStatusCallback);
      };
      controller.addStatusListener(animationStatusCallback);
    } else {
      navigator.didStopUserGesture();
    }
  }
}
