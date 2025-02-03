// home_screen.dart
import 'package:flutter/material.dart';
import 'package:godtrain/screeens/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:godtrain/screeens/settings_screen.dart';
import 'package:godtrain/screeens/workout_screen.dart';
import 'package:godtrain/screeens/my_workouts_screen.dart';
import 'package:godtrain/database/exercise_database_screen.dart';
import 'package:godtrain/screeens/progress_graph_screen.dart'; // Новый импорт

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Индекс выбранного экрана

  // Список экранов
  final List<Widget> _screens = [
    WorkoutScreen(), // Главный экран (Начать тренировку)
    MyWorkoutsScreen(), // Мои тренировки
    ExerciseDatabaseScreen(), // База упражнений
    ProgressGraphScreen(), // График прогресса
    SettingsScreen(), // Настройки
  ];

  // Выход из учетной записи
  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      print("✅ Пользователь вышел из учетной записи");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
    } catch (e) {
      print("❌ Ошибка выхода: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка выхода: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Главный экран'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context), // Выход из учетной записи
          ),
        ],
      ),
      body: _screens[_selectedIndex], // Отображение текущего экрана
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Текущий индекс
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // Обновление индекса при нажатии
          });
        },
        type: BottomNavigationBarType.fixed, // Фиксированный тип для более 3 элементов
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Тренировка',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Мои тренировки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'База упражнений',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Прогресс',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}