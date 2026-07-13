import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inteli_rehab/features/exercise/utils/app_colors.dart';
import 'package:inteli_rehab/features/onboarding/onboarding_constants.dart';
import 'package:inteli_rehab/features/onboarding/patient_profile_setup_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, this.email = 'john.doe@example.com'});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with TickerProviderStateMixin {
  // 6 digit controllers and focus nodes
  final List<TextEditingController> _controllers = [
    TextEditingController(text: OnboardingConstants.otpCorrectCode[0]),
    TextEditingController(text: OnboardingConstants.otpCorrectCode[1]),
    TextEditingController(text: OnboardingConstants.otpCorrectCode[2]),
    TextEditingController(text: OnboardingConstants.otpCorrectCode[3]),
    TextEditingController(text: OnboardingConstants.otpCorrectCode[4]),
    TextEditingController(text: OnboardingConstants.otpCorrectCode[5]),
  ];
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  // Interactive States
  late String _userEmail;
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _shakeError = false;

  // Timer States
  int _secondsRemaining = 45;
  Timer? _timer;
  bool _canResend = false;

  // Scale & Shake Animations
  late final AnimationController _buttonScaleController;
  late final Animation<double> _buttonScale;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _userEmail = widget.email;

    _buttonScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonScaleController, curve: Curves.easeInOut),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 12.0,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);

    _startCountdownTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _buttonScaleController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // ── OTP Auto-Traversal & Paste logic ──────────────────────────────────────
  void _onOtpChanged(String value, int index) {
    if (value.length == 1) {
      // Focus next field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty) {
      // Focus previous field
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
    setState(() {}); // Trigger build to update button disabled status
  }

  bool _isOtpComplete() {
    return _controllers.every((c) => c.text.isNotEmpty);
  }

  String _getOtpCode() {
    return _controllers.map((c) => c.text).join();
  }

  // ── Countdown Timer ────────────────────────────────────────────────────────
  void _startCountdownTimer() {
    setState(() {
      _secondsRemaining = 45;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      }
    });
  }

  // ── Reset/Change Email Actions ─────────────────────────────────────────────
  void _showChangeEmailDialog() {
    final emailTextController = TextEditingController(text: _userEmail);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.edit, color: AppColors.tealCore),
            const SizedBox(width: 8),
            const Text('Change Email'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Update your registration email. We will send a new code.',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailTextController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _userEmail = emailTextController.text.trim();
              });
              Navigator.pop(context);
              _startCountdownTimer();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Verification code sent to $_userEmail'),
                  backgroundColor: AppColors.tealCore,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tealCore,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Verification Action ────────────────────────────────────────────────────
  Future<void> _handleVerify() async {
    if (!_isOtpComplete()) return;

    _buttonScaleController.forward().then(
      (_) => _buttonScaleController.reverse(),
    );
    HapticFeedback.mediumImpact();

    final code = _getOtpCode();

    // Check code validity (dummy code for success, others shake/error)
    if (code != OnboardingConstants.otpCorrectCode) {
      HapticFeedback.vibrate();
      setState(() {
        _shakeError = true;
      });
      // Play shake animation
      _shakeController.forward(from: 0).then((_) {
        setState(() {
          _shakeError = false;
        });
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate HIPAA Verification API
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });

      // Show success tick for 900ms before navigating
      await Future.delayed(const Duration(milliseconds: 900));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const PatientProfileSetupScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 720;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        // Strictly non-scrollable layout fitting exactly on a single screen height
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header & Logo Section ──
                Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: isSmallScreen ? 70 : 90,
                          height: isSmallScreen ? 70 : 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.tealBright.withOpacity(0.15),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        // Mini assembled brand logo stack
                        SizedBox(
                          width: isSmallScreen ? 40 : 50,
                          height: isSmallScreen ? 40 : 50,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: 109.0 * ((isSmallScreen ? 40 : 50) / 568),
                                left: 277.0 * ((isSmallScreen ? 40 : 50) / 568),
                                width:
                                    291.0 * ((isSmallScreen ? 40 : 50) / 568),
                                height:
                                    457.0 * ((isSmallScreen ? 40 : 50) / 568),
                                child: Image.asset(
                                  'assets/images/thin line.png',
                                  fit: BoxFit.contain,
                                  color: AppColors.tealBright,
                                  colorBlendMode: BlendMode.srcIn,
                                ),
                              ),
                              Positioned(
                                top: 1.0 * ((isSmallScreen ? 40 : 50) / 568),
                                left: 0.0 * ((isSmallScreen ? 40 : 50) / 568),
                                width:
                                    331.0 * ((isSmallScreen ? 40 : 50) / 568),
                                height:
                                    565.0 * ((isSmallScreen ? 40 : 50) / 568),
                                child: Image.asset(
                                  'assets/images/left hand.png',
                                  fit: BoxFit.contain,
                                  color: AppColors.tealCore,
                                  colorBlendMode: BlendMode.srcIn,
                                ),
                              ),
                              Positioned(
                                top: 114.0 * ((isSmallScreen ? 40 : 50) / 568),
                                left: 240.0 * ((isSmallScreen ? 40 : 50) / 568),
                                width:
                                    328.0 * ((isSmallScreen ? 40 : 50) / 568),
                                height:
                                    327.0 * ((isSmallScreen ? 40 : 50) / 568),
                                child: Image.asset(
                                  'assets/images/right hand.png',
                                  fit: BoxFit.contain,
                                  color: AppColors.tealBright,
                                  colorBlendMode: BlendMode.srcIn,
                                ),
                              ),
                              Positioned(
                                top: 115.0 * ((isSmallScreen ? 40 : 50) / 568),
                                left: 125.0 * ((isSmallScreen ? 40 : 50) / 568),
                                width:
                                    443.0 * ((isSmallScreen ? 40 : 50) / 568),
                                height:
                                    451.0 * ((isSmallScreen ? 40 : 50) / 568),
                                child: Image.asset(
                                  'assets/images/human hand.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Positioned(
                                top: 11.0 * ((isSmallScreen ? 40 : 50) / 568),
                                left: 103.0 * ((isSmallScreen ? 40 : 50) / 568),
                                width:
                                    257.0 * ((isSmallScreen ? 40 : 50) / 568),
                                height:
                                    260.0 * ((isSmallScreen ? 40 : 50) / 568),
                                child: Image.asset(
                                  'assets/images/filled circle.png',
                                  fit: BoxFit.contain,
                                  color: AppColors.tealBright,
                                  colorBlendMode: BlendMode.srcIn,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Verify Your Account',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Enter the verification code sent to your email.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF6B7280),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _userEmail,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.tealCore,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: _showChangeEmailDialog,
                          child: const Icon(
                            Icons.edit,
                            color: Color(0xFF6B7280),
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ── Medical Vector Hero Illustration (Custom Painter) ──
                SizedBox(
                  height: isSmallScreen ? 70 : 100,
                  child: CustomPaint(
                    painter: _HeroIllustrationPainter(
                      brandColor: AppColors.tealCore,
                      accentColor: AppColors.tealBright,
                    ),
                  ),
                ),

                // ── OTP Card ──
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        _shakeError
                            ? _shakeAnimation.value *
                                  (1 - (_shakeController.value * 2)).clamp(
                                    -1,
                                    1,
                                  )
                            : 0,
                        0,
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _shakeError
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFE5E7EB),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1F2937).withOpacity(0.03),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Verification Code',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 6 separate OTP fields
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (idx) {
                            return SizedBox(
                              width: isSmallScreen ? 42 : 48,
                              height: isSmallScreen ? 42 : 48,
                              child: TextFormField(
                                controller: _controllers[idx],
                                focusNode: _focusNodes[idx],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(1),
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (value) => _onOtpChanged(value, idx),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: _controllers[idx].text.isNotEmpty
                                          ? const Color(0xFF22C55E)
                                          : const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: AppColors.tealCore,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Countdown / Resend ──
                Center(
                  child: _canResend
                      ? TextButton.icon(
                          onPressed: _startCountdownTimer,
                          icon: Icon(
                            Icons.refresh,
                            color: AppColors.tealCore,
                            size: 14,
                          ),
                          label: Text(
                            'Resend Code',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.tealCore,
                            ),
                          ),
                        )
                      : Text(
                          'Resend code in 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),

                // ── Primary Action Button ──
                ScaleTransition(
                  scale: _buttonScale,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: _isOtpComplete() && !_isLoading && !_isSuccess
                          ? LinearGradient(
                              colors: [
                                AppColors.tealCore,
                                AppColors.tealBright,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : null,
                      color: !_isOtpComplete() || _isLoading || _isSuccess
                          ? const Color(0xFFE5E7EB)
                          : null,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: _isOtpComplete() && !_isLoading && !_isSuccess
                          ? [
                              BoxShadow(
                                color: AppColors.tealCore.withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: ElevatedButton(
                      onPressed: _isOtpComplete() && !_isLoading && !_isSuccess
                          ? _handleVerify
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.0,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Verifying...',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : _isSuccess
                          ? const Icon(
                              Icons.check_circle,
                              color: Color(0xFF22C55E),
                              size: 20,
                            )
                          : const Text(
                              'Verify Account',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),

                // ── Help Card ──
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: AppColors.tealCore,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Check your spam folder if you haven\'t received the email.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Bottom Link ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Wrong email address? ',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    GestureDetector(
                      onTap: _showChangeEmailDialog,
                      child: Text(
                        'Change Email',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tealCore,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Custom Vector Illustration Painter ─────────────────────────────────────────
class _HeroIllustrationPainter extends CustomPainter {
  final Color brandColor;
  final Color accentColor;
  _HeroIllustrationPainter({
    required this.brandColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = accentColor.withOpacity(0.15)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint nodePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    // Draw connection lines
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.5),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.1),
      Offset(size.width * 0.5, size.height * 0.9),
      linePaint,
    );

    // Draw nodes
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.5),
      4,
      nodePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.5),
      4,
      nodePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.1),
      4,
      nodePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.9),
      4,
      nodePaint,
    );

    // Draw shield in center
    final double cx = size.width * 0.5;
    final double cy = size.height * 0.5;

    final Paint shieldPaint = Paint()
      ..color = brandColor
      ..style = PaintingStyle.fill;

    final Path shieldPath = Path();
    shieldPath.moveTo(cx, cy - 14);
    shieldPath.quadraticBezierTo(cx + 12, cy - 14, cx + 12, cy - 4);
    shieldPath.quadraticBezierTo(cx + 12, cy + 8, cx, cy + 14);
    shieldPath.quadraticBezierTo(cx - 12, cy + 8, cx - 12, cy - 4);
    shieldPath.quadraticBezierTo(cx - 12, cy - 14, cx, cy - 14);
    shieldPath.close();

    canvas.drawPath(shieldPath, shieldPaint);

    // Draw checkmark inside shield
    final Paint checkPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path checkPath = Path();
    checkPath.moveTo(cx - 5, cy);
    checkPath.lineTo(cx - 1.5, cy + 3.5);
    checkPath.lineTo(cx + 5, cy - 3.5);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
