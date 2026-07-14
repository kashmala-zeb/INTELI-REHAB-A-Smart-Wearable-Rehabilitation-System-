import 'package:flutter/material.dart';
import 'package:inteli_rehab/presentation/onboarding/splash/splash_screen.dart';
import 'package:inteli_rehab/presentation/onboarding/wait_screen.dart';
import 'package:inteli_rehab/presentation/onboarding/onboarding_calibration.dart';
import 'package:inteli_rehab/presentation/onboarding/login/login_screen.dart';
import 'package:inteli_rehab/presentation/home/home_dashboard.dart';
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INTELI-REHAB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/wait_screen': (context) => const WaitScreen(),
        '/calibration_onboarding': (context) => const OnboardingCalibrationScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeDashboardScreen(),
      },
    );
  }
}
