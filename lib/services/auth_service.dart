import 'package:godtrain/database/database_service.dart';

class AuthService {
  final DatabaseService _dbService = DatabaseService();

  Future<void> register(String email, String password) async {
    try {
      await _dbService.registerUser(email, password);
      print('✅ Пользователь зарегистрирован: $email');
    } catch (e) {
      print('❌ Ошибка регистрации: $e');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final user = await _dbService.getUser(email);
      if (user != null && user['password'] == password) {
        print('✅ Вход выполнен: $email');
      } else {
        print('❌ Неверный email или пароль');
        throw Exception('Неверный email или пароль');
      }
    } catch (e) {
      print('❌ Ошибка входа: $e');
    }
  }
}
