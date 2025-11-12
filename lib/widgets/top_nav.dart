// lib/widgets/top_nav.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class TopNav extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const TopNav({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return AppBar(
      leading: Builder(
        builder:
            (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
      ),
      title: Text(title),
      actions: [
        TextButton(
          onPressed:
              () => Navigator.of(context).pushReplacementNamed('/booking'),
          child: const Text('Booking', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed('/profile'),
          child: const Text('Profile', style: TextStyle(color: Colors.white)),
        ),
        if (auth.user != null)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
