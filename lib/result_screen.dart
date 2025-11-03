import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'ai_duel_screen.dart';

class ResultScreen extends StatefulWidget {
  final String text;
  final String finalTime;
  final String finalScore;

  const ResultScreen({
    super.key,
    required this.text,
    this.finalTime = '00:00',
    required this.finalScore,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  final String _correctAnswer = 'goodbye';
  late ConfettiController _confettiController;
  late bool _isCorrect;

  // Animation controllers and values for the trophy
  late AnimationController _cartoonController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // The core correctness check remains based on the 'text' property
    _isCorrect = widget.text.trim().toLowerCase() == _correctAnswer;

    // --- Confetti Initialization ---
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 750),
    );
    if (_isCorrect) {
      _confettiController.play();
    }

    _cartoonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _cartoonController, curve: Curves.easeOut),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_cartoonController);

    if (_isCorrect) {
      _cartoonController.forward();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _cartoonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String pointsText = _isCorrect ? "+10 Points" : "0 Points";

    return Scaffold(
      backgroundColor: const Color(0xFF011627),
      body: SafeArea(
        child: Stack(
          children: [
            // Confetti animation layer
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                emissionFrequency: 0.0,
                numberOfParticles: 100,
                gravity: 0.0,
                maxBlastForce: 40,
                minBlastForce: 20,
                colors: const [Colors.yellow, Colors.amberAccent, Colors.white],
              ),
            ),

            // Main Content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "AI DUEL",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow[700],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- AVATAR AND SCORE ROW (SCOREBOARD) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: const AssetImage(
                            "assets/shinchan.png",
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              widget.finalTime,
                              style: GoogleFonts.poppins(
                                color: Colors.greenAccent,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.finalScore,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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
                              "assets/cartoon2.png",
                              fit: BoxFit.contain,
                              height: 56,
                              width: 56,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Divider(color: Colors.white24, thickness: 1),
                    const SizedBox(height: 40),

                    // --- SPEECH BUBBLE GROUP ---
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. Main Result Container
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: _isCorrect
                                ? Colors.green
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: _isCorrect
                                ? null
                                : Border.all(color: Colors.white24, width: 1),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _isCorrect ? "Correct" : "Try Again",
                                style: GoogleFonts.poppins(
                                  color: _isCorrect
                                      ? Colors.white
                                      : Colors.redAccent,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                pointsText,
                                style: GoogleFonts.poppins(
                                  color: _isCorrect
                                      ? Colors.white70
                                      : Colors.white70,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 2. Speech Bubble Tail
                        if (_isCorrect)
                          Padding(
                            padding: const EdgeInsets.only(top: 1.0),
                            child: CustomPaint(
                              size: const Size(20, 10),
                              painter: SpeechBubblePainter(
                                bubbleColor: Colors.green,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Animated Trophy
                    if (_isCorrect)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Image.asset('assets/cartoon.png', height: 180),
                        ),
                      ),

                    // Space to keep the button centered
                    SizedBox(height: _isCorrect ? 90 : 190),

                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AiDuelScreen(),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 60,
                          vertical: 15,
                        ),
                      ),
                      child: Text(
                        "Next",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTER CLASS ---

class SpeechBubblePainter extends CustomPainter {
  final Color bubbleColor;

  SpeechBubblePainter({required this.bubbleColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = bubbleColor
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
