import 'package:flutter/material.dart';
import '../ui/home_screen.dart';

void main() {
  runApp(const MorseVibrationApp());
}

class MorseVibrationApp extends StatelessWidget {
  const MorseVibrationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Morse Vibration App',
      home: HomeScreen(),
    );
  }
}
