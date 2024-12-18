# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- Template:
## NEW · 2024-xx-xx

### ⚠️ BREAKING CHANGES
### 🎉 New Features
### ⚡ Changes
### 🐛 Bug Fixes
### 📜 Documentation updates
### 🏗️ Refactoring
### 📦 Build & CI
-->

## 0.4.5 · 2024-12-18

### 🎉 New Features

- add `key` parameter to public widgets ([`53eccb1`](https://github.com/JonasWanke/swipeable_page_route/commit/53eccb10b21d00243e3e8f4fabce955ec9354a68))

### ⚡ Changes

- remove dependency on `flutter_color_models` ([`0b50afa`](https://github.com/JonasWanke/swipeable_page_route/commit/0b50afadcd55e21d3ce1660a3e5d0ef94d38bce0)), closes: [#79](https://github.com/JonasWanke/swipeable_page_route/issues/79)

### 📦 Build & CI

- upgrade to Flutter `^3.27.0-0`, Dart `^3.6.0-0` ([`c065d66`](https://github.com/JonasWanke/swipeable_page_route/commit/c065d662b86d10f150d58ca235b0dd25bf59421a))

## 0.4.4 · 2024-08-13

### 🎉 New Features

- animate `appBar.flexiblespace` ([#64](https://github.com/JonasWanke/swipeable_page_route/pull/64)), closes: [#63](https://github.com/JonasWanke/swipeable_page_route/issues/63). Thanks to [@proformance](https://github.com/proformance)

## 0.4.3 · 2024-05-21

### 🎉 New Features

- support Flutter ^3.22 ([#54](https://github.com/JonasWanke/swipeable_page_route/pull/54)), closes: [#52](https://github.com/JonasWanke/swipeable_page_route/issues/52). Thanks to [@1l0](https://github.com/1l0) and [@nimr77](https://github.com/nimr77)!
- add remaining properties from `AppBar` and `SliverAppBar` ([`b4ebae5`](https://github.com/JonasWanke/swipeable_page_route/commit/b4ebae5e1be5bf3bac64244bf2f185a56caa283d)), closes [#44](https://github.com/JonasWanke/swipeable_page_route/issues/44):
  - `morphingAppBar.scrolledUnderElevation`, `.notificationPredicate`, `.forceMaterialTransparency`, and `.clipBehavior`
  - `morphingSliverAppBar.scrolledUnderElevation`, `.surfaceTintColor`, `.forceMaterialTransparency`, and `.clipBehavior`

### 📦 Build & CI

- upgrade to Flutter `^3.22.0`, Dart `^3.4.0` ([`587a08a`](https://github.com/JonasWanke/swipeable_page_route/commit/587a08afda3ea13ec36cda092a252dbfef6ae250))

## 0.4.2 · 2024-01-20

### 🎉 New Features

- handle new `pageRoute.popDisposition` ([`9cee84a`](https://github.com/JonasWanke/swipeable_page_route/commit/9cee84a1c12e50f91c46c0a2487d155f5183fe6e))
- expose `swipeablePageRoute.`, `swipeablePage.reverseTransitionDuration` ([`4f6e398`](https://github.com/JonasWanke/swipeable_page_route/commit/4f6e398a17f117b058d7162e4a94ba23d1f1ce99)), closes [#38](https://github.com/JonasWanke/swipeable_page_route/issues/38)

### 📦 Build & CI

- upgrade to Flutter `>=3.16.0` ([`8dd381c`](https://github.com/JonasWanke/swipeable_page_route/commit/8dd381c1f046fc30490c5457e7fce3a73926e772)), closes [#36](https://github.com/JonasWanke/swipeable_page_route/issues/36)

## 0.4.1 · 2023-12-30

### 🎉 New Features

- add `SwipeablePage` and a [Go Router](https://pub.dev/packages/go_router) example ([`ea49c3e`](https://github.com/JonasWanke/swipeable_page_route/commit/ea49c3e598e6a5e506ead98b5220a578b2ff749b)), closes [#29](https://github.com/JonasWanke/swipeable_page_route/issues/29). Thanks to [@110](https://github.com/110), [@kamranbekirovyz](https://github.com/kamranbekirovyz), and [@gustavjohansen98](https://github.com/gustavjohansen98) for exploring this!
- expose `swipeablePageRoute.allowSnapshotting`, `.barrierDismissible` ([#35](https://github.com/JonasWanke/swipeable_page_route/pull/35)). Thanks to [@MagTuxGit](https://github.com/MagTuxGit)!

### ⚡ Changes

- interpolate colors in the [Oklab color space](https://bottosson.github.io/posts/oklab/) instead of HSV ([`65f2a5d`](https://github.com/JonasWanke/swipeable_page_route/commit/65f2a5d60b12ed127a99497e713f0257ad7b7c03))

### 🐛 Bug Fixes

- honor `themeData.useMaterial3` with different defaults compared to Material 2 ([`cc98d3f`](https://github.com/JonasWanke/swipeable_page_route/commit/cc98d3f3ea0539c1eeb8c013dc425d2443283ed7))

## 0.4.0 · 2023-05-30

### ⚠️ BREAKING CHANGES

- make `swipeablePageRoute.canOnlySwipeFromEdge`, `.backGestureDetectionWidth`, and `.backGestureDetectionStartOffset` mutable and change `SwipeablePageRoute.buildPageTransitions(…)`'s corresponding parameters to `ValueGetter`s ([`2ad8bfb`](https://github.com/JonasWanke/swipeable_page_route/commit/2ad8bfb986ff687b169930d762925c1fb4adbafd)), closes: [#27](https://github.com/JonasWanke/swipeable_page_route/issues/27)

### 🐛 Bug Fixes

- fix `MorphingAppBar`'s title text color during swipe ([`fb0466d`](https://github.com/JonasWanke/swipeable_page_route/commit/fb0466d4e37cda4e1b64383de6ea90d77644c547))

## 0.3.1 · 2023-05-16

### 📦 Build & CI

- upgrade to Flutter `>=3.10.0`, Dart `>=3.0.0 <4.0.0` ([`ff58ba7`](https://github.com/JonasWanke/swipeable_page_route/commit/ff58ba7c4f6d6f48c3945fb90031259b4d6b2999))
- update `black_hole_flutter` to `^1.0.3` ([`0f114e2`](https://github.com/JonasWanke/swipeable_page_route/commit/0f114e2a4f9de0af19d716fa0d3fd8c564990e13))

## 0.3.0 · 2023-01-24

### ⚠️ BREAKING CHANGES

- remove deprecated `appBar.`/`sliverAppBar.textTheme` ([`c0cb638`](https://github.com/JonasWanke/swipeable_page_route/commit/c0cb638b85025d3d9b30fac6c43bd547e8bb2614))

### 🐛 Bug Fixes

- use Flutter's update logic/fields for `AnimatedTitle`'s title style ([`341dc68`](https://github.com/JonasWanke/swipeable_page_route/commit/341dc687b56380fabe94143f3f99843c4f285673)), closes: [#21](https://github.com/JonasWanke/swipeable_page_route/issues/21)

### 📦 Build & CI

- upgrade to Flutter `>=3.3.0`, Dart `>=2.18.0 <3.0.0` ([`0ad5c9e`](https://github.com/JonasWanke/swipeable_page_route/commit/0ad5c9e7cd29a0b4c85df16219978f7eeaad9c95))
- update `black_hole_flutter` to `^1.0.0` ([`9a43d1b`](https://github.com/JonasWanke/swipeable_page_route/commit/9a43d1bc7a19d338950eba2d789953523418d20d))

## 0.2.6 · 2022-01-14

### 📜 Documentation updates

- add `SwipeablePageTransitionsBuilder` warning to README ([`cea522c`](https://github.com/JonasWanke/swipeable_page_route/commit/cea522c510e9d0830403efc9f42f987bc6d9912a))

## 0.2.5 · 2022-01-14

### 🎉 New Features

- add `SwipeablePageTransitionsBuilder` for usage with `PageTransitionsTheme`, closes: [#19](https://github.com/JonasWanke/swipeable_page_route/issues/19) ([`8a5e677`](https://github.com/JonasWanke/swipeable_page_route/commit/8a5e677e8758608b28b9fcfff4eda0d9b3b3a705))

### 📦 Build & CI

- remove dependency on the discontinued [<kbd>supercharged</kbd>](https://pub.dev/packages/supercharged) ([`9b0b5ac`](https://github.com/JonasWanke/swipeable_page_route/commit/9b0b5ac332cab3dc56065acdedf7672abd78ab69))

## 0.2.4 · 2021-10-30

### 🎉 New Features

- only intercept drag events in the swipeable direction ([#18](https://github.com/JonasWanke/swipeable_page_route/pull/18)). Thanks to [@NaikSoftware](https://github.com/NaikSoftware)!

## 0.2.3 · 2021-08-10

### 🎉 New Features

- add `swipeablePageRoute.transitionBuilder`, closes: [#16](https://github.com/JonasWanke/swipeable_page_route/issues/16)

## 0.2.2 · 2021-06-09

### 🎉 New Features

- add `swipeablePageRoute.backGestureDetectionStartOffset` ([#14](https://github.com/JonasWanke/swipeable_page_route/pull/14)), closes: [#13](https://github.com/JonasWanke/swipeable_page_route/issues/13). Thanks to [@zim32](https://github.com/zim32)!
- add `swipeablePageRoute.transitionDuration` ([#15](https://github.com/JonasWanke/swipeable_page_route/pull/15)). Thanks to [@zim32](https://github.com/zim32)!

## 0.2.1 · 2021-03-09

### 🎉 New Features

- make `swipeablePageRoute.canSwipe` mutable, closes: [#8](https://github.com/JonasWanke/swipeable_page_route/issues/8)
- add `buildContext.getSwipeablePageRoute<T>()`

## 0.2.0 · 2021-03-08

### ⚠️ BREAKING CHANGES

- migrate to null-safety
- `swipeablePageRoute.onlySwipeFromEdge` is now called `canOnlySwipeFromEdge`

### 🎉 New Features

- add `swipeablePageRoute.canSwipe`, closes: [#8](https://github.com/JonasWanke/swipeable_page_route/issues/8)
- add `swipeablePageRoute.backGestureWidth`

### ⚡ Changes

- `[Sliver-]MorphingAppBar`'s colors are interpolated using HSV

## 0.1.6 · 2020-12-14

### 🎉 New Features

- **example:** demonstrate `onlySwipeFromEdge` parameter

## 0.1.5 · 2020-10-20

### 🐛 Bug Fixes

- resolve theme only once to avoid looking up deactivated widget's ancestor
- keep brightness parameter during transition
- center app bar bottom widgets during animation

## 0.1.4 · 2020-08-09

### 📦 Build & CI

- update <kbd>dartx</kbd> to `^0.5.0`
- use stricter linting rules

## 0.1.3 · 2020-05-27

### 🎉 New Features

- **app_bar:** support non-opaque backgrounds ([#2](https://github.com/JonasWanke/swipeable_page_route/pull/2))

## 0.1.2 · 2020-05-11

### 🐛 Bug Fixes

- support Flutter v1.17.0

## 0.1.1 · 2020-04-30

### 📜 Documentation updates

- fix `MorphingSliverAppBar` naming in README

## 0.1.0 · 2020-04-30

Initial release 🎉
