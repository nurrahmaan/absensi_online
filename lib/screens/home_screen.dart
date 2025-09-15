import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/server_connection_provider.dart';
import 'dashboard_screen.dart';
import 'absensi_screen.dart';
import 'daily_attendance_screen.dart';
import 'monthly_summary_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  const HomeScreen({required this.token, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  Timer? _serverSnackTimer;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(token: widget.token),
      AbsensiScreen(token: widget.token),
      DailyAttendanceScreen(token: widget.token),
      MonthlySummaryScreen(token: widget.token),
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _serverSnackTimer?.cancel();
    super.dispose();
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _showServerSnack(BuildContext context, bool connected) {
    final snackBar = SnackBar(
      content: Text(
        connected ? '✅ Terhubung ke server' : '⚠ Tidak terkoneksi ke server!',
      ),
      backgroundColor: connected ? Colors.green : Colors.redAccent,
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(12),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final serverProvider = Provider.of<ServerConnectionProvider>(context);

    // Show SnackBar kalau server disconnect
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!serverProvider.isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠ Tidak terkoneksi ke server!"),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 5),
          ),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: _screens[_currentIndex],
          ),

          // Overlay card kalau internet putus
          if (!serverProvider.hasInternet)
            Positioned(
              top: 20,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Tidak ada koneksi internet!",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF673AB7),
        selectedItemColor: Colors.lightBlueAccent,
        unselectedItemColor: Colors.white70,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_circle), label: 'Absen'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Harian'),
          BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart), label: 'Bulanan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
