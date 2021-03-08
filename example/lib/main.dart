import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '🔙 swipeable_page_route example',
      home: FirstPage(),
    );
  }
}

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MorphingAppBar(
        title: Text('🔙 swipeable_page_route example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.navigator
                .push<void>(SwipeablePageRoute(builder: (_) => SecondPage()));
          },
          child: Text('Open page 2'),
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MorphingAppBar(
        title: Text('Page 2'),
        actions: <Widget>[
          IconButton(
            key: ValueKey('check'),
            icon: Icon(Icons.check),
            onPressed: () {},
          ),
          IconButton(
            key: ValueKey('star'),
            icon: Icon(Icons.star),
            onPressed: () {},
          ),
          IconButton(
            key: ValueKey('play_arrow'),
            icon: Icon(Icons.play_arrow),
            onPressed: () {},
          ),
          PopupMenuButton<void>(
            itemBuilder: (context) => [
              PopupMenuItem(child: Text('One')),
              PopupMenuItem(child: Text('Two')),
            ],
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.navigator.push<void>(CupertinoPageRoute(
              // This option has to be enabled for pages with horizontally
              // scrollable content, as otherwise, `SwipeablePageRoute`'s
              // swipe-gesture intercepts those gestures in the page. This way,
              // only swipes starting from the left (LTR) or right (RTL) screen
              // edge can be used to navigate back.
              // canOnlySwipeFromEdge: true,
              // You can customize the width of the detection area with
              // `backGestureDetectionWidth`.
              builder: (_) => ThirdPage(),
            ));
          },
          child: Text('Open page 3'),
        ),
      ),
    );
  }
}

class ThirdPage extends StatefulWidget {
  @override
  _ThirdPageState createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage>
    with SingleTickerProviderStateMixin {
  static const _tabCount = 3;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
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
        title: Text('Page 3'),
        actions: <Widget>[
          IconButton(
            key: ValueKey('star'),
            icon: Icon(Icons.star),
            onPressed: () {},
          ),
          IconButton(
            key: ValueKey('play_arrow'),
            icon: Icon(Icons.play_arrow),
            onPressed: () {},
          ),
          IconButton(
            key: ValueKey('favorite'),
            icon: Icon(Icons.favorite),
            onPressed: () {},
          ),
          PopupMenuButton<void>(
            itemBuilder: (context) => [
              PopupMenuItem(child: Text('One')),
              PopupMenuItem(child: Text('Two')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: <Widget>[
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
                  onPressed: () {
                    context.navigator.push<void>(
                      SwipeablePageRoute(builder: (_) => SecondPage()),
                    );
                  },
                  child: Text('Open page 2'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
