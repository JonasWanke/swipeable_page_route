// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'go_router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $firstPageRoute,
  $secondPageRoute,
  $thirdPageRoute,
];

RouteBase get $firstPageRoute =>
    GoRouteData.$route(path: '/', factory: $FirstPageRouteExtension._fromState);

extension $FirstPageRouteExtension on FirstPageRoute {
  static FirstPageRoute _fromState(GoRouterState state) => FirstPageRoute();

  String get location => GoRouteData.$location('/');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $secondPageRoute => GoRouteData.$route(
  path: '/page2',
  factory: $SecondPageRouteExtension._fromState,
);

extension $SecondPageRouteExtension on SecondPageRoute {
  static SecondPageRoute _fromState(GoRouterState state) => SecondPageRoute();

  String get location => GoRouteData.$location('/page2');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $thirdPageRoute => GoRouteData.$route(
  path: '/page3',
  factory: $ThirdPageRouteExtension._fromState,
);

extension $ThirdPageRouteExtension on ThirdPageRoute {
  static ThirdPageRoute _fromState(GoRouterState state) => ThirdPageRoute();

  String get location => GoRouteData.$location('/page3');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
