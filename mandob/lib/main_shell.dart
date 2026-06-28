import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'المنتجات'),
          BottomNavigationBarItem(icon: Icon(Icons.add_shopping_cart), label: 'بيع جديد'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'العملاء'),
          BottomNavigationBarItem(icon: Icon(Icons.money_off), label: 'المصروفات'),
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/products')) return 1;
    if (location.startsWith('/invoices')) return 2;
    if (location.startsWith('/customers')) return 3;
    if (location.startsWith('/expenses')) return 4;
    return 0; // Default to Dashboard
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/products');
        break;
      case 2:
        context.go('/invoices');
        break;
      case 3:
        context.go('/customers');
        break;
      case 4:
        context.go('/expenses');
        break;
    }
  }
}
