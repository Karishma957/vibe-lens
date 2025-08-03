import 'package:vibration/vibration.dart';
import 'dart:async';

class VibrationService {
  static Future<void> vibrateMorse(String morseCode) async {
    for (var symbol in morseCode.split('')) {
      if (symbol == '.') {
        // Dot: short vibration
        await Vibration.vibrate(duration: 200);
        await Future.delayed(const Duration(milliseconds: 400));
      } else if (symbol == '-') {
        // Dash: longer vibration
        await Vibration.vibrate(duration: 600);
        await Future.delayed(const Duration(milliseconds: 500));
      } else if (symbol == ' ') {
        // Space between letters
        await Future.delayed(const Duration(milliseconds: 1000));
      } else {
        // Unknown or word gap
        await Future.delayed(const Duration(milliseconds: 1500));
      }
    }
  }

  static Future<void> vibrateSmsStatus(bool smsSent) async {
    if (smsSent) {
      // Single short vibration for success
      await Vibration.vibrate(duration: 200);
    } else {
      // Long vibration for failure
      await Vibration.vibrate(duration: 800);
    }
  }
}
