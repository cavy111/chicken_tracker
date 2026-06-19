import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({required this.currentIndex, super.key});

  static const _routes = ['/batches', '/feed', '/withdrawals', '/settings'];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.egg), label: 'Batches'),
        BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Feed'),
        BottomNavigationBarItem(
            icon: Icon(Icons.payments_outlined), label: 'Withdrawals'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      onTap: (index) {
        if (index != currentIndex) {
          context.go(_routes[index]);
        }
      },
    );
  }
}
