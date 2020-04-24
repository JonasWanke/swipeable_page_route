import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '🔙 swipeable_page_route example',
      home: Scaffold(
        appBar: AppBar(title: Text('🔙 swipeable_page_route example')),
        body: SizedBox(),
      ),
    );
  }
}
