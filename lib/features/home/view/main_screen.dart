import 'package:flutter/material.dart';
import '../../donation_flow/view/donation_flow_page.dart';
import '../../emergency_requests/view/emergency_requests_page.dart';
import '../../stock_tracker/view/blood_stock_page.dart';

/// Damla Ana Ekranı (Bağış Akışı, Stok Takibi ve Acil Talepler Bölümleri)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    DonationFlowPage(),
    BloodStockPage(),
    EmergencyRequestsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop_rounded),
            label: 'Bağış Akışı',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Stok Takibi',
          ),
          NavigationDestination(
            icon: Icon(Icons.emergency_outlined),
            selectedIcon: Icon(Icons.emergency_rounded),
            label: 'Acil Talepler',
          ),
        ],
      ),
    );
  }
}
