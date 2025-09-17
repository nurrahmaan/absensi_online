import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  final String token;
  const MoreScreen({required this.token, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Daily Attendance Screen\nToken: $token',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
