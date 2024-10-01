
import 'package:chatbot_app/front_page.dart';
import 'package:chatbot_app/home_page.dart';
import 'package:flutter/material.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text to Image Generation',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AnimatedBackgroundWithUI(),
    );
  }
}
