import 'package:shared_preferences/shared_preferences.dart';

class CaregiverStorageService {
  static const _key = 'caregiver_number';
  static const _defaultNumber = '112'; // Emergency number

  static Future<void> setNumber(String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, number);
  }

  static Future<String> getNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? _defaultNumber;
  }

  static Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _defaultNumber);
  }
}
