import '../models/user.dart';

class AuthService {
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    if (email == 'operario@test.com' && password == '123456') {
      return User(id: '1', name: 'Opereario Test', email: email, role: '1');
    }
    else if (email == 'supervisor@test.com' && password == '123456') {
      return User(id: '2', name: 'Supervisor Test', email: email, role: '2');
    }
    throw Exception('Credenciales invalidads');
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}