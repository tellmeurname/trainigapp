import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Инициализация Firestore

  Future<void> register(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Сохраняем данные пользователя в Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'name': '', // Имя можно оставить пустым или запросить позже
        'createdAt': DateTime.now(),
        'exercises': [], // Пустой список упражнений
      });

      print('✅ Пользователь зарегистрирован: $email');
    } catch (e) {
      print('❌ Ошибка регистрации: $e');
      throw e;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Вход выполнен: $email');
    } catch (e) {
      print('❌ Ошибка входа: $e');
      throw e;
    }
  }

  Future<void> addExercise(String userId, String exerciseName, DateTime date) async {
    await _firestore.collection('users').doc(userId).update({
      'exercises': FieldValue.arrayUnion([
        {'name': exerciseName, 'date': date}
      ]),
    });
    print('✅ Упражнение добавлено: $exerciseName');
  }

  Future<List<Map<String, dynamic>>> getExercises(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return List<Map<String, dynamic>>.from(doc['exercises']);
  }
}