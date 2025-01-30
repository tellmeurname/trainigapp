// models/exercise.dart
class Exercise {
  final String id;
  final String name;
  final String description;
  final String type;
  int sets;
  int reps;
  double weight;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.sets = 3,
    this.reps = 10,
    this.weight = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'sets': sets,
      'reps': reps,
      'weight': weight,
    };
  }
}