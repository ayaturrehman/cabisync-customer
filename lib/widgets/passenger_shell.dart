import 'package:flutter/material.dart';

/// Visible passenger navigation; tabs are created on first visit and retained.
class PassengerShell extends StatefulWidget {
  const PassengerShell({super.key, required this.pages});
  final List<WidgetBuilder> pages;

  @override
  State<PassengerShell> createState() => _PassengerShellState();
}

class _PassengerShellState extends State<PassengerShell> {
  int _selected = 0;
  late final List<Widget?> _pages = List.filled(widget.pages.length, null);

  @override
  Widget build(BuildContext context) {
    _pages[_selected] ??= widget.pages[_selected](context);
    return Scaffold(
      body: IndexedStack(
        index: _selected,
        children:
            _pages.map((page) => page ?? const SizedBox.shrink()).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selected,
        onTap: (index) => setState(() => _selected = index),
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: const Color(0xFF777777),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
