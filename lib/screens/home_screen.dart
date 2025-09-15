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
  bool _showBanner = true;

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

  void _autoHideBanner() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showBanner = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final serverProvider = Provider.of<ServerConnectionProvider>(context);

    // Reset banner tiap kali status berubah
    if (serverProvider.isConnected && _showBanner) {
      _autoHideBanner();
    }
    if (!serverProvider.isConnected && !_showBanner) {
      setState(() {
        _showBanner = true;
      });
    }

    return Scaffold(
      body: Column(
        children: [
          AnimatedSlide(
            offset: _showBanner ? Offset.zero : const Offset(0, -1),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: _showBanner ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: Container(
                width: double.infinity,
                color: serverProvider.isConnected
                    ? Colors.green
                    : Colors.redAccent,
                padding: const EdgeInsets.all(8),
                child: Text(
                  serverProvider.isConnected
                      ? '✅ Terhubung ke server'
                      : '⚠ Tidak terkoneksi ke server!',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Expanded(child: _screens[_currentIndex]),
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
