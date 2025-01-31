
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:godtrain/models/exercise.dart';
import 'exercise_selection_screen.dart';

class WorkoutScreen extends StatefulWidget {
  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  List<Exercise> _exercises = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  void _addExercise(BuildContext context) async {
    final selectedExercise = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExerciseSelectionScreen()),
    );

    if (selectedExercise != null) {
      setState(() {
        _exercises.add(selectedExercise);
      });
    }
  }


  void _moveExercise(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final exercise = _exercises.removeAt(oldIndex);
      _exercises.insert(newIndex, exercise);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Тренировка'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addExercise(context),
          ),
        ],
      ),
      body: _exercises.isEmpty
          ? Center(child: Text('Добавьте упражнения'))
          : ReorderableListView.builder(
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                return Card(
                  key: Key(exercise.id),
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_upward),
                          onPressed: () {
                            if (index > 0) {
                              _moveExercise(index, index - 1);
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_downward),
                          onPressed: () {
                            if (index < _exercises.length - 1) {
                              _moveExercise(index, index + 1);
                            }
                          },
                        ),
                      ],
                    ),
                    title: Text(exercise.name),
                    subtitle: Text('${exercise.sets}x${exercise.reps}, ${exercise.weight} кг'),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _editExercise(context, exercise, index);
                      },
                    ),
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) => _moveExercise(oldIndex, newIndex),
            ),
    );
  }


  void _editExercise(BuildContext context, Exercise exercise, int index) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ExerciseEditDialog(exercise: exercise),
    );

    if (result != null) {
      setState(() {
        _exercises[index] = Exercise(
          id: exercise.id,
          name: exercise.name,
          description: exercise.description,
          type: exercise.type,
          sets: result['sets'],
          reps: result['reps'],
          weight: result['weight'],
        );
      });
    }
  }
}


class ExerciseEditDialog extends StatefulWidget {
  final Exercise exercise;

  ExerciseEditDialog({required this.exercise});

  @override
  _ExerciseEditDialogState createState() => _ExerciseEditDialogState();
}

class _ExerciseEditDialogState extends State<ExerciseEditDialog> {
  late int _sets;
  late int _reps;
  late double _weight;

  @override
  void initState() {
    super.initState();
    _sets = widget.exercise.sets;
    _reps = widget.exercise.reps;
    _weight = widget.exercise.weight;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Редактировать упражнение'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: TextEditingController(text: _sets.toString()),
            keyboardType: TextInputType.number,
            onChanged: (value) => _sets = int.tryParse(value) ?? _sets,
            decoration: InputDecoration(labelText: 'Подходы'),
          ),
          TextField(
            controller: TextEditingController(text: _reps.toString()),
            keyboardType: TextInputType.number,
            onChanged: (value) => _reps = int.tryParse(value) ?? _reps,
            decoration: InputDecoration(labelText: 'Повторения'),
          ),
          TextField(
            controller: TextEditingController(text: _weight.toString()),
            keyboardType: TextInputType.number,
            onChanged: (value) => _weight = double.tryParse(value) ?? _weight,
            decoration: InputDecoration(labelText: 'Вес (кг)'),
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
            Navigator.pop(context, {'sets': _sets, 'reps': _reps, 'weight': _weight});
          },
          child: Text('Сохранить'),
        ),
      ],
    );
  }
}