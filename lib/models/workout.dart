class Workout {
  final String id;
  final String title;
  final String description;
  final int duration;
  final int calories;
  final String difficulty;
  final String category;
  final String imageUrl;

  const Workout({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.calories,
    required this.difficulty,
    required this.category,
    required this.imageUrl,
  });
}