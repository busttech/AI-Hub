import 'package:flutter/material.dart';
import 'Homescreen.dart';
void main() {
  runApp(GeminiChatApp());
}

class GeminiChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Summarizer',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: Dashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}
