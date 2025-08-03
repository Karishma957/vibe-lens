import 'package:battery_plus/battery_plus.dart';

class BatteryService {
  static final Battery _battery = Battery();

  static Future<String> getBatteryLevelText() async {
    final level = await _battery.batteryLevel;
    return level.toString();
  }
}
