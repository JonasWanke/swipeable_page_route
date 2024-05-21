import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'main.dart';

part 'go_router.g.dart';

final goRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => SwipeablePage(
        builder: (context) => const FirstPage(),
      ),
    ),
    GoRoute(
      path: '/page2',
      pageBuilder: (context, state) => SwipeablePage(
        builder: (context) => const SecondPage(),
      ),
    ),
    GoRoute(
      path: '/page3',
      pageBuilder: (context, state) => SwipeablePage(
        builder: (context) => const ThirdPage(),
      ),
    ),
  ],
);

final goRouterBuilder = GoRouter(routes: $appRoutes);

@TypedGoRoute<FirstPageRoute>(path: '/')
@immutable
class FirstPageRoute extends GoRouteData {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      SwipeablePage(builder: (context) => const FirstPage());
}

@TypedGoRoute<SecondPageRoute>(path: '/page2')
@immutable
class SecondPageRoute extends GoRouteData {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      SwipeablePage(builder: (context) => const SecondPage());
}

@TypedGoRoute<ThirdPageRoute>(path: '/page3')
@immutable
class ThirdPageRoute extends GoRouteData {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      SwipeablePage(builder: (context) => const ThirdPage());
}
