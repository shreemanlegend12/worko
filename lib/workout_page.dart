import 'package:flutter/material.dart';
import 'models/workout.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({Key? key}) : super(key: key);

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Strength',
    'Cardio',
    'Core',
    'Flexibility'
  ];

  // Sample workout data
  final List<Workout> _workouts = [
    const Workout(
      id: '1',
      title: 'Full Body Workout',
      description: 'Complete full body workout targeting all major muscle groups',
      duration: 45,
      calories: 350,
      difficulty: 'Beginner',
      category: 'Strength',
      imageUrl: 'assets/images/workouts/full_body.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Workout> get filteredWorkouts {
    return _workouts.where((workout) {
      final matchesSearch = workout.title.toLowerCase().contains(_searchQuery) ||
          workout.description.toLowerCase().contains(_searchQuery);
      final matchesCategory = _selectedCategory == 'All' || 
          workout.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Workouts',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search workouts...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) => 
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: _selectedCategory == category,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: const Color(0xFF4285F4),
                            labelStyle: TextStyle(
                              color: _selectedCategory == category 
                                ? Colors.white 
                                : Colors.black87,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredWorkouts.isEmpty
                ? Center(
                    child: Text(
                      'No workouts found',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredWorkouts.length,
                    itemBuilder: (context, index) {
                      final workout = filteredWorkouts[index];
                      return WorkoutCard(workout: workout);
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutCard extends StatelessWidget {
  final Workout workout;

  const WorkoutCard({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                workout.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  workout.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${workout.duration} min',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.local_fire_department_outlined, 
                         size: 16, 
                         color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${workout.calories} cal',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        workout.difficulty,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle start workout
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4285F4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Start Workout'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}