// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'go_router.dart';

void main() => runApp(MyApp());

enum NavigationMode {
  navigator,
  goRouter,
  goRouterBuilder;

  /// Change this value to switch between the navigation modes.
  static const current = NavigationMode.navigator;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const title = '🔙 swipeable_page_route example';
    final theme = ThemeData(
      appBarTheme: const AppBarTheme(
        color: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );

    return switch (NavigationMode.current) {
      NavigationMode.navigator => MaterialApp(
          title: title,
          theme: theme,
          home: const FirstPage(),
        ),
      NavigationMode.goRouter => MaterialApp.router(
          title: title,
          theme: theme,
          routerConfig: goRouter,
        ),
      NavigationMode.goRouterBuilder => MaterialApp.router(
          title: title,
          theme: theme,
          routerConfig: goRouterBuilder,
        ),
    };
  }
}

class FirstPage extends StatelessWidget {
  const FirstPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MorphingAppBar(
        leading: const Icon(Icons.menu),
        title: const Text('🔙 swipeable_page_route example'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF005C9D), Color(0xff0078C1), Color(0xFF0995E0)],
            ),
          ),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async => _pushSecondPage(context),
          child: const Text('Open page 2'),
        ),
      ),
    );
  }

  Future<void> _pushSecondPage(BuildContext context) async {
    return switch (NavigationMode.current) {
      NavigationMode.navigator => Navigator.of(context)
          .push<void>(SwipeablePageRoute(builder: (_) => const SecondPage())),
      NavigationMode.goRouter => GoRouter.of(context).push<void>('/page2'),
      NavigationMode.goRouterBuilder => SecondPageRoute().push(context),
    };
  }
}

class SecondPage extends StatefulWidget {
  const SecondPage();

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    // Gets the `SwipeablePageRoute` wrapping the current page.
    final pageRoute = context.getSwipeablePageRoute<void>()!;

    return Scaffold(
      appBar: MorphingAppBar(
        title: const Text('Page 2'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF5733), Color(0xFFC70039), Color(0xFF900C3F)],
            ),
          ),
        ),
        actions: [
          IconButton(
            key: const ValueKey('check'),
            icon: const Icon(Icons.check),
            onPressed: () {},
          ),
          IconButton(
            key: const ValueKey('star'),
            icon: const Icon(Icons.star),
            onPressed: () {},
          ),
          IconButton(
            key: const ValueKey('play_arrow'),
            icon: const Icon(Icons.play_arrow),
            onPressed: () {},
          ),
          PopupMenuButton<void>(
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text('One')),
              const PopupMenuItem(child: Text('Two')),
            ],
          ),
        ],
      ),
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Can swipe: ${pageRoute.canSwipe}'),
            TextButton(
              onPressed: () {
                // You can disable swiping completely using `canSwipe`:
                setState(() => pageRoute.canSwipe = !pageRoute.canSwipe);
              },
              child: const Text('Toggle'),
            ),
            Text('Can only swipe from edge: ${pageRoute.canOnlySwipeFromEdge}'),
            TextButton(
              onPressed: () => setState(
                () => pageRoute.canOnlySwipeFromEdge =
                    !pageRoute.canOnlySwipeFromEdge,
              ),
              child: const Text('Toggle'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async => _pushThirdPage(context),
              child: const Text('Open page 3'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pushThirdPage(BuildContext context) async {
    return switch (NavigationMode.current) {
      NavigationMode.navigator => Navigator.of(context)
          .push<void>(SwipeablePageRoute(builder: (_) => const ThirdPage())),
      NavigationMode.goRouter => GoRouter.of(context).push<void>('/page3'),
      NavigationMode.goRouterBuilder => ThirdPageRoute().push(context),
    };
  }
}

class ThirdPage extends StatefulWidget {
  const ThirdPage();

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage>
    with SingleTickerProviderStateMixin {
  static const _tabCount = 3;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
    _tabController.addListener(() {
      if (!mounted) return;

      final canSwipe = _tabController.index == 0;
      context.getSwipeablePageRoute<void>()!.canSwipe = canSwipe;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MorphingAppBar(
        backgroundColor: Colors.green,
        title: const Text('Page 3'),
        actions: [
          IconButton(
            key: const ValueKey('star'),
            icon: const Icon(Icons.star),
            onPressed: () {},
          ),
          IconButton(
            key: const ValueKey('play_arrow'),
            icon: const Icon(Icons.play_arrow),
            onPressed: () {},
          ),
          IconButton(
            key: const ValueKey('favorite'),
            icon: const Icon(Icons.favorite),
            onPressed: () {},
          ),
          PopupMenuButton<void>(
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text('One')),
              const PopupMenuItem(child: Text('Two')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: [
            for (var i = 0; i < _tabCount; i++) Tab(text: 'Tab ${i + 1}'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          for (var i = 0; i < _tabCount; i++)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('This is tab ${i + 1}'),
                ElevatedButton(
                  onPressed: () async => _pushSecondPage(context),
                  child: const Text('Open page 2'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _pushSecondPage(BuildContext context) async {
    return switch (NavigationMode.current) {
      NavigationMode.navigator => Navigator.of(context)
          .push<void>(SwipeablePageRoute(builder: (_) => const SecondPage())),
      NavigationMode.goRouter => GoRouter.of(context).push<void>('/page2'),
      NavigationMode.goRouterBuilder => SecondPageRoute().push(context),
    };
  }
}
