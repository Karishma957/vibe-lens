import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class TemperatureService {
  static const String _apiKey = 'e51c33608445831ddb05a373330563d3';

  static Future<String> getTemperature(double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final temp = data['main']['temp'].round();
        return temp.toString();
      } else {
        return "32";
      }
    } catch (e) {
      return "32";
    }
  }

  static Future<String> getCurrentLocationTemperature() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      return await getTemperature(position.latitude, position.longitude);
    } catch (e) {
      return "32";
    }
  }
}
