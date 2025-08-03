import 'package:flutter/material.dart';

import 'package:morse_vibration_app/core/app_gesture.dart';
import 'package:morse_vibration_app/service/caregiver_storage_service.dart';
import 'package:morse_vibration_app/service/gesture_service.dart';
import 'package:morse_vibration_app/service/vibration_service.dart';
import 'package:morse_vibration_app/ui/morse_teacher_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _caregiverMode = false;
  bool _isBusy = false;
  String _currentMorse = '';
  String _currentText = '';
  String _currentHeading = '';
  final TextEditingController _controller = TextEditingController();
  String _savedCaregiverNumber = '';

  @override
  void initState() {
    super.initState();
    _loadCaregiverNumber();
  }

  void _loadCaregiverNumber() async {
    final saved = await CaregiverStorageService.getNumber();
    setState(() {
      _savedCaregiverNumber = saved;
      _controller.text = saved;
    });
  }

  void _saveCaregiverNumber() async {
    FocusScope.of(context).unfocus();
    await CaregiverStorageService.setNumber(_controller.text.trim());
    setState(() {
      _savedCaregiverNumber = _controller.text.trim();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Caregiver number saved')));
  }

  void _handleGesture(AppGesture gesture) async {
    if (_isBusy) return;

    setState(() {
      _isBusy = true;
    });

    Map<String, String> result = {};
    try {
      switch (gesture) {
        case AppGesture.singleTap:
          result = await GestureService.handleSingleTap();
          break;
        case AppGesture.scrollUp:
          result = await GestureService.handleSwipeUp();
          break;
        case AppGesture.scrollDown:
          result = await GestureService.handleSwipeDown();
          break;
        case AppGesture.swipeRight:
          result = await GestureService.handleSwipeRight();
          break;
        case AppGesture.swipeLeft:
          result = await GestureService.handleSwipeLeft();
          break;
      }

      setState(() {
        _currentHeading = result['heading'] ?? '';
        _currentText = result['text'] ?? '';
        _currentMorse = result['morse'] ?? '';
      });

      if (_currentText == 'SOS') {
        await VibrationService.vibrateSmsStatus(_currentMorse == 'Successful');
      } else {
        await VibrationService.vibrateMorse(_currentMorse);
      }
    } catch (e) {
      print('Gesture error: $e');
    } finally {
      setState(() {
        _currentHeading = '';
        _currentMorse = '';
        _isBusy = false;
      });
    }
  }

  void _toggleCaregiverMenu() {
    setState(() {
      _caregiverMode = !_caregiverMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Important for transparency
      backgroundColor: Colors.transparent, // Body background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_book, color: Colors.deepPurple, size: 30,),
          tooltip: 'Caregiver Guide',
          onPressed: _toggleCaregiverMenu,
        ),
        title: const Text(
          'VibeLens',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: Colors.deepPurple,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0c3fc), Color(0xFF8ec5fc)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _handleGesture(AppGesture.singleTap),
                onPanUpdate: (details) {
                  final dx = details.delta.dx;
                  final dy = details.delta.dy;
                  if (dx.abs() > dy.abs()) {
                    if (dx > 10)
                      _handleGesture(AppGesture.swipeRight);
                    else if (dx < -10)
                      _handleGesture(AppGesture.swipeLeft);
                  } else {
                    if (dy > 10)
                      _handleGesture(AppGesture.scrollDown);
                    else if (dy < -10)
                      _handleGesture(AppGesture.scrollUp);
                  }
                },
                child: SizedBox.expand(
                  child: Column(
                    children: [
                      const SizedBox(height: 64),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child:
                                    (_currentHeading.isEmpty &&
                                        _currentText.isEmpty &&
                                        _currentMorse.isEmpty)
                                    ? Container(
                                        key: const ValueKey('idle'),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 32,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.95),
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.deepPurple
                                                  .withOpacity(0.1),
                                              blurRadius: 18,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(
                                              Icons.touch_app,
                                              size: 42,
                                              color: Color(0xFF6A4FB6),
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              "Welcome 👋",
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Quicksand',
                                                color: Color(0xFF6A4FB6),
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              "Tap or swipe to begin",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Quicksand',
                                                color: Color(0xFF6A4FB6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Column(
                                        key: ValueKey(
                                          _currentHeading +
                                              _currentText +
                                              _currentMorse,
                                        ),
                                        children: [
                                          if (_currentHeading.isNotEmpty)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 12,
                                                  ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 12,
                                                      offset: const Offset(
                                                        0,
                                                        4,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                padding: const EdgeInsets.all(
                                                  16,
                                                ),
                                                child: Column(
                                                  children: [
                                                    Icon(
                                                      Icons.info,
                                                      color: Color(0xFF6A4FB6),
                                                      size: 28,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      _currentHeading,
                                                      style: const TextStyle(
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontFamily: 'Quicksand',
                                                        color: Color(
                                                          0xFF6A4FB6,
                                                        ),
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          if (_currentText.isNotEmpty)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 8,
                                                  ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFFBEAFF),
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.purple
                                                          .withOpacity(0.15),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        4,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                padding: const EdgeInsets.all(
                                                  14,
                                                ),
                                                child: Text(
                                                  _currentText,
                                                  style: const TextStyle(
                                                    fontSize: 22,
                                                    color: Color(0xFF6A4FB6),
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'Quicksand',
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          if (_currentMorse.isNotEmpty)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 8,
                                                  ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                  border: Border.all(
                                                    color: Colors.purpleAccent,
                                                    width: 1.2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors
                                                          .deepPurpleAccent
                                                          .withOpacity(0.1),
                                                      blurRadius: 10,
                                                      offset: const Offset(
                                                        0,
                                                        4,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                      horizontal: 20,
                                                    ),
                                                child: Text(
                                                  _currentMorse,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: 'FiraMono',
                                                    letterSpacing: 2,
                                                    color: Color(0xFF6A4FB6),
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_caregiverMode)
                AnimatedOpacity(
                  opacity: _caregiverMode ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    color: Colors.deepPurple[100]?.withOpacity(0.95),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purpleAccent.withOpacity(0.25),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 40.0,
                              ),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Center(
                                      child: Text(
                                        '🧑‍🦯 Caregiver Guide',
                                        style: TextStyle(
                                          color: Color(0xFF6A4FB6),
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Quicksand',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    const Text(
                                      '📖 Gestures:',
                                      style: TextStyle(
                                        color: Color(0xFF6A4FB6),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Quicksand',
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      '• 👆 Single Tap: Current Time\n'
                                      '• 🔼 Swipe Up: Temperature\n'
                                      '• 🔽 Swipe Down: Battery\n'
                                      '• ⬅️ Swipe Left: Emergency SOS\n'
                                      '• ➡️ Swipe Right: Date & Day',
                                      style: TextStyle(
                                        color: Color(0xFF6A4FB6),
                                        fontSize: 18,
                                        height: 1.5,
                                        fontFamily: 'Quicksand',
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Center(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            PageRouteBuilder(
                                              pageBuilder:
                                                  (context, animation, _) =>
                                                      const MorseTeacherScreen(),
                                              transitionsBuilder:
                                                  (
                                                    context,
                                                    animation,
                                                    _,
                                                    child,
                                                  ) {
                                                    final tween = Tween(
                                                      begin: 0.0,
                                                      end: 1.0,
                                                    );
                                                    return FadeTransition(
                                                      opacity: animation.drive(
                                                        tween,
                                                      ),
                                                      child: child,
                                                    );
                                                  },
                                              transitionDuration:
                                                  const Duration(
                                                    milliseconds: 400,
                                                  ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.school),
                                        label: const Text("📚 Learn Morse"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.deepPurple,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 28),
                                    const Text(
                                      '📞 Caregiver Number',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF6A4FB6),
                                        fontFamily: 'Quicksand',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _controller,
                                            keyboardType: TextInputType.phone,
                                            decoration: InputDecoration(
                                              hintText: 'Enter number',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10,
                                                  ),
                                              filled: true,
                                              fillColor: Colors.purple[50],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.save),
                                          label: const Text('Save'),
                                          onPressed: _saveCaregiverNumber,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.deepPurple,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                color: Colors.deepPurple,
                                tooltip: 'Close',
                                onPressed: _toggleCaregiverMenu,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
