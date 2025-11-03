import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'result_screen.dart';

class AiDuelScreen extends StatefulWidget {
  const AiDuelScreen({super.key});

  @override
  State<AiDuelScreen> createState() => _AiDuelScreenState();
}

class _AiDuelScreenState extends State<AiDuelScreen> {
  final TextEditingController _controller = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  Timer? _timer;
  int _remainingSeconds = 30;
  // Note: Added _targetWord which was missing in the code snippet provided
  final String _targetWord = "goodbye";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speech.stop();
    _controller.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _remainingSeconds = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 0) {
        t.cancel();
        if (_isListening) {
          _stopListening();
        }

        // Pass final time/score for Time Up (0 points)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              text: "TIME_UP",
              finalTime: _formattedTime(),
              finalScore: '0',
            ),
          ),
        );
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  String _formattedTime() {
    final mins = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Future<void> _requestMicPermission() async {
    var status = await Permission.microphone.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      await Permission.microphone.request();
    }
  }

  Future<void> _startListening() async {
    await _requestMicPermission();

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (err) {
        debugPrint("Speech error: $err");
      },
    );

    if (!mounted) return;

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          final words = result.recognizedWords;
          setState(() {
            _recognizedText = words;
            _controller.text = _recognizedText;
          });
        },
        listenFor: const Duration(seconds: 20),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
      );
    } else {
      setState(() => _isListening = false);
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    if (!mounted) return;
    setState(() => _isListening = false);
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      if (_remainingSeconds <= 0) {
        _startCountdown();
      }
      _startListening();
    }
  }

  void _submit() {
    _timer?.cancel();
    if (_isListening) _stopListening();

    // 🎯 FIX 1: Determine the correct score based on the target word
    final bool isCorrect = _controller.text.trim().toLowerCase().contains(
      _targetWord.toLowerCase(),
    );
    final String score = isCorrect ? '10' : '0';

    // 🎯 FIX 2: Pass the dynamic score to the ResultScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          text: _controller.text.trim(),
          finalTime: _formattedTime(),
          finalScore: score,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the full screen height
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF011627),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Container(
              constraints: BoxConstraints(minHeight: screenHeight - 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // --- TOP HEADER ---
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "AI DUEL",
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[400],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Read or listen the word/sentence carefully.",
                        style: GoogleFonts.poppins(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  // --- AVATARS AND TIMER ---
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // 🎯 PLAYER 1 AVATAR (Man with beard - Assuming 'pirate.png')
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: const AssetImage(
                              "assets/shinchan.png",
                            ),
                          ),
                          Text(
                            _formattedTime(),
                            style: GoogleFonts.poppins(
                              color: Colors.greenAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // 🎯 PLAYER 2 AVATAR FIX (Boy in jacket - Assuming 'cartoon2.png' or 'shinchan.png')
                          // Using BoxFit.contain to prevent cropping
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: const Color.fromARGB(
                              255,
                              255,
                              255,
                              255,
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                "assets/cartoon2.png", // Use the correct asset name for the boy
                                fit: BoxFit.contain,
                                height: 56,
                                width: 56,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white24, thickness: 1),
                    ],
                  ),

                  // --- WORD BUBBLE ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEDED),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Alvida",
                      style: GoogleFonts.poppins(
                        color: Colors.red[800],
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // --- MIC BUTTON ---
                  GestureDetector(
                    onTap: _toggleListening,
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening
                            ? Colors.greenAccent
                            : const Color(0xFF06202A),
                        boxShadow: _isListening
                            ? [
                                BoxShadow(
                                  color: Colors.greenAccent.withOpacity(0.45),
                                  blurRadius: 30,
                                  spreadRadius: 6,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                        border: Border.all(
                          color: _isListening
                              ? Colors.greenAccent
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.mic,
                        size: 44,
                        color: _isListening ? Colors.black : Colors.white,
                      ),
                    ),
                  ),

                  // --- INPUT SECTION ---
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Text Field
                      TextField(
                        controller: _controller,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          hintText: "Type Instead....",
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF07232B),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ), // Small space before the button
                    ],
                  ),

                  // --- SUBMIT BUTTON ---
                  GestureDetector(
                    onTap: _submit,
                    child: Container(
                      width: 64,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
