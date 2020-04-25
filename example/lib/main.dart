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
          Navigator.of(context).push(SwipeablePageRoute(
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
      ),
    );
  }
}
