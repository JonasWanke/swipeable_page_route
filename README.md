🔙 Swipe to navigate back and admire beautifully morphing widgets.

<img src="https://github.com/JonasWanke/swipeable_page_route/raw/master/doc/demo.gif?raw=true" width="400px" alt="swipeable_page_route demo" />


## [`SwipeablePageRoute`]

To allow your users to go back by swiping anywhere on the current page, use [`SwipeablePageRoute`] instead of [`MaterialPageRoute`] or [`CupertinoPageRoute`]:

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


## [`MorphingAppBar`] & [`SliverMorphingAppBar`]

As you can see in the demo above, there's a beautiful animation happening to the AppBar. That's a [`MorphingAppBar`]!

You can construct [`MorphingAppBar`] (corresponds to `AppBar`) and [`SliverMorphingAppBar`] (corresponds to `SliverAppBar`) just like the originals:

```dart
MorphingAppBar(
  backgroundColor: Colors.green,
  title: Text('My Page'),
  actions: <Widget>[
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
      itemBuilder: (context) {
        return [
          PopupMenuItem<void>(child: Text('Overflow action 1')),
          PopupMenuItem<void>(child: Text('Overflow action 2')),
        ];
      },
    ),
  ],
  bottom: TabBar(
    tabs: <Widget>[
      Tab(text: 'Tab 1'),
      Tab(text: 'Tab 2'),
      Tab(text: 'Tab 3'),
    ],
  ),
)
```

Both [`MorphingAppBar`]s internally use [`Hero`]s, so if you're not navigating directly inside a `MaterialApp`, you have to add a [`HeroController`] to your `Navigator`:

```dart
Navigator(
  observers: [
    HeroController(),
  ],
  onGenerateRoute: // ...
)
```

To animate additions, removals and constants in your `AppBar`s `actions`, we compare them using [`Widget.canUpdate(Widget old, Widget new)`]. It compares `Widget`s based on their type and `key`, so it's recommended to give every action `Widget` a key (that will be reused across pages) for correct animations.



<!-- Flutter -->
[`CupertinoPageRoute`]: https://api.flutter.dev/flutter/cupertino/CupertinoPageRoute-class.html
[`Hero`]: https://api.flutter.dev/flutter/widgets/Hero-class.html
[`HeroController`]: https://api.flutter.dev/flutter/widgets/HeroController-class.html
[`MaterialPageRoute`]: https://api.flutter.dev/flutter/material/MaterialPageRoute-class.html
[`Widget.canUpdate(Widget old, Widget new)`]: https://api.flutter.dev/flutter/widgets/Widget/canUpdate.html
<!-- swipeable_page_route -->
[`MorphingAppBar`]: https://pub.dev/documentation/swipeable_page_route/latest/swipeable_page_route/MorphingAppBar-class.html
[`SliverMorphingAppBar`]: https://pub.dev/documentation/swipeable_page_route/latest/swipeable_page_route/SliverMorphingAppBar-class.html
[`SwipeablePageRoute`]: https://pub.dev/documentation/swipeable_page_route/latest/swipeable_page_route/SwipeablePageRoute-class.html
