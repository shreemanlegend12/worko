import 'package:flutter/material.dart';
import 'dart:async';
import 'models/workout.dart';

class ActiveWorkoutPage extends StatefulWidget {
  final Workout workout;

  const ActiveWorkoutPage({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  State<ActiveWorkoutPage> createState() => _ActiveWorkoutPageState();
}

class _ActiveWorkoutPageState extends State<ActiveWorkoutPage> {
  int currentExerciseIndex = 0;
  List<Set<int>> completedSets = [];
  late Timer _timer;
  Duration _elapsed = const Duration();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    completedSets = List.generate(
      widget.workout.exercises.length,
      (index) => <int>{},
    );
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isActive) {
        setState(() {
          _elapsed += const Duration(seconds: 1);
        });
      }
    });
  }

  String get formattedTime {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(_elapsed.inMinutes.remainder(60));
    String seconds = twoDigits(_elapsed.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Exercise get currentExercise => widget.workout.exercises[currentExerciseIndex];

  void completeSet(int setIndex) {
    setState(() {
      if (completedSets[currentExerciseIndex].contains(setIndex)) {
        completedSets[currentExerciseIndex].remove(setIndex);
      } else {
        completedSets[currentExerciseIndex].add(setIndex);
      }
    });
  }

  bool isSetCompleted(int setIndex) {
    return completedSets[currentExerciseIndex].contains(setIndex);
  }

  void onCompleteExercise() {
    if (currentExerciseIndex < widget.workout.exercises.length - 1) {
      setState(() {
        currentExerciseIndex++;
      });
    } else {
      // Workout completed
      _timer.cancel();
      Navigator.popUntil(
        context,
        (route) => route.settings.name == '/workout' || route.isFirst,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout completed! Great job!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.workout.title,
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                formattedTime,
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: currentExerciseIndex / widget.workout.exercises.length,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$currentExerciseIndex of ${widget.workout.exercises.length} exercises completed',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  currentExercise.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentExercise.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                ...List.generate(
                  currentExercise.sets,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: InkWell(
                      onTap: () => completeSet(index),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSetCompleted(index)
                                ? Colors.green
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Set ${index + 1}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${currentExercise.reps} reps',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const Spacer(),
                            if (isSetCompleted(index))
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: onCompleteExercise,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            currentExerciseIndex < widget.workout.exercises.length - 1
                ? 'Complete Exercise'
                : 'Finish Workout',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}