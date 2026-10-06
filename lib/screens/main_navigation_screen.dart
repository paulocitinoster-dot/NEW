import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'recurring_bills_screen.dart';
import 'credit_cards_screen.dart';
import 'vehicle_screen.dart';
import 'investments_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final String familyId;

  const MainNavigationScreen({super.key, required this.familyId});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(familyId: widget.familyId),
      RecurringBillsScreen(familyId: widget.familyId),
      CreditCardsScreen(familyId: widget.familyId),
      VehicleScreen(familyId: widget.familyId),
      InvestmentsScreen(familyId: widget.familyId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11);
            }
            return const TextStyle(color: Colors.grey, fontSize: 11);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF1E293B),
          indicatorColor: const Color(0xFF2563EB).withOpacity(0.25),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, color: Colors.grey),
              selectedIcon: Icon(Icons.dashboard_rounded, color: Color(0xFF60A5FA)),
              label: 'Início',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_repeat_outlined, color: Colors.grey),
              selectedIcon: Icon(Icons.event_repeat_rounded, color: Color(0xFFF59E0B)),
              label: 'Contas',
            ),
            NavigationDestination(
              icon: Icon(Icons.credit_card_outlined, color: Colors.grey),
              selectedIcon: Icon(Icons.credit_card_rounded, color: Color(0xFF8B5CF6)),
              label: 'Cartões',
            ),
            NavigationDestination(
              icon: Icon(Icons.directions_car_outlined, color: Colors.grey),
              selectedIcon: Icon(Icons.directions_car_rounded, color: Color(0xFF60A5FA)),
              label: 'Veículos',
            ),
            NavigationDestination(
              icon: Icon(Icons.trending_up_outlined, color: Colors.grey),
              selectedIcon: Icon(Icons.trending_up_rounded, color: Color(0xFF10B981)),
              label: 'Investir',
            ),
          ],
        ),
      ),
    );
  }
}
