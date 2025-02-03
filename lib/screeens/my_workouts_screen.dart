// my_workouts_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Для форматирования даты
import 'package:godtrain/models/exercise.dart';
import 'package:table_calendar/table_calendar.dart';

class MyWorkoutsScreen extends StatefulWidget {
  @override
  _MyWorkoutsScreenState createState() => _MyWorkoutsScreenState();
}

class _MyWorkoutsScreenState extends State<MyWorkoutsScreen> {
  late Map<DateTime, List<Map<String, dynamic>>> _workoutsByDate; // Список тренировок по датам
  DateTime _selectedDay = DateTime.now(); // Выбранная дата
  DateTime _focusedDay = DateTime.now(); // Фокус календаря

  @override
  void initState() {
    super.initState();
    _workoutsByDate = {};
  }

  // Загрузка тренировок из Firestore
  Future<void> _loadWorkouts() async {
    try {
      final workoutsSnapshot = await FirebaseFirestore.instance.collection('workouts').get();
      final workoutsByDate = <DateTime, List<Map<String, dynamic>>>{};

      for (final doc in workoutsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        if (data['date'] == null || data['exercises'] == null) {
          print('⚠️ Некорректные данные в документе: $data');
          continue;
        }

        // Преобразование 'date' из Timestamp в DateTime
        final date = (data['date'] as Timestamp).toDate();

        // Преобразование массива в список упражнений
        final exercisesList = data['exercises'] as List<dynamic>;
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

        // Группируем тренировки по дате
        final dateKey = DateTime(date.year, date.month, date.day);
        if (workoutsByDate.containsKey(dateKey)) {
          workoutsByDate[dateKey]!.add({'date': date, 'exercises': exercises});
        } else {
          workoutsByDate[dateKey] = [{'date': date, 'exercises': exercises}];
        }
      }

      setState(() {
        _workoutsByDate = workoutsByDate;
      });
      print('Загружены тренировки: $_workoutsByDate'); // Логирование загруженных данных
    } catch (e) {
      print('❌ Ошибка загрузки тренировок: $e');
    }
  }

  // Получение тренировок для выбранной даты
  List<Map<String, dynamic>> _getWorkoutsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day); // Нормализация даты
    return _workoutsByDate[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    // Если данные еще не загружены, загружаем их
    if (_workoutsByDate.isEmpty) {
      _loadWorkouts();
      return Scaffold(
        appBar: AppBar(
          title: Text('Мои тренировки'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Мои тренировки'),
      ),
      body: Column(
        children: [
          // Календарь
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              final normalizedSelectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
              print('Выбранная дата: $normalizedSelectedDay'); // Логирование выбранной даты
              setState(() {
                _selectedDay = normalizedSelectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              // Подсветка дней с тренировками
              final normalizedDay = DateTime(day.year, day.month, day.day);
              return _workoutsByDate.containsKey(normalizedDay) ? ['Тренировка'] : [];
            },
          ),
          SizedBox(height: 16),
          // Список тренировок для выбранной даты
          Expanded(
            child: _getWorkoutsForDay(_selectedDay).isEmpty
                ? Center(child: Text('Нет тренировок на эту дату'))
                : ListView.builder(
                    itemCount: _getWorkoutsForDay(_selectedDay).length,
                    itemBuilder: (context, index) {
                      final workout = _getWorkoutsForDay(_selectedDay)[index];
                      final formattedDate = DateFormat('dd MMMM yyyy').format(workout['date'] as DateTime);

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
                  ),
          ),
        ],
      ),
    );
  }
}