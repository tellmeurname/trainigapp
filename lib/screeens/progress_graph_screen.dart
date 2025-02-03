// progress_graph_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressGraphScreen extends StatefulWidget {
  @override
  _ProgressGraphScreenState createState() => _ProgressGraphScreenState();
}

class _ProgressGraphScreenState extends State<ProgressGraphScreen> {
  List<Map<String, dynamic>> _exercises = []; // Список всех упражнений
  String? _selectedExerciseId; // ID выбранного упражнения
  List<WorkoutData> _workoutData = []; // Все данные о тренировках
  List<List<WorkoutData>> _groupedWorkoutData = []; // Группы по 10 точек
  int _currentGroupIndex = 0; // Индекс текущей группы

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  // Загрузка всех упражнений из Firestore
  Future<void> _loadExercises() async {
    try {
      final exercisesSnapshot = await FirebaseFirestore.instance.collection('exercises').get();
      setState(() {
        _exercises = exercisesSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {'id': doc.id, 'name': data['name']};
        }).toList();
      });
    } catch (e) {
      print('❌ Ошибка загрузки упражнений: $e');
    }
  }

  // Загрузка данных о тренировках для выбранного упражнения
  Future<void> _loadWorkoutData(String exerciseId) async {
    try {
      final workoutsSnapshot = await FirebaseFirestore.instance.collection('workouts').get();
      final workoutData = <WorkoutData>[];

      for (final doc in workoutsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['date'] == null || data['exercises'] == null) continue;

        final date = (data['date'] as Timestamp).toDate();
        final exercisesList = data['exercises'] as List<dynamic>;

        for (final e in exercisesList) {
          if (e['id'] == exerciseId) {
            workoutData.add(
              WorkoutData(
                date: date,
                weight: e['weight'].toDouble(),
              ),
            );
          }
        }
      }

      // Сортируем данные по дате
      workoutData.sort((a, b) => a.date.compareTo(b.date));

      // Разделяем данные на группы по 10 точек
      final groupedData = <List<WorkoutData>>[];
      for (var i = 0; i < workoutData.length; i += 10) {
        groupedData.add(workoutData.sublist(i, i + 10 > workoutData.length ? workoutData.length : i + 10));
      }

      setState(() {
        _workoutData = workoutData;
        _groupedWorkoutData = groupedData;
        _currentGroupIndex = 0; // Начинаем с первой группы
      });
    } catch (e) {
      print('❌ Ошибка загрузки данных тренировок: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('График прогресса'),
      ),
      body: Column(
        children: [
          // Выбор упражнения
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedExerciseId,
              decoration: InputDecoration(
                labelText: 'Выберите упражнение',
                border: OutlineInputBorder(),
              ),
              items: _exercises.map((exercise) {
                return DropdownMenuItem<String>(
                  value: exercise['id'],
                  child: Text(exercise['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedExerciseId = value;
                });
                if (value != null) {
                  _loadWorkoutData(value);
                }
              },
            ),
          ),
          SizedBox(height: 16),
          // График прогресса
          Expanded(
            child: _workoutData.isEmpty
                ? Center(child: Text('Нет данных для графика'))
                : Column(
                    children: [
                      // График
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0), // Отступы по бокам
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40, // Увеличиваем расстояние между метками и графиком
                                    getTitlesWidget: (value, meta) {
                                      final currentGroup = _groupedWorkoutData[_currentGroupIndex];
                                      final matchingPoint = currentGroup.firstWhere(
                                        (point) => point.date.millisecondsSinceEpoch.toDouble() == value,
                                        orElse: () => WorkoutData(date: DateTime(0), weight: 0),
                                      );

                                      if (matchingPoint.date == DateTime(0)) {
                                        return Container();
                                      }

                                      return Text(
                                        DateFormat('dd MMM').format(matchingPoint.date),
                                        style: TextStyle(fontSize: 10),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 60, // Увеличиваем расстояние между метками и графиком
                                    getTitlesWidget: (value, meta) {
                                      return Text('${value.toInt()} кг', style: TextStyle(fontSize: 10));
                                    },
                                  ),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false), // Отключаем метки сверху
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false), // Отключаем метки справа
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _groupedWorkoutData[_currentGroupIndex]
                                      .map((data) => FlSpot(
                                            data.date.millisecondsSinceEpoch.toDouble(),
                                            data.weight,
                                          ))
                                      .toList(),
                                  isCurved: true,
                                  color: Colors.blue,
                                  dotData: FlDotData(show: true),
                                ),
                              ],
                              minX: _groupedWorkoutData[_currentGroupIndex]
                                  .map((data) => data.date.millisecondsSinceEpoch.toDouble())
                                  .reduce((a, b) => a < b ? a : b),
                              maxX: _groupedWorkoutData[_currentGroupIndex]
                                  .map((data) => data.date.millisecondsSinceEpoch.toDouble())
                                  .reduce((a, b) => a > b ? a : b),
                              minY: _groupedWorkoutData[_currentGroupIndex].map((data) => data.weight).reduce((a, b) => a < b ? a : b) - 5,
                              maxY: _groupedWorkoutData[_currentGroupIndex].map((data) => data.weight).reduce((a, b) => a > b ? a : b) + 5,
                            ),
                          ),
                        ),
                      ),
                      // Кнопки навигации
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: _currentGroupIndex > 0
                                ? () {
                                    setState(() {
                                      _currentGroupIndex--;
                                    });
                                  }
                                : null,
                          ),
                          Text('Группа ${_currentGroupIndex + 1} из ${_groupedWorkoutData.length}'),
                          IconButton(
                            icon: Icon(Icons.arrow_forward),
                            onPressed: _currentGroupIndex < _groupedWorkoutData.length - 1
                                ? () {
                                    setState(() {
                                      _currentGroupIndex++;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// Модель данных для графика
class WorkoutData {
  final DateTime date;
  final double weight;

  WorkoutData({
    required this.date,
    required this.weight,
  });
}