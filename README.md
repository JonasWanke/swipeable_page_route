🔙 Swipe to navigate back and admire beautifully morphing widgets.

<img src="https://github.com/JonasWanke/swipeable_page_route/raw/main/doc/demo.gif?raw=true" width="400px" alt="swipeable_page_route demo" />

## [`SwipeablePageRoute`]

[`SwipeablePageRoute`] is a specialized [`CupertinoPageRoute`] that allows your users to go back by swiping anywhere on the current page. Use it instead of [`MaterialPageRoute`] or [`CupertinoPageRoute`]:

```dart
Navigator.of(context).push(SwipeablePageRoute(
  builder: (BuildContext context) => MyPageContent(),
));
```

If your page contains horizontally scrollable content, you can limit [`SwipeablePageRoute`] to only react on drags from the start (left in LTR, right in RTL) screen edge — just like [`CupertinoPageRoute`]:

```dart
Navigator.of(context).push(SwipeablePageRoute(
  onlySwipeFromEdge: true,
  builder: (BuildContext context) => MyHorizontallyScrollablePageContent(),
));
```

You can get the [`SwipeablePageRoute`] wrapping your current page using `context.getSwipeablePageRoute<T>()`.

> To use swipeable pages with a [`PageTransitionsTheme`], use [`SwipeablePageTransitionsBuilder`].

## [`MorphingAppBar`] & [`MorphingSliverAppBar`]

As you can see in the demo above, there's a beautiful animation happening to the AppBar. That's a [`MorphingAppBar`]!

You can construct [`MorphingAppBar`] (corresponds to `AppBar`) and [`MorphingSliverAppBar`] (corresponds to `SliverAppBar`) just like the originals:

```dart
MorphingAppBar(
  backgroundColor: Colors.green,
  title: Text('My Page'),
  actions: [
    IconButton(
      key: ValueKey('play'),
      icon: Icon(Icons.play_arrow),
      onPressed: () {},
    ),
    IconButton(
      key: ValueKey('favorite'),
      icon: Icon(Icons.favorite),
      onPressed: () {},
    ),
    PopupMenuButton<void>(
      key: ValueKey('overflow'),
      itemBuilder: (context) => [
        PopupMenuItem<void>(child: Text('Overflow action 1')),
        PopupMenuItem<void>(child: Text('Overflow action 2')),
      ],
    ),
  ],
  bottom: TabBar(tabs: [
    Tab(text: 'Tab 1'),
    Tab(text: 'Tab 2'),
    Tab(text: 'Tab 3'),
  ]),
)
```

Both [`MorphingAppBar`]s internally use [`Hero`]s, so if you're not navigating directly inside a `MaterialApp`, you have to add a [`HeroController`] to your `Navigator`:

```dart
Navigator(
  observers: [HeroController()],
  onGenerateRoute: // ...
)
```

To animate additions, removals, and constants in your `AppBar`s `actions`, we compare them using [`Widget.canUpdate(Widget old, Widget new)`]. It compares `Widget`s based on their type and `key`, so it's recommended to give every action `Widget` a key (that you reuse across pages) for correct animations.

<!-- Flutter -->
[`CupertinoPageRoute`]: https://api.flutter.dev/flutter/cupertino/CupertinoPageRoute-class.html
[`Hero`]: https://api.flutter.dev/flutter/widgets/Hero-class.html
[`HeroController`]: https://api.flutter.dev/flutter/widgets/HeroController-class.html
[`MaterialPageRoute`]: https://api.flutter.dev/flutter/material/MaterialPageRoute-class.html
[`PageTransitionsTheme`]: https://api.flutter.dev/flutter/material/PageTransitionsTheme-class.html
[`Widget.canUpdate(Widget old, Widget new)`]: https://api.flutter.dev/flutter/widgets/Widget/canUpdate.html
<!-- swipeable_page_route -->
[`MorphingAppBar`]: https://pub.dev/documentation/swipeable_page_route/latest/swipeable_page_route/MorphingAppBar-class.html
[`MorphingSliverAppBar`]: https://pub.dev/documentation/swipeable_page_route/latest/swipeable_page_route/MorphingSliverAppBar-class.html
[`SwipeablePageRoute`]: https://pub.dev/documentation/swipeable_page_route/latest/swipeable_page_route/SwipeablePageRoute-class.html
[`SwipeablePageTransitionsBuilder`]: https://pub.dev/documentation/swipeable_page_route/latest/swipeable_page_route/SwipeablePageTransitionsBuilder-class.html
