import 'package:flutter/material.dart';

class MonthlySummaryScreen extends StatelessWidget {
  final String token;
  const MonthlySummaryScreen({required this.token, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Monthly Summary Screen\nToken: $token',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
