import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:another_flushbar/flushbar.dart';

// Import screen yang benar
import '../absensi/dashboard_screen.dart';
import '../absensi/absensi_screen.dart';
import '../absensi/daily_attendance_screen.dart';
import '../absensi/monthly_summary_screen.dart';
import '../user/profile_screen.dart';
import '../auth/login_screen.dart';
import '../../providers/core/server_connection_provider.dart';

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
    // Pastikan hanya satu import DashboardScreen
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

  @override
  Widget build(BuildContext context) {
    final serverProvider = Provider.of<ServerConnectionProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!serverProvider.isConnected) {
        Flushbar(
          title: 'Koneksi Server Terputus',
          message:
              'Tidak dapat terhubung ke server. Mohon periksa jaringan Anda atau coba kembali nanti.',
          icon: const Icon(Icons.cloud_off, color: Colors.white),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.redAccent,
          margin: const EdgeInsets.all(12),
          borderRadius: BorderRadius.circular(12),
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: _screens[_currentIndex],
          ),
          if (!serverProvider.hasInternet)
            Positioned(
              top: 48,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red,
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
