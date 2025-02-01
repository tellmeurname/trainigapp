// my_workouts_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Для форматирования даты
import 'dart:convert'; // Для работы с JSON
import 'package:godtrain/models/exercise.dart';

class MyWorkoutsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Мои тренировки'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('workouts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Нет сохранённых тренировок'));
          }

          // Преобразуем данные из Firestore
          final workouts = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            // Проверка наличия полей 'date' и 'exercises'
            if (data['date'] == null || data['exercises'] == null) {
              print('⚠️ Некорректные данные в документе: $data');
              return null; // Пропускаем некорректные документы
            }

            // Преобразование 'date' из Timestamp в DateTime
            final date = (data['date'] as Timestamp).toDate();

            // Преобразование JSON-строки в список упражнений
            final exercisesJson = data['exercises'] as String;
            final exercisesList = jsonDecode(exercisesJson) as List<dynamic>;

            final exercises = exercisesList.map((e) {
              return Exercise(
                id: e['id'],
                name: e['name'],
                description: e['description'],
                type: e['type'],
                sets: e['sets'],
                reps: e['reps'],
                weight: e['weight'],
              );
            }).toList();

            return {'date': date, 'exercises': exercises};
          }).where((workout) => workout != null).toList(); // Фильтруем null-значения

          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index] as Map<String, dynamic>;

              // Форматирование даты
              final formattedDate = DateFormat('dd MMMM yyyy').format(workout['date'] as DateTime);

              // Отображение упражнений
              return ExpansionTile(
                title: Text(formattedDate),
                children: (workout['exercises'] as List<Exercise>).map<Widget>((exercise) {
                  return ListTile(
                    title: Text(exercise.name),
                    subtitle: Text('${exercise.sets}x${exercise.reps}, ${exercise.weight} кг'),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}