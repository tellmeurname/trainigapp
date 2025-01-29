import 'package:flutter/material.dart';
import 'package:godtrain/services/auth_service.dart';
import 'package:godtrain/screeens/home_screen.dart';

class AuthForm extends StatefulWidget {
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  String _email = '';
  String _password = '';
  bool _isLogin = true; // Переменная для переключения между входом и регистрацией

  void _submit() async {
    print("Форма отправлена");
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        if (_isLogin) {
          // Вход
          print("Выполняю вход с email: $_email");
          await _authService.login(_email, _password);
        } else {
          // Регистрация
          print("Выполняю регистрацию с email: $_email");
          await _authService.register(_email, _password);
        }
        // Перенаправление на главный экран
        print("Авторизация прошла успешно, перенаправляю на главный экран");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (e) {
        print("Ошибка при авторизации: $e");
        // Обработка ошибок (например, неверный пароль)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } else {
      print("Форма не прошла валидацию");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Отрисовывается AuthForm");
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
                print("Сохранен email: $_email");
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
                print("Сохранен пароль: $_password");
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text(_isLogin ? 'Войти' : 'Зарегистрироваться'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin; // Переключаем между входом и регистрацией
                  print("Переключение режима: ${_isLogin ? 'Вход' : 'Регистрация'}");
                });
              },
              child: Text(_isLogin
                  ? 'Нет аккаунта? Зарегистрироваться'
                  : 'Уже есть аккаунт? Войти'),
            ),
          ],
        ),
      ),
    );
  }
}
