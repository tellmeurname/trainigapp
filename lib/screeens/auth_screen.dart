import 'package:flutter/material.dart';
import 'package:godtrain/widgets/auth_form.dart'; // Импортируем AuthForm

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Аутентификация'),
      ),
      body: AuthForm(), // Используем AuthForm
    );
  }
}