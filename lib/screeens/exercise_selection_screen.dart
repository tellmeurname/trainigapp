// exercise_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:godtrain/models/exercise.dart';

class ExerciseSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Выбор упражнений'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addNewExercise(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('exercises').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Нет доступных упражнений'));
          }

          final exercises = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Exercise(
              id: doc.id,
              name: data['name'],
              description: data['description'],
              type: data['type'],
              sets: data['sets'] ?? 0, // Значение по умолчанию
              reps: data['reps'] ?? 0, // Значение по умолчанию
              weight: data['weight']?.toDouble() ?? 0.0, // Значение по умолчанию
            );
          }).toList();

          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return ListTile(
                title: Text(exercise.name),
                subtitle: Text('${exercise.description} (${exercise.type})'),
                onTap: () {
                  Navigator.pop(context, exercise);
                },
              );
            },
          );
        },
      ),
    );
  }

  // Метод для добавления нового упражнения
  void _addNewExercise(BuildContext context) async {
    final newExercise = await showDialog<Exercise>(
      context: context,
      builder: (context) => AddExerciseDialog(),
    );

    if (newExercise != null) {
      await FirebaseFirestore.instance.collection('exercises').add({
        'name': newExercise.name,
        'description': newExercise.description,
        'type': newExercise.type,
        'sets': newExercise.sets,
        'reps': newExercise.reps,
        'weight': newExercise.weight,
      });
      Navigator.pop(context, newExercise);
    }
  }
}

// Диалог для добавления нового упражнения
class AddExerciseDialog extends StatefulWidget {
  @override
  _AddExerciseDialogState createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _typeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Добавить новое упражнение'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Название'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Описание'),
          ),
          TextField(
            controller: _typeController,
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
          onPressed: () {
            final exercise = Exercise(
              id: DateTime.now().toString(),
              name: _nameController.text,
              description: _descriptionController.text,
              type: _typeController.text,
              sets: 0, // Значение по умолчанию
              reps: 0, // Значение по умолчанию
              weight: 0.0, // Значение по умолчанию
            );
            Navigator.pop(context, exercise);
          },
          child: Text('Добавить'),
        ),
      ],
    );
  }
}