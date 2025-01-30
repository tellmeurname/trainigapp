// exercise_database_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseDatabaseScreen extends StatefulWidget {
  @override
  _ExerciseDatabaseScreenState createState() => _ExerciseDatabaseScreenState();
}

class _ExerciseDatabaseScreenState extends State<ExerciseDatabaseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('База упражнений'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addExercise(context), // Кнопка добавления
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Поиск по названию',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase(); // Обновляем запрос поиска
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('exercises').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Ошибка загрузки данных: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Нет доступных упражнений'));
                }

                // Фильтруем данные по запросу поиска
                var exercises = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return data['name'].toString().toLowerCase().contains(_searchQuery);
                }).toList();

                if (exercises.isEmpty) {
                  return Center(child: Text('Упражнения не найдены'));
                }

                return ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    var exercise = exercises[index];
                    var data = exercise.data() as Map<String, dynamic>;

                    return ListTile(
                      leading: Icon(Icons.fitness_center), // Иконка гантели
                      title: Text(data['name']),
                      subtitle: Text('${data['description']} (${data['type']})'),
                      onTap: () {
                        print('Выбрано упражнение: ${data['name']}');
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Метод для добавления нового упражнения
  void _addExercise(BuildContext context) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final typeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Добавить упражнение'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Название'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Описание'),
            ),
            TextField(
              controller: typeController,
              decoration: InputDecoration(labelText: 'Тип (например, Силовое)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Проверяем, что поля не пустые
              if (nameController.text.isEmpty ||
                  descriptionController.text.isEmpty ||
                  typeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Заполните все поля')),
                );
                return;
              }

              // Сохраняем данные в Firestore
              try {
                await FirebaseFirestore.instance.collection('exercises').add({
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'type': typeController.text,
                });
                print('✅ Упражнение добавлено: ${nameController.text}');
                Navigator.pop(context); // Закрываем диалог
              } catch (e) {
                print('❌ Ошибка добавления упражнения: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка добавления: $e')),
                );
              }
            },
            child: Text('Добавить'),
          ),
        ],
      ),
    );
  }
}