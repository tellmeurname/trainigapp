import 'package:flutter/material.dart';
import 'package:godtrain/screeens/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:godtrain/screeens/settings_screen.dart';
import 'package:godtrain/screeens/workout_screen.dart'; 
import 'package:godtrain/screeens/my_workouts_screen.dart';
import 'package:godtrain/database/exercise_database_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Главный экран'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Text(
                'Меню',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Настройки'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.fitness_center),
              title: Text('Мои тренировки'),
              onTap: () {
                Navigator.pop(context);
                // Переход на экран "Мои тренировки"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyWorkoutsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('База упражнений'),
              onTap: () {
                Navigator.pop(context);
                
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExerciseDatabaseScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Выход из учетной записи'),
              onTap: () {
                Navigator.pop(context);
               
                _logout(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WorkoutScreen()),
                );
              },
              child: Text('Начать тренировку'),
            ),
          ],
        ),
      ),
    );
  }

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
}