import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FitnessGoalsPage extends StatefulWidget {
  const FitnessGoalsPage({super.key});

  @override
  State<FitnessGoalsPage> createState() => _FitnessGoalsPageState();
}

class _FitnessGoalsPageState extends State<FitnessGoalsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  
  // Default values for sliders
  double _workoutDays = 3;
  double _weeklyHours = 4;
  double _calorieGoal = 2000;
  
  bool _isLoading = false;

  Future<void> _saveGoalsAndContinue() async {
    if (_auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to save goals')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _database.ref().child('userGoals').child(_auth.currentUser!.uid).set({
        'workoutDays': _workoutDays.toInt(),
        'weeklyHours': _weeklyHours.toInt(),
        'calorieGoal': _calorieGoal.toInt(),
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving goals: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Widget _buildQuestionCard({
    required String question,
    required String value,
    required double sliderValue,
    required double min,
    required double max,
    required Function(double) onChanged,
    required String recommendation,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4285F4),
            ),
          ),
          Slider(
            value: sliderValue,
            min: min,
            max: max,
            divisions: max.toInt() - min.toInt(),
            activeColor: const Color(0xFF4285F4),
            onChanged: onChanged,
          ),
          const SizedBox(height: 4),
          Text(
            recommendation,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFF5F7FA),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Your Goals',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Help us personalize your fitness journey',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildQuestionCard(
                          question: 'How many days per week do you want to workout?',
                          value: 'Target: ${_workoutDays.toInt()} days',
                          sliderValue: _workoutDays,
                          min: 1,
                          max: 7,
                          onChanged: (value) {
                            setState(() {
                              _workoutDays = value;
                            });
                          },
                          recommendation: 'Recommended: 3-5 days for optimal results with rest days',
                        ),
                        _buildQuestionCard(
                          question: 'How many hours can you commit per week?',
                          value: 'Target: ${_weeklyHours.toInt()} hours',
                          sliderValue: _weeklyHours,
                          min: 1,
                          max: 10,
                          onChanged: (value) {
                            setState(() {
                              _weeklyHours = value;
                            });
                          },
                          recommendation: 'Recommended: 4-6 hours for balanced progress',
                        ),
                        _buildQuestionCard(
                          question: 'Weekly calorie burn goal?',
                          value: 'Target: ${_calorieGoal.toInt()} calories',
                          sliderValue: _calorieGoal,
                          min: 1000,
                          max: 5000,
                          onChanged: (value) {
                            setState(() {
                              _calorieGoal = value;
                            });
                          },
                          recommendation: 'Recommended: 2000-3000 calories for sustainable weight management',
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveGoalsAndContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4285F4),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}