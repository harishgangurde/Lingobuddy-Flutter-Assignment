Lingobuddy - Flutter Assignment

Candidate: Harish Gangurde

Submission Overview

This project implements the two required screens (Duel Screen and Result Screen) for the Flutter Development Internship assignment, focusing on high code quality, robust problem-solving, and precise replication of the required UI/UX and animation elements demonstrated in the video walkthrough.

The entire codebase is structured to be clean, maintainable, and fully functional.

Project Structure

The application follows a standard Flutter architecture with clear separation of concerns:

main.dart: Entry point and theme definition.

ai_duel_screen.dart: Manages the main game loop, timer logic, speech-to-text input, correctness check, and score calculation.

result_screen.dart: Manages result display, custom animations, confetti effect, scoreboard presentation, and game restart logic.

Problem-Solving Approach & Technical Details (Simplified)

Microphone Logic & Manual Input: The application uses the speech_to_text and permission_handler packages. Submission is intentionally triggered manually by the user pressing the send button, avoiding automatic submission for better control. (See: _startListening() in ai_duel_screen.dart).

UI/UX Stability (Keyboard Overflow Fix): To prevent the "Bottom Overflowed" error when the soft keyboard appears, the main screen content is wrapped in a SingleChildScrollView with minimum height constraints, ensuring the layout remains stable and centered.

Dynamic Score Logic: The AiDuelScreen calculates the correct score ('10' or '0') based on the user's input before navigating, ensuring the ResultScreen receives and displays the accurate result.

Avatar Cropping Fix: The second player's avatar is displayed correctly without being cropped inside the CircleAvatar boundary by using ClipOval and setting BoxFit.contain.

Game Flow and Restart: Navigator.pushReplacement is used consistently for all screen transitions (submission, time-out, and "Next" button) to prevent navigation stack buildup and ensure the game restarts cleanly.

Advanced UI/Animation Implementation (Bonus)

Custom Speech Bubble: The "Correct +10 Points" text features a visual speech bubble appearance with a downward-pointing tail, achieved using a custom SpeechBubblePainter class for precise shape control.

Animated Trophy: The trophy image implements a slow, smooth slide-up and fade-in animation over 1.5 seconds (using FadeTransition and SlideTransition) that triggers upon a correct answer, enhancing the sense of reward.

Confetti Effect: A short, impactful confetti explosion is triggered simultaneously with the correct answer.

Scoreboard Replication: The ResultScreen layout was meticulously updated to display the avatars, timer (00:00), and final score (10 or 0) as a scoreboard overview, mirroring the video demonstration.

How to Run the Project

Clone this repository.

Run flutter pub get in the terminal.

Ensure the necessary asset images (pirate.png, shinchan.png, trophy.png, cartoon2.png) are correctly placed in the project's assets/ directory and declared in pubspec.yaml.

Run the application using flutter run.