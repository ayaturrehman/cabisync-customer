import 'package:flutter/material.dart';
import '../../widgets/passenger_shell.dart';
import '../booking/ride_history_screen.dart';
import '../profile/profile_screen.dart';
import 'map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PassengerShell(
      pages: [
        (_) => const MapScreen(),
        (_) => const RideHistoryScreen(),
        (_) => const ProfileScreen(),
      ],
    );
  }
}
