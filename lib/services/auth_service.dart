class AuthService {
  Future<void> login(String email, String password) async {
    print('Пользователь вошел: Email: $email, Password: $password');
  }
  Future<void> register(String email, String password) async {
    print('Пользователь зарегистрирован: Email: $email, Password: $password');
  }
}