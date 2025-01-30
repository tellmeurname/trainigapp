import 'package:flutter/material.dart';

class MyWorkoutsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Мои тренировки'),
      ),
      body: Center(
        child: Text('Здесь будут ваши тренировки'),
      ),
    );
  }
}