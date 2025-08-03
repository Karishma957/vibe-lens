import 'package:intl/intl.dart';
import 'package:morse_vibration_app/core/morse_code.dart';
import 'package:morse_vibration_app/service/sos_service.dart';
import 'package:morse_vibration_app/service/temperature_service.dart';
import 'package:morse_vibration_app/service/battery_service.dart';

class GestureService {
  static Future<Map<String, String>> handleSingleTap() async {
    final now = DateTime.now();
    final formattedTime = DateFormat.Hm().format(now); // "HH:mm"
    final morse = MorseCode.textToMorse(formattedTime);
    return {'heading': 'Current Time', 'text': formattedTime, 'morse': morse};
  }

  static Future<Map<String, String>> handleSwipeUp() async {
    final tempText = await TemperatureService.getCurrentLocationTemperature();
    final morse = MorseCode.textToMorse(tempText);
    return {'heading': 'Temperature', 'text': tempText, 'morse': morse};
  }

  static Future<Map<String, String>> handleSwipeDown() async {
    final batteryText = await BatteryService.getBatteryLevelText();
    final morse = MorseCode.textToMorse(batteryText.toString());
    return {
      'heading': 'Battery Percentage',
      'text': batteryText,
      'morse': morse,
    };
  }

  static Future<Map<String, String>> handleSwipeLeft() async {
    final successful = await SosService.sendSos();
    return {
      'heading': 'Emergency SOS',
      'text': 'SOS',
      'morse': successful ? 'Successful' : 'Unsuccessful',
    };
  }

  static Future<Map<String, String>> handleSwipeRight() async {
    final now = DateTime.now();
    final formattedDate = DateFormat(
      'EEEE d MMM',
    ).format(now); // "Saturday 3 Aug"
    final morse = MorseCode.textToMorse(formattedDate);
    return {'heading': 'Date & Day', 'text': formattedDate, 'morse': morse};
  }
}
