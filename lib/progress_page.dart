import 'package:flutter/material.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  String _selectedPeriod = 'Weekly';

  // Sample data for activity
  final Map<String, List<double>> activityData = {
    'Weekly': [0.4, 0.3, 0.8, 0.0, 0.2, 0.5, 0.4],
    'Monthly': [0.6, 0.4, 0.7, 0.3, 0.8, 0.2, 0.5, 0.9, 0.4, 0.6, 0.3, 0.7],
  };
  final Map<String, List<String>> periodLabels = {
    'Weekly': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    'Monthly': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
      onPressed: () {
        setState(() {
          _selectedPeriod = text;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF4285F4) : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      child: Text(text),
    );
  }

  Widget _buildActivityCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_selectedPeriod Activity',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  activityData[_selectedPeriod]!.length,
                  (index) => _buildActivityBar(
                    activityData[_selectedPeriod]![index],
                    periodLabels[_selectedPeriod]![index],
                    index == 2, // Highlight Wednesday for weekly, March for monthly
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: _selectedPeriod == 'Weekly' ? 30 : 20,
          height: 120 * height,
          decoration: BoxDecoration(
            color: isHighlighted
                ? const Color(0xFF4285F4)
                : const Color(0xFFA4CAFB),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard('18', 'Workouts'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard('4500', 'Calories'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard('2.6', 'Avg/Day'),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String value, String label) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Goals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildGoalProgress(
              'Weekly Workouts',
              5,
              7,
              const Color(0xFF4285F4),
            ),
            const SizedBox(height: 16),
            _buildGoalProgress(
              'Weight Goal',
              165,
              160,
              Colors.amber,
            ),
            const SizedBox(height: 16),
            _buildGoalProgress(
              'Monthly Calories',
              4200,
              5000,
              const Color(0xFF4285F4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgress(
      String label, num current, num target, Color progressColor) {
    final double progress = (current / target).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$current of $target ${label.contains('Weight') ? 'lbs' : label.contains('Calories') ? 'cal' : 'days'}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            color: progressColor,
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}