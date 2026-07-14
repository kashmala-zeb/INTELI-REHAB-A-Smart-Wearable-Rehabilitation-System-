import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inteli_rehab/core/constants/app_colors.dart';
import 'package:inteli_rehab/core/constants/onboarding_constants.dart';
import 'package:inteli_rehab/domain/entities/patient.dart';
import 'package:inteli_rehab/presentation/onboarding/notification_permission/notification_permission_screen.dart';

class PatientProfileSetupScreen extends StatefulWidget {
  const PatientProfileSetupScreen({super.key});

  @override
  State<PatientProfileSetupScreen> createState() => _PatientProfileSetupScreenState();
}

class _PatientProfileSetupScreenState extends State<PatientProfileSetupScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0; // Steps 0 to 7 (8 total steps)

  // Recovery Setup State Model
  final RecoverySetupModel _setupModel = RecoverySetupModel();

  // Input Controllers for Optional Fields
  final TextEditingController _therapistCodeController = TextEditingController(text: OnboardingConstants.defaultTherapistCode);
  bool _hasAvatar = true;

  // Weekday selection list for custom schedule
  final List<String> _weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  // Animation States
  bool _isSaving = false;
  late final AnimationController _submitScaleController;
  late final Animation<double> _submitScale;

  @override
  void initState() {
    super.initState();
    
    // Initialize model with defaults for instant preview verification
    _setupModel.affectedArm = OnboardingConstants.defaultAffectedArm;
    _setupModel.rehabArea = OnboardingConstants.defaultPrimaryRehabArea;
    _setupModel.recoveryStage = OnboardingConstants.defaultRecoveryStage;
    _setupModel.therapistAssigned = true;
    _setupModel.therapistCode = OnboardingConstants.defaultTherapistCode;
    _setupModel.exerciseFrequency = "5 Days/Week";
    _setupModel.selectedDays = ["Mon", "Wed", "Fri"];
    _setupModel.reminderTime = "Morning (8:00 AM)";
    _setupModel.profilePhoto = OnboardingConstants.defaultProfileImagePath;

    _submitScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _submitScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _submitScaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _therapistCodeController.dispose();
    _submitScaleController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < 7) {
      _pageController.animateToPage(
        _currentStep + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      _pageController.animateToPage(
        _currentStep - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _handleCompleteProfile() async {
    _submitScaleController.forward().then((_) => _submitScaleController.reverse());
    HapticFeedback.mediumImpact();

    setState(() {
      _isSaving = true;
    });

    // Save final code value
    if (_setupModel.therapistAssigned == true) {
      _setupModel.therapistCode = _therapistCodeController.text;
    }

    // Simulate HIPAA profile commit
    await Future.delayed(const Duration(milliseconds: 1400));

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      // Route to Notification Permission Screen
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const NotificationPermissionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  // Check if current page selection has been completed (disables Continue button otherwise)
  bool _isStepValid() {
    switch (_currentStep) {
      case 0:
        return _setupModel.affectedArm != null;
      case 1:
        return _setupModel.rehabArea != null;
      case 2:
        return _setupModel.recoveryStage != null;
      case 3:
        if (_setupModel.therapistAssigned == null) return false;
        if (_setupModel.therapistAssigned == true) {
          return _therapistCodeController.text.trim().isNotEmpty;
        }
        return true;
      case 4:
        if (_setupModel.exerciseFrequency == null) return false;
        if (_setupModel.exerciseFrequency == "Custom") {
          return _setupModel.selectedDays.isNotEmpty;
        }
        return true;
      case 5:
        return _setupModel.reminderTime != null;
      case 6:
        return true; // Avatar photo is optional
      case 7:
        return true; // Summary review step
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 720;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background soft radial highlight
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealCore.withValues(alpha: 0.03),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF14B8A6).withValues(alpha: 0.03),
              ),
            ),
          ),
          // Safe Area Layout
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(), // Enforce non-scrollable page viewport
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxHeight: isSmallScreen ? 680 : 760),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Header Section with Back, Progress, and Skip
                      _buildHeader(isSmallScreen),

                      // Card Container carrying Step Views
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: const BorderSide(
                                color: Color(0xFFE2E8F0),
                                width: 1.5,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: PageView(
                                controller: _pageController,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  _buildAffectedArmPage(isSmallScreen),
                                  _buildRehabAreaPage(isSmallScreen),
                                  _buildRecoveryStagePage(isSmallScreen),
                                  _buildTherapistPage(isSmallScreen),
                                  _buildExerciseSchedulePage(isSmallScreen),
                                  _buildReminderTimePage(isSmallScreen),
                                  _buildAlmostReadyPage(isSmallScreen),
                                  _buildRecoverySummaryPage(isSmallScreen),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Bottom Action Buttons
                      _buildBottomControls(isSmallScreen),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Commit Saving progress overlay indicator
          if (_isSaving) _buildSavingOverlay(),
        ],
      ),
    );
  }

  // --- Header Layout ---
  Widget _buildHeader(bool isSmallScreen) {
    final double progress = (_currentStep + 1) / 8.0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Button
            if (_currentStep > 0)
              GestureDetector(
                onTap: _previousPage,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(Icons.arrow_back, size: 18, color: Color(0xFF475569)),
                ),
              )
            else
              const SizedBox(width: 40),

            // Onboarding Title
            const Text(
              "Recovery Setup",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),

            // Skip Option
            if (_currentStep < 7)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Skip to final step or summary page
                  _pageController.animateToPage(
                    7,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                  );
                  setState(() {
                    _currentStep = 7;
                  });
                },
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
              )
            else
              const SizedBox(width: 40),
          ],
        ),
        const SizedBox(height: 16),
        // Animated Progress Bar
        Stack(
          children: [
            Container(
              width: double.infinity,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: MediaQuery.of(context).size.width * progress * 0.85,
              height: 6,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Step 1: Affected Arm ---
  Widget _buildAffectedArmPage(bool isSmallScreen) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text(
              "Which arm are you recovering?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "We'll personalize your rehabilitation exercises.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),

        // Custom painter arm highlight
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _setupModel.affectedArm = "Left";
                });
              },
              child: _buildArmSelectionCard("Left", _setupModel.affectedArm == "Left", isSmallScreen),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _setupModel.affectedArm = "Right";
                });
              },
              child: _buildArmSelectionCard("Right", _setupModel.affectedArm == "Right", isSmallScreen),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildArmSelectionCard(String side, bool isSelected, bool isSmallScreen) {
    return Container(
      width: isSmallScreen ? 115 : 135,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.tealCore.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.tealCore : const Color(0xFFE2E8F0),
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isSelected ? 0.04 : 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          CustomPaint(
            size: Size(60, isSmallScreen ? 50 : 60),
            painter: OnboardingArmPainter(
              side: side,
              isSelected: isSelected,
              activeColor: AppColors.tealCore,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$side Arm",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.tealCore : const Color(0xFF1E293B),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                const Icon(Icons.check_circle, size: 14, color: AppColors.tealCore),
              ]
            ],
          ),
        ],
      ),
    );
  }

  // --- Step 2: Rehab Area ---
  Widget _buildRehabAreaPage(bool isSmallScreen) {
    final List<Map<String, dynamic>> areas = [
      {"name": "Shoulder", "icon": Icons.accessibility},
      {"name": "Elbow", "icon": Icons.gesture},
      {"name": "Forearm", "icon": Icons.linear_scale},
      {"name": "Wrist", "icon": Icons.watch_later_outlined},
      {"name": "Hand", "icon": Icons.back_hand_outlined},
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text(
              "Which area needs rehabilitation?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Choose the body part your therapist assigned.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),

        // Grid selection cards
        SizedBox(
          height: isSmallScreen ? 240 : 290,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: areas.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: isSmallScreen ? 2.3 : 2.0,
            ),
            itemBuilder: (context, index) {
              final String val = areas[index]["name"];
              final IconData icon = areas[index]["icon"];
              final bool isSelected = _setupModel.rehabArea == val;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _setupModel.rehabArea = val;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.tealCore.withValues(alpha: 0.06) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.tealCore : const Color(0xFFE2E8F0),
                      width: isSelected ? 2.5 : 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.tealCore.withValues(alpha: 0.12) : Colors.white,
                        ),
                        child: Icon(icon, size: 18, color: isSelected ? AppColors.tealCore : const Color(0xFF475569)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          val,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected ? AppColors.tealCore : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Step 3: Recovery Stage ---
  Widget _buildRecoveryStagePage(bool isSmallScreen) {
    final List<Map<String, String>> stages = [
      {
        "stage": "Early",
        "title": "Early Recovery",
        "desc": "Gentle guided movements and minimal force.",
      },
      {
        "stage": "Intermediate",
        "title": "Intermediate Recovery",
        "desc": "Improving movement, range, and building strength.",
      },
      {
        "stage": "Advanced",
        "title": "Advanced Recovery",
        "desc": "High intensity exercises preparing for full mobility.",
      }
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text(
              "What stage of recovery are you in?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "This helps personalize your rehabilitation intensity.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),

        // Stacked option cards
        Column(
          children: stages.map((item) {
            final String val = item["stage"]!;
            final bool isSelected = _setupModel.recoveryStage == val;

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _setupModel.recoveryStage = val;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.tealCore.withValues(alpha: 0.06) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.tealCore : const Color(0xFFE2E8F0),
                    width: isSelected ? 2.5 : 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppColors.tealCore.withValues(alpha: 0.12) : const Color(0xFFF1F5F9),
                      ),
                      child: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        size: 18,
                        color: isSelected ? AppColors.tealCore : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item["title"]!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.tealCore : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item["desc"]!,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- Step 4: Physiotherapist Plan ---
  Widget _buildTherapistPage(bool isSmallScreen) {
    final bool isYes = _setupModel.therapistAssigned == true;
    final bool isNo = _setupModel.therapistAssigned == false;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text(
              "Are you following a plan from a physiotherapist?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 19 : 21,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Allows linking your program to your clinic portal.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),

        // Selection buttons
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _setupModel.therapistAssigned = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isYes ? AppColors.tealCore.withValues(alpha: 0.06) : Colors.white,
                    border: Border.all(
                      color: isYes ? AppColors.tealCore : const Color(0xFFCBD5E1),
                      width: isYes ? 2.5 : 1.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      "Yes",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isYes ? FontWeight.bold : FontWeight.normal,
                        color: isYes ? AppColors.tealCore : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _setupModel.therapistAssigned = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isNo ? AppColors.tealCore.withValues(alpha: 0.06) : Colors.white,
                    border: Border.all(
                      color: isNo ? AppColors.tealCore : const Color(0xFFCBD5E1),
                      width: isNo ? 2.5 : 1.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      "No",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isNo ? FontWeight.bold : FontWeight.normal,
                        color: isNo ? AppColors.tealCore : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Animated drop-down for Therapist Code text input
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _setupModel.therapistAssigned == true
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Enter Therapist Code",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _therapistCodeController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        hintText: "e.g. ABC-2041",
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.pin, color: Color(0xFF0F766E)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.tealCore, width: 2),
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox(height: 0),
        ),
      ],
    );
  }

  // --- Step 5: Exercise Schedule ---
  Widget _buildExerciseSchedulePage(bool isSmallScreen) {
    final List<String> frequencies = ["Daily", "5 Days / Week", "3 Days / Week", "Custom Schedule"];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text(
              "How often would you like to perform your rehabilitation exercises?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Choose a frequency target or set specific days.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),

        // Frequency cards
        SizedBox(
          height: isSmallScreen ? 200 : 240,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: frequencies.length,
            itemBuilder: (context, index) {
              final String val = frequencies[index];
              final bool isSelected = _setupModel.exerciseFrequency == val;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _setupModel.exerciseFrequency = val;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.tealCore.withValues(alpha: 0.06) : Colors.white,
                    border: Border.all(
                      color: isSelected ? AppColors.tealCore : const Color(0xFFE2E8F0),
                      width: isSelected ? 2.5 : 1.5,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        val,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? AppColors.tealCore : const Color(0xFF1E293B),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, size: 16, color: AppColors.tealCore),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Weekday selection animated bar (slides down if Custom is active)
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _setupModel.exerciseFrequency == "Custom Schedule"
              ? Column(
                  children: [
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _weekdays.map((day) {
                        final bool isDaySelected = _setupModel.selectedDays.contains(day);
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              if (isDaySelected) {
                                _setupModel.selectedDays.remove(day);
                              } else {
                                _setupModel.selectedDays.add(day);
                              }
                            });
                          },
                          child: Container(
                            width: isSmallScreen ? 34 : 40,
                            height: isSmallScreen ? 34 : 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDaySelected ? AppColors.tealCore : Colors.white,
                              border: Border.all(
                                color: isDaySelected ? AppColors.tealCore : const Color(0xFFCBD5E1),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                day[0],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDaySelected ? Colors.white : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                )
              : const SizedBox(height: 0),
        ),
      ],
    );
  }

  // --- Step 6: Reminder Time ---
  Widget _buildReminderTimePage(bool isSmallScreen) {
    final List<Map<String, String>> times = [
      {"name": "Morning (8:00 AM)", "icon": "🌅", "stage": "Morning"},
      {"name": "Afternoon (1:00 PM)", "icon": "☀️", "stage": "Afternoon"},
      {"name": "Evening (6:00 PM)", "icon": "🌙", "stage": "Evening"},
      {"name": "Choose Time", "icon": "⏰", "stage": "Custom"},
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text(
              "When would you like your reminders?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Choose when you'd like to receive reminders.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),

        // Grid cards
        SizedBox(
          height: isSmallScreen ? 240 : 280,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: times.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
            ),
            itemBuilder: (context, index) {
              final String val = times[index]["name"]!;
              final String icon = times[index]["icon"]!;
              final String stage = times[index]["stage"]!;
              final bool isSelected = _setupModel.reminderTime == val || 
                  (stage == "Custom" && _setupModel.reminderTime != null && 
                   !_setupModel.reminderTime!.startsWith("Morning") && 
                   !_setupModel.reminderTime!.startsWith("Afternoon") && 
                   !_setupModel.reminderTime!.startsWith("Evening"));

              return GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  if (stage == "Custom") {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.tealCore,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        _setupModel.reminderTime = picked.format(context);
                      });
                    }
                  } else {
                    setState(() {
                      _setupModel.reminderTime = val;
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.tealCore.withValues(alpha: 0.06) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.tealCore : const Color(0xFFE2E8F0),
                      width: isSelected ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isSelected ? 0.03 : 0.01),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 8),
                      Text(
                        stage == "Custom" && isSelected ? _setupModel.reminderTime! : val.split(' ')[0],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.tealCore : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Step 7: Almost Ready (Profile Photo Picker) ---
  Widget _buildAlmostReadyPage(bool isSmallScreen) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text(
              "Almost Ready!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 22 : 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Your rehabilitation profile has been created.\nYou're now ready to begin your recovery journey.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
            ),
          ],
        ),

        // Avatar circle picture preloaded
        Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: isSmallScreen ? 110 : 130,
                  height: isSmallScreen ? 110 : 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF1F5F9),
                    border: Border.all(color: AppColors.tealCore.withValues(alpha: 0.25), width: 4),
                  ),
                  child: ClipOval(
                    child: _hasAvatar
                        ? Image.asset(
                            OnboardingConstants.defaultProfileImagePath,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : const Center(
                            child: Icon(Icons.add_a_photo_outlined, size: 36, color: Color(0xFF64748B)),
                          ),
                  ),
                ),
                if (_hasAvatar)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 14, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _hasAvatar = true;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.tealCore),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Choose Photo", style: TextStyle(color: AppColors.tealCore)),
                ),
                const SizedBox(width: 14),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _hasAvatar = false;
                    });
                  },
                  child: const Text("Skip", style: TextStyle(color: Color(0xFF64748B))),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // --- Step 8: Recovery Summary page ---
  Widget _buildRecoverySummaryPage(bool isSmallScreen) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            const Text(
              "Your Recovery Plan",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Welcome, ${OnboardingConstants.defaultName.split(' ')[0]}! Plan is structured and ready.",
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),

        // Summary details card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              _buildSummaryRow(Icons.person, "Patient", OnboardingConstants.defaultName),
              const Divider(color: Color(0xFFE2E8F0), height: 16),
              _buildSummaryRow(Icons.accessibility_new, "Affected Arm", "${_setupModel.affectedArm ?? 'Right'} Arm"),
              const Divider(color: Color(0xFFE2E8F0), height: 16),
              _buildSummaryRow(Icons.healing, "Focus Area", "${_setupModel.rehabArea ?? 'Shoulder'} Rehab"),
              const Divider(color: Color(0xFFE2E8F0), height: 16),
              _buildSummaryRow(Icons.assessment, "Recovery Stage", "${_setupModel.recoveryStage ?? 'Intermediate'} Stage"),
              const Divider(color: Color(0xFFE2E8F0), height: 16),
              _buildSummaryRow(Icons.calendar_month, "Exercise Schedule", _setupModel.exerciseFrequency ?? '5 Days / Week'),
              const Divider(color: Color(0xFFE2E8F0), height: 16),
              _buildSummaryRow(Icons.alarm, "Daily Reminder", _setupModel.reminderTime ?? '8:00 AM'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(IconData icon, String title, String val) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.tealCore),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
        ),
        const Spacer(),
        Text(
          val,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
      ],
    );
  }

  // --- Bottom Action Navigation Row ---
  Widget _buildBottomControls(bool isSmallScreen) {
    final bool isLastPage = _currentStep == 7;
    final bool isValid = _isStepValid();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: AnimatedBuilder(
        animation: _submitScale,
        builder: (context, child) => Transform.scale(
          scale: _submitScale.value,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isValid
                  ? const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              color: isValid ? null : const Color(0xFFE2E8F0),
              boxShadow: isValid
                  ? [
                      BoxShadow(
                        color: const Color(0xFF0F766E).withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: ElevatedButton(
              onPressed: isValid
                  ? (isLastPage ? _handleCompleteProfile : _nextPage)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                disabledForegroundColor: const Color(0xFF94A3B8),
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                isLastPage ? "Begin Recovery" : "Continue",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- saving loading overlay ---
  Widget _buildSavingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.65),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 15,
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.tealCore),
              ),
              const SizedBox(height: 20),
              const Text(
                "Saving your profile...",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Configuring personalized plan",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Vector arm drawing helper class
class OnboardingArmPainter extends CustomPainter {
  final String side;
  final bool isSelected;
  final Color activeColor;

  OnboardingArmPainter({
    required this.side,
    required this.isSelected,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint armPaint = Paint()
      ..color = isSelected ? activeColor.withValues(alpha: 0.16) : const Color(0xFFF1F5F9)
      ..style = PaintingStyle.fill;

    final Paint outlinePaint = Paint()
      ..color = isSelected ? activeColor : const Color(0xFFCBD5E1)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint jointPaint = Paint()
      ..color = isSelected ? activeColor : const Color(0xFF94A3B8)
      ..style = PaintingStyle.fill;

    final double width = size.width;
    final double height = size.height;

    final Path path = Path();
    if (side == "Left") {
      path.moveTo(width * 0.7, height * 0.1);
      path.quadraticBezierTo(width * 0.75, height * 0.45, width * 0.6, height * 0.55);
      path.quadraticBezierTo(width * 0.35, height * 0.65, width * 0.3, height * 0.9);
      path.lineTo(width * 0.45, height * 0.95);
      path.quadraticBezierTo(width * 0.55, height * 0.72, width * 0.75, height * 0.62);
      path.quadraticBezierTo(width * 0.9, height * 0.42, width * 0.85, height * 0.1);
      path.close();
    } else {
      path.moveTo(width * 0.3, height * 0.1);
      path.quadraticBezierTo(width * 0.25, height * 0.45, width * 0.4, height * 0.55);
      path.quadraticBezierTo(width * 0.65, height * 0.65, width * 0.7, height * 0.9);
      path.lineTo(width * 0.55, height * 0.95);
      path.quadraticBezierTo(width * 0.45, height * 0.72, width * 0.25, height * 0.62);
      path.quadraticBezierTo(width * 0.1, height * 0.42, width * 0.15, height * 0.1);
      path.close();
    }

    canvas.drawPath(path, armPaint);
    canvas.drawPath(path, outlinePaint);

    if (side == "Left") {
      canvas.drawCircle(Offset(width * 0.77, height * 0.18), 3.5, jointPaint);
      canvas.drawCircle(Offset(width * 0.67, height * 0.56), 3.5, jointPaint);
      canvas.drawCircle(Offset(width * 0.33, height * 0.88), 3.5, jointPaint);
    } else {
      canvas.drawCircle(Offset(width * 0.23, height * 0.18), 3.5, jointPaint);
      canvas.drawCircle(Offset(width * 0.33, height * 0.56), 3.5, jointPaint);
      canvas.drawCircle(Offset(width * 0.67, height * 0.88), 3.5, jointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant OnboardingArmPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected || oldDelegate.side != side;
  }
}
