import 'package:absensi_online/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/login_provider.dart';
import 'providers/server_connection_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ServerConnectionProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Absensi Online',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: const SplashOrLogin(),
      ),
    );
  }
}

/// Widget untuk menentukan apakah token sudah tersimpan.
/// Jika ada token valid, langsung ke Dashboard. Kalau tidak, ke LoginScreen.
class SplashOrLogin extends StatefulWidget {
  const SplashOrLogin({super.key});

  @override
  State<SplashOrLogin> createState() => _SplashOrLoginState();
}

class _SplashOrLoginState extends State<SplashOrLogin> {
  bool _checking = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final token = await loginProvider.getSavedToken();
    setState(() {
      _token = token;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_token != null && _token!.isNotEmpty) {
      return HomeScreen(token: _token!);
    }

    return const LoginScreen();
  }
}
