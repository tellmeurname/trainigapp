import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<void> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');

    if (savedEmail == email && savedPassword == password) {
      print('Пользователь вошел: Email: $email, Password: $password');
    } else {
      throw Exception('Неверный email или пароль');
    }
  }

  Future<void> register(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    print('Пользователь зарегистрирован: Email: $email, Password: $password');
  }
}