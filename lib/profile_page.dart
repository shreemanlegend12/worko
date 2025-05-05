import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_page.dart';
import 'providers/avatar_provider.dart';
import 'providers/user_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final avatarProvider = Provider.of<AvatarProvider>(context);

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _StatColumn(count: "48", label: "Workouts"),
                  _StatColumn(count: "124", label: "Following"),
                  _StatColumn(count: "85", label: "Followers"),
                ],
              ),
              const SizedBox(height: 30),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String count;
  final String label;

  const _StatColumn({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
