// home_screen.dart
import 'package:flutter/material.dart';
import 'package:godtrain/screeens/settings_screen.dart';
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Главный экран'),
      ),
      // Добавляем Drawer
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
                // Закрываем Drawer
                Navigator.pop(context);
                // Переходим на экран настроек
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Настройки'),
              onTap: () {
                // Закрываем Drawer
                Navigator.pop(context);
                // Переходим на экран настроек (пока просто заглушка)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Переход на настройки')),
                );
              },
            ),
            // Добавьте другие вкладки здесь
          ],
        ),
      ),
      body: Center(
        child: Text('Добро пожаловать!'),
      ),
    );
  }
}