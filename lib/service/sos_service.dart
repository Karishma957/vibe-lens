import 'package:geolocator/geolocator.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:morse_vibration_app/service/caregiver_storage_service.dart';

class SosService {
  static Future<bool> sendSos() async {
    final caregiverNumber = await CaregiverStorageService.getNumber();
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      String message =
          "SOS! Location: https://maps.google.com/?q=${position.latitude},${position.longitude}";
      await sendSMS(message: message, recipients: [caregiverNumber]);
    } catch (e) {
      print("SOS Location unavailable: $e");
    }

    return true;
  }
}
