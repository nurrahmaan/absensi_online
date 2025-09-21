// lib/utils/time_of_day_extension.dart
import 'package:flutter/material.dart';

extension TimeOfDayExtension on TimeOfDay {
  /// Mengembalikan format 24 jam seperti "14:30"
  String format24Hour() {
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }
}
