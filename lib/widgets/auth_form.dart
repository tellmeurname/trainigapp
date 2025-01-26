import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>(); 
  String _email = '';
  String _password = '';

  void _submit() {
    if (_formKey.currentState!.validate()) { 
      _formKey.currentState!.save(); // 
      print('Email: $_email, Пароль: $_password');
    }
  }

  @override
  Widget build(BuildContext context) { 
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Почта'),
              validator: (value) {
                if (value!.isEmpty || !value.contains('@')) { 
                  return 'Некорректный email (нет @)';
                }
                return null;
              },
              onSaved: (value) {
                _email = value!;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Пароль'),
              obscureText: true,
              validator: (value) {
                if (value!.isEmpty || value.length < 6) { 
                  return 'Пароль не менее 6 символов';
                }
                return null;
              },
              onSaved: (value) {
                _password = value!;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Войти'),
            ),
          ],
        ),
      ),
    );
  }
}