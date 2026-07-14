import 'package:flutter/material.dart';
import 'package:inteli_rehab/core/constants/app_colors.dart';
import 'dart:async';

class WaitScreen extends StatefulWidget {
  const WaitScreen({super.key});

  @override
  State<WaitScreen> createState() => _WaitScreenState();
}

class _WaitScreenState extends State<WaitScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  int _currentTextIndex = 0;
  
  final List<String> _loadingTexts = [
    'Finalizing patient profile...',
    'Securely sending data to the cloud...',
    'Awaiting Physiotherapist Approval...',
    'Your rehabilitation plan has been assigned!'
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _cycleText();
  }

  void _cycleText() async {
    for (int i = 0; i < _loadingTexts.length; i++) {
      if (!mounted) return;
      setState(() {
        _currentTextIndex = i;
      });
      await Future.delayed(const Duration(milliseconds: 2000));
    }
    
    // After all texts, simulate approval and go straight to login
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.tealLight,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.teal.withValues(alpha: 0.2 + 0.3 * _pulseController.value),
                          blurRadius: 30 * _pulseController.value,
                          spreadRadius: 10 * _pulseController.value,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _currentTextIndex == _loadingTexts.length - 1 ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                        size: 50,
                        color: AppColors.teal,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),
              Text(
                'Approval Pending',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate800,
                ),
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _loadingTexts[_currentTextIndex],
                  key: ValueKey<int>(_currentTextIndex),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.slate600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              if (_currentTextIndex < _loadingTexts.length - 1)
                SizedBox(
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      backgroundColor: AppColors.slate200,
                      color: AppColors.teal,
                      minHeight: 6,
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
