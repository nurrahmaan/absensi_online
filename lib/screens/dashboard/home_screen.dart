import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/core/server_connection_provider.dart';
import '../../providers/auth/user_provider.dart';
import '../absensi/absensi_screen.dart';
import '../absensi/history_screen.dart';
import '../extra/more_screen.dart';
import '../user/profile_screen.dart';
import '../auth/login_screen.dart';
import 'dashboard_screen.dart';
import 'package:another_flushbar/flushbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens = [];
  Timer? _serverSnackTimer;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUserProfile();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    setState(() {
      _screens = [
        DashboardScreen(token: token),
        AbsensiScreen(token: token),
        HistoryScreen(token: token),
        MoreScreen(token: token),
        ProfileScreen(token: token),
      ];
      _loadingProfile = false;
    });
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

  void _updateStatusBarFromContext(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      statusBarBrightness:
          brightness == Brightness.dark ? Brightness.dark : Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final serverProvider = Provider.of<ServerConnectionProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateStatusBarFromContext(context);
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

    if (_loadingProfile || _screens.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(child: _screens[_currentIndex]),
          if (!serverProvider.hasInternet)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 16,
                  right: 16,
                  bottom: 12,
                ),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: const Row(
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
              icon: Icon(Icons.location_on_rounded), label: 'Absen'),
          BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Extra'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
