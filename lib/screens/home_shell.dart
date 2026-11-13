import 'package:flutter/material.dart';
import '../widgets/add_measurement_sheet.dart';
import 'connect_device_page.dart';
import 'dashboard_page.dart';
import 'settings_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  int _refresh = 0; // dinaikkan setelah alur pengukuran supaya Dashboard memuat ulang

  Future<void> _startDeviceFlow() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ConnectDevicePage()),
    );
    if (mounted) setState(() => _refresh++);
  }

  void _openAddSheet() =>
      showAddMeasurementSheet(context, onDevice: _startDeviceFlow);

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardPage(key: ValueKey(_refresh), onMeasure: _startDeviceFlow),
      const Center(child: Text('Laporan')),
      const Center(child: Text('Segera hadir')), // Produk: tidak ada mockup
      const SettingsPage(),
    ];

    return Scaffold(
      body: pages[_index],
      floatingActionButton: _index <= 1
          ? FloatingActionButton(
        onPressed: _openAddSheet,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Laporan'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Produk'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
      ),
    );
  }
}