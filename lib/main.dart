import 'package:flutter/material.dart';
import 'package:godtrain/screeens/auth_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Аутентификация'),
        ),
        body: Center(
          child: Text('Форма аутентификация'),
        ),
      ),
    );
  }
}