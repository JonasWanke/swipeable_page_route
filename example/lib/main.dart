import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:flutter/material.dart';

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
      body: RaisedButton(
        onPressed: () {
          Navigator.of(context).push<void>(SwipeablePageRoute(
            builder: (_) => SecondPage(),
          ));
        },
        child: Text('Open page 2'),
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
            itemBuilder: (context) {
              return [
                PopupMenuItem<void>(child: Text('One')),
                PopupMenuItem<void>(child: Text('Two')),
              ];
            },
          ),
        ],
      ),
      body: RaisedButton(
        onPressed: () {
          Navigator.of(context).push<void>(SwipeablePageRoute(
            builder: (_) => ThirdPage(),
          ));
        },
        child: Text('Open page 3'),
      ),
    );
  }
}

class ThirdPage extends StatefulWidget {
  @override
  _ThirdPageState createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> with TickerProviderStateMixin {
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
            itemBuilder: (context) {
              return [
                PopupMenuItem<void>(child: Text('One')),
                PopupMenuItem<void>(child: Text('Two')),
              ];
            },
          ),
        ],
        bottom: TabBar(
          controller: TabController(length: 3, vsync: this),
          indicatorColor: Colors.white,
          tabs: <Widget>[
            Tab(text: 'Tab 1'),
            Tab(text: 'Tab 2'),
            Tab(text: 'Tab 3'),
          ],
        ),
      ),
      body: RaisedButton(
        onPressed: () {
          Navigator.of(context).push<void>(SwipeablePageRoute(
            builder: (_) => SecondPage(),
          ));
        },
        child: Text('Open page 2'),
      ),
    );
  }
}
