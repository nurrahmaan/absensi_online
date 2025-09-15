import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/server_connection_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ServerConnectionProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Absensi Online',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      // default screen login, nanti sukses login → ke HomeScreen(token: ...)
      home: const LoginScreen(),
    );
  }
}
