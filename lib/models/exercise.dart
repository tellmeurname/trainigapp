// models/exercise.dart
class Exercise {
  final String id;
  final String name;
  final String description;
  final String type;
  final int sets;
  final int reps;
  final double weight;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.sets,
    required this.reps,
    required this.weight,
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

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      type: map['type'],
      sets: map['sets'] ?? 0, // Значение по умолчанию
      reps: map['reps'] ?? 0, // Значение по умолчанию
      weight: map['weight']?.toDouble() ?? 0.0, // Значение по умолчанию
    );
  }
}