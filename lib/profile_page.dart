import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_page.dart';
import 'providers/avatar_provider.dart';
import 'providers/user_provider.dart';
import 'providers/workout_provider.dart';
import 'upgrade_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<AvatarProvider>().initializeAvatar();
    // Refresh user data when profile page loads
    context.read<UserProvider>().refreshUser();
  }

  Future<void> _navigateToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  Widget _buildPremiumCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF4285F4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upgrade to Premium',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Get access to advanced workout programs and exclusive features',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UpgradePage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4285F4),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            ),
            child: const Text(
              'View Plans',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarProvider = Provider.of<AvatarProvider>(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Profile",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: _navigateToSettings,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListenableBuilder(
                listenable: avatarProvider,
                builder: (context, child) {
                  return CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: avatarProvider.currentAvatar != null
                        ? AssetImage(avatarProvider.currentAvatar!)
                        : null,
                    child: avatarProvider.currentAvatar == null
                        ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                        : null,
                  );
                },
              ),
              const SizedBox(height: 10),
              // Use Consumer to listen for UserProvider changes
              Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  return Text(
                    userProvider.user?.displayName ?? "User",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  );
                },
              ),
              const SizedBox(height: 20),
              if (!workoutProvider.isPremium) _buildPremiumCard(),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Text(
                    "Achievements",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.emoji_events, size: 20, color: Colors.blue),
                ],
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: Icon(Icons.local_fire_department, color: Colors.orange, size: 30),
                  title: Text("7-Day Streak", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Completed workouts for 7 consecutive days\nAug 15, 2023"),
                  trailing: Icon(Icons.share),
                  isThreeLine: true,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
