import 'package:flutter/material.dart';
import 'package:godtrain/widgets/auth_form.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("Отрисовывается AuthScreen");
    return Scaffold(
      appBar: AppBar(
        title: Text('Аутентификация'),
      ),
      body: AuthForm(),
    );
  }
}
