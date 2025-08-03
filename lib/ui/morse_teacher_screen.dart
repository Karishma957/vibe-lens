import 'package:flutter/material.dart';
import 'package:morse_vibration_app/core/morse_code.dart';
import 'package:morse_vibration_app/service/vibration_service.dart';

class MorseTeacherScreen extends StatelessWidget {
  const MorseTeacherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final morseMap = MorseCode.morseMap;
    final sortedKeys = morseMap.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Learn Morse Code'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEEE7F7), Color(0xFFD3CFEA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            const Text(
              '🔤 Each letter has a unique vibration pattern.\n'
              '• Dots (.) are short.\n'
              '• Dashes (-) are long.\n\n'
              'Tap any letter to feel its pattern! 💡',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Quicksand',
                color: Color(0xFF5A3E9C),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: sortedKeys.map((key) {
                final morse = morseMap[key]!;
                return GestureDetector(
                  onTap: () async {
                    await VibrationService.vibrateMorse(morse);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("🔔 Vibrating '$key' in Morse"),
                        duration: const Duration(milliseconds: 800),
                        backgroundColor: Colors.deepPurple.shade300,
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 80,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          key,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A4FB6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          morse,
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'FiraMono',
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
