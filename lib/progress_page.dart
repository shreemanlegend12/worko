import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseDatabase _database = FirebaseDatabase.instance;

class ProgressPage extends StatefulWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  String _selectedPeriod = 'Weekly';
  Map<String, dynamic> _userGoals = {};
  Map<String, dynamic> _workoutStats = {
    'totalCalories': 0,
    'totalWorkouts': 0,
    'avgTimePerDay': 0.0,
  };
  
  // Initialize with empty data (will be filled with real data)
  Map<String, List<double>> activityData = {
    'Weekly': List.filled(7, 0.0),
    'Monthly': List.filled(31, 0.0),  // Max days in month
  };
  
  final Map<String, List<String>> periodLabels = {
    'Weekly': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    'Monthly': List.generate(31, (index) => '${index + 1}'),
  };

  @override
  void initState() {
    super.initState();
    _fetchGoals();
    _fetchWorkoutStats();
  }

  void _fetchGoals() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        print("Fetching goals for user: $userId");
        final snapshot = await _database.ref('userGoals/$userId').get();
        if (snapshot.exists) {
          setState(() {
            _userGoals = Map<String, dynamic>.from(snapshot.value as Map);
            print("Goals fetched: $_userGoals");
          });
        } else {
          print("No goals found, setting defaults");
          setState(() {
            _userGoals = {
              'workoutDays': 7, // Default target
              'calorieGoal': 5000, // Default target
              'weeklyHours': 10, // Default target
            };
          });
        }
      } catch (e) {
        print("Error fetching goals: $e");
        // Set default goals if there's an error
        setState(() {
          _userGoals = {
            'workoutDays': 7,
            'calorieGoal': 5000,
            'weeklyHours': 10,
          };
        });
      }
    } else {
      print("No user ID available");
    }
  }

  void _fetchWorkoutStats() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("No user ID available for workout stats");
      return;
    }

    try {
      // Use local device time to ensure we're in user's timezone
      final now = DateTime.now();
      print("Fetching $_selectedPeriod workout stats for user: $userId");
      print("Current device time: ${now.toString()}");
      print("Current weekday: ${now.weekday} (1=Monday, 7=Sunday)");
      
      // Initialize default data with correct size
      int daysToShow = _selectedPeriod == 'Weekly' ? 7 : DateTime(now.year, now.month + 1, 0).day;
      List<double> newActivityData = List.filled(daysToShow, 0.0);
      
      // Calculate period dates using local device time
      DateTime startDate;
      if (_selectedPeriod == 'Weekly') {
        // Find start of the week (Monday) based on current device time
        startDate = now.subtract(Duration(days: now.weekday - 1));
        // Force midnight to ensure full day inclusion
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
      } else {
        // Start of month
        startDate = DateTime(now.year, now.month, 1);
      }
          
      print("Period start date: ${startDate.toString()}");
      
      final endDate = _selectedPeriod == 'Weekly'
          ? startDate.add(const Duration(days: 6))
          : DateTime(now.year, now.month + 1, 0);
      
      final workoutHistoryRef = _database.ref('workoutHistory/$userId');
      print("Querying workout history from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}");
      
      // Get workout stats for current period
      Map<String, dynamic> periodStats = {
        'totalCalories': 0,
        'totalWorkouts': 0,
        'totalDuration': 0, // in minutes
      };
      
      // Fetch all workout history
      final historySnapshot = await workoutHistoryRef.get();
      
      if (historySnapshot.exists) {
        final historyData = Map<String, dynamic>.from(historySnapshot.value as Map);
        Map<int, Map<String, dynamic>> dayWorkouts = {};
        
        // Process each workout
        historyData.forEach((key, value) {
          try {
            if (value != null) {
              final workout = Map<String, dynamic>.from(value as Map);
              if (workout.containsKey('completedAt')) {
                // Parse the workout completion time, ensuring we're dealing with local time
                final completedAtString = workout['completedAt'] as String;
                print("Raw completedAt: $completedAtString");
                
                // Parse the date with timezone awareness
                DateTime completedAt;
                try {
                  // Try to parse with timezone if present
                  completedAt = DateTime.parse(completedAtString);
                  // Convert to local time if the timestamp has timezone info
                  final bool hasTimeZone = completedAtString.contains('Z') || 
                                          completedAtString.contains('+') || 
                                          completedAtString.contains('-');
                  if (hasTimeZone) {
                    // If it has timezone info, ensure it's converted to local
                    final offset = DateTime.now().timeZoneOffset;
                    completedAt = completedAt.add(offset);
                  }
                } catch (e) {
                  // Fallback if parsing fails
                  print("Date parsing error: $e");
                  completedAt = DateTime.now();
                }
                
                print("Processed completedAt: ${completedAt.toString()}, weekday: ${completedAt.weekday}");
                
                // Check if workout is within the selected period
                if (completedAt.isAfter(startDate.subtract(const Duration(minutes: 1))) && 
                    completedAt.isBefore(endDate.add(const Duration(days: 1)))) {
                  
                  // Calculate which day of the week/month this workout belongs to
                  int dayDiff;
                  if (_selectedPeriod == 'Weekly') {
                    // For weekly view, index should be 0-6 corresponding to Mon-Sun
                    dayDiff = completedAt.weekday - 1; // Weekday is 1-7 where 1 is Monday
                  } else {
                    // For monthly view, index should be 0-30 corresponding to day of month
                    dayDiff = completedAt.day - 1;
                  }
                  
                  print("Workout on ${_selectedPeriod == 'Weekly' ? 'weekday' : 'day'}: ${dayDiff + 1} (from $completedAt)");
                  
                  // Create or update day stats
                  if (!dayWorkouts.containsKey(dayDiff)) {
                    dayWorkouts[dayDiff] = {
                      'count': 0,
                      'calories': 0,
                      'duration': 0,
                    };
                  }
                  
                  // Update workout counts
                  dayWorkouts[dayDiff]!['count'] = (dayWorkouts[dayDiff]!['count'] as int) + 1;
                  
                  // Add calories if available
                  if (workout.containsKey('caloriesBurned')) {
                    int calories = workout['caloriesBurned'] as int? ?? 0;
                    dayWorkouts[dayDiff]!['calories'] = (dayWorkouts[dayDiff]!['calories'] as int) + calories;
                    periodStats['totalCalories'] = (periodStats['totalCalories'] as int) + calories;
                  }
                  
                  // Add duration if available
                  if (workout.containsKey('duration')) {
                    int duration = workout['duration'] as int? ?? 0;
                    dayWorkouts[dayDiff]!['duration'] = (dayWorkouts[dayDiff]!['duration'] as int) + duration;
                    periodStats['totalDuration'] = (periodStats['totalDuration'] as int) + duration;
                  }
                  
                  // Increment total workouts
                  periodStats['totalWorkouts'] = (periodStats['totalWorkouts'] as int) + 1;
                }
              }
            }
          } catch (e) {
            print("Error processing workout $key: $e");
          }
        });

        print("Day workouts data: $dayWorkouts");
        print("Period stats: $periodStats");

        // Convert to activity data - we'll use workout counts for the graph
        dayWorkouts.forEach((day, stats) {
          if (day >= 0 && day < newActivityData.length) {
            newActivityData[day] = (stats['count'] as int).toDouble();
          }
        });

        // Normalize the data (only if there's actual data)
        double maxValue = newActivityData.reduce((max, value) => max > value ? max : value);
        print("Max activity value: $maxValue");
        
        if (maxValue > 0) {
          for (var i = 0; i < newActivityData.length; i++) {
            newActivityData[i] = newActivityData[i] / maxValue;
          }
        }

        // Update state with real data
        setState(() {
          activityData[_selectedPeriod] = newActivityData;
          
          // Calculate average time per day
          double avgTimePerDay = 0.0;
          if (periodStats['totalDuration'] > 0) {
            avgTimePerDay = (periodStats['totalDuration'] as int).toDouble() / daysToShow;
          }
          
          _workoutStats = {
            'totalCalories': periodStats['totalCalories'],
            'totalWorkouts': periodStats['totalWorkouts'],
            'avgTimePerDay': avgTimePerDay,
          };
        });
        
        print("Updated activity data: ${activityData[_selectedPeriod]}");
        print("Updated workout stats: $_workoutStats");
      } else {
        print("No workout history found, using zeros");
        setState(() {
          activityData[_selectedPeriod] = newActivityData;
          _workoutStats = {
            'totalCalories': 0,
            'totalWorkouts': 0,
            'avgTimePerDay': 0.0,
          };
        });
      }
    } catch (e) {
      print("Error fetching workout stats: $e");
      setState(() {
        activityData[_selectedPeriod] = List.filled(
          _selectedPeriod == 'Weekly' ? 7 : DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day,
          0.0
        );
        _workoutStats = {
          'totalCalories': 0,
          'totalWorkouts': 0,
          'avgTimePerDay': 0.0,
        };
      });
    }
  }

  Future<void> _saveGoals(int workoutDays, int calorieGoal, int weeklyHours) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        print("Saving goals for user: $userId");
        await _database.ref('userGoals/$userId').update({
          'workoutDays': workoutDays,
          'calorieGoal': calorieGoal,
          'weeklyHours': weeklyHours,
        });
        print("Goals saved successfully");
        _fetchGoals(); // Refresh data after update
      } catch (e) {
        print("Error saving goals: $e");
      }
    }
  }

  Widget _buildGoalsCard() {
    int workoutDays = _userGoals['workoutDays'] ?? 7;
    int calorieGoal = _userGoals['calorieGoal'] ?? 5000;
    int weeklyHours = _userGoals['weeklyHours'] ?? 10;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Your Goals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    double workoutValue = workoutDays.toDouble();
                    double calorieValue = calorieGoal.toDouble();
                    double hoursValue = weeklyHours.toDouble();
                    
                    showDialog(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: const Text('Edit Goals'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Weekly Workout Days: ${workoutValue.round()}'),
                                  Slider(
                                    value: workoutValue,
                                    min: 1,
                                    max: 7,
                                    divisions: 6,
                                    onChanged: (value) {
                                      setState(() => workoutValue = value);
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Text('Weekly Hours: ${hoursValue.round()}'),
                                  Slider(
                                    value: hoursValue,
                                    min: 1,
                                    max: 10,
                                    divisions: 9,
                                    onChanged: (value) {
                                      setState(() => hoursValue = value);
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Text('Monthly Calorie Goal: ${calorieValue.round()}'),
                                  Slider(
                                    value: calorieValue,
                                    min: 1000,
                                    max: 5000,
                                    divisions: 40,
                                    onChanged: (value) {
                                      setState(() => calorieValue = value);
                                    },
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _saveGoals(
                                      workoutValue.round(),
                                      calorieValue.round(),
                                      hoursValue.round(),
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Save'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildGoalProgress('Weekly Workouts', workoutDays, 7, const Color(0xFF4285F4)),
            const SizedBox(height: 16),
            _buildGoalProgress('Weekly Hours', weeklyHours, 10, const Color(0xFF4285F4)),
            const SizedBox(height: 16),
            _buildGoalProgress('Monthly Calories', calorieGoal, 5000, const Color(0xFF4285F4)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Progress', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildPeriodSelector(),
              const SizedBox(height: 16),
              _buildActivityCard(),
              const SizedBox(height: 16),
              _buildMetricsRow(),
              const SizedBox(height: 16),
              _buildGoalsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        _periodButton('Weekly', _selectedPeriod == 'Weekly'),
        const SizedBox(width: 10),
        _periodButton('Monthly', _selectedPeriod == 'Monthly'),
      ],
    );
  }

  Widget _periodButton(String text, bool isSelected) {
    return ElevatedButton(
      onPressed: () => setState(() {
        _selectedPeriod = text;
        _fetchWorkoutStats();
      }),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF4285F4) : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      child: Text(text),
    );
  }

  Widget _buildActivityCard() {
    // Use local device time for determining today
    final now = DateTime.now();
    print("Building activity card with now: ${now.toString()}, weekday: ${now.weekday}");
    
    // Make sure we're using the correct weekday (1-7, where 1 is Monday)
    // This ensures Wednesday shows up as the 3rd day (index 2)
    final todayIndex = _selectedPeriod == 'Weekly' 
        ? now.weekday - 1  // 0 = Monday, 6 = Sunday
        : now.day - 1;     // 0-based day of month
        
    print("Today's index in graph: $todayIndex");

    final dataLength = _selectedPeriod == 'Weekly' 
        ? 7 
        : DateTime(now.year, now.month + 1, 0).day;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$_selectedPeriod Activity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: _selectedPeriod == 'Monthly' 
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(
                        dataLength,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: _buildActivityBar(
                            index < activityData[_selectedPeriod]!.length 
                                ? activityData[_selectedPeriod]![index] 
                                : 0.0,
                            index < periodLabels[_selectedPeriod]!.length 
                                ? periodLabels[_selectedPeriod]![index] 
                                : '$index',
                            index == todayIndex,
                          ),
                        ),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(
                      dataLength,
                      (index) => _buildActivityBar(
                        index < activityData[_selectedPeriod]!.length 
                            ? activityData[_selectedPeriod]![index] 
                            : 0.0,
                        index < periodLabels[_selectedPeriod]!.length 
                            ? periodLabels[_selectedPeriod]![index] 
                            : '$index',
                        index == todayIndex,
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityBar(double height, String label, bool isHighlighted) {
    final bool isMonthly = _selectedPeriod == 'Monthly';
    // Ensure minimum height so bars are always visible even if value is 0
    final double barHeight = height > 0 ? 120 * height : 2;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: isMonthly ? 20 : 30,
          height: barHeight,
          decoration: BoxDecoration(
            color: isHighlighted ? const Color(0xFF4285F4) : const Color(0xFFA4CAFB),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: isMonthly ? 20 : 30,
          child: Text(
            label, 
            style: TextStyle(
              fontSize: isMonthly ? 10 : 12,
              color: Colors.grey
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      children: [
        Expanded(child: _buildMetricCard('${_workoutStats['totalWorkouts']}', 'Workouts')),
        const SizedBox(width: 12),
        Expanded(child: _buildMetricCard('${_workoutStats['totalCalories']}', 'Calories')),
        const SizedBox(width: 12),
        Expanded(child: _buildMetricCard(
          _workoutStats['avgTimePerDay'].toStringAsFixed(1), 
          'Avg min/Day'
        )),
      ],
    );
  }

  Widget _buildMetricCard(String value, String label) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgress(String label, num target, num maxTarget, Color color) {
    num currentValue = 0;
    
    switch (label) {
      case 'Weekly Workouts':
        currentValue = _workoutStats['totalWorkouts'] ?? 0;
        break;
      case 'Monthly Calories':
        currentValue = _workoutStats['totalCalories'] ?? 0;
        break;
      case 'Weekly Hours':
        // Convert from minutes to hours
        currentValue = ((_workoutStats['avgTimePerDay'] ?? 0) * 7 / 60).toDouble();
        break;
    }

    final double progress = currentValue / target;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            color: color,
            backgroundColor: color.withOpacity(0.3),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text('$currentValue / $target', style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}