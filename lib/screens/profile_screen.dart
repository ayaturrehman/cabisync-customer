// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../widgets/main_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainScaffold(
      title: 'Profile',
      body: Center(child: Text('User profile')),
    );
  }
}
