import 'package:flutter/material.dart';
import 'package:inteli_rehab/features/onboarding/splash_screen.dart';
import 'package:inteli_rehab/features/exercise/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const InteliRehabApp());
}

class InteliRehabApp extends StatelessWidget {
  const InteliRehabApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.tealCore,
        primary: AppColors.tealCore,
        secondary: const Color(0xFF0D9488),
        surface: Colors.white,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'INTELI-REHAB',
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
      ),
      home: const SplashScreen(),
    );
  }
}
