import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inteli_rehab/core/constants/app_colors.dart';
import 'package:inteli_rehab/presentation/onboarding/signup/signup_screen.dart';
import 'package:inteli_rehab/presentation/onboarding/otp/otp_screen.dart';
import 'package:inteli_rehab/presentation/onboarding/profile_setup/patient_profile_setup_screen.dart';
import 'package:inteli_rehab/presentation/home/home_dashboard.dart';
import 'package:inteli_rehab/core/constants/onboarding_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  // Input Controllers
  final TextEditingController _emailController = TextEditingController(text: OnboardingConstants.defaultEmail);
  final TextEditingController _passwordController = TextEditingController(text: OnboardingConstants.defaultPassword);

  // Focus Nodes
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  // Interactive States
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;
  bool _showEmailError = false;
  bool _showPasswordError = false;

  // Validation States
  bool _isEmailValid = true;
  bool _isPasswordLengthValid = true;
  bool _isPasswordUpperValid = true;
  bool _isPasswordNumberValid = true;

  // Scale animation for button tap
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Dynamic verification listeners
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  // ── Validation Helpers ─────────────────────────────────────────────────────
  void _validateEmail() {
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    setState(() {
      _isEmailValid = emailRegex.hasMatch(email);
      if (_isEmailValid) _showEmailError = false;
    });
  }

  void _validatePassword() {
    final pass = _passwordController.text;
    setState(() {
      _isPasswordLengthValid = pass.length >= 6;
      _isPasswordUpperValid = pass.contains(RegExp(r'[A-Z]'));
      _isPasswordNumberValid = pass.contains(RegExp(r'[0-9]'));
      if (_isPasswordLengthValid && _isPasswordUpperValid && _isPasswordNumberValid) {
        _showPasswordError = false;
      }
    });
  }

  bool _isFormValid() {
    return _isEmailValid && _isPasswordLengthValid && _isPasswordUpperValid && _isPasswordNumberValid;
  }

  // ── Authentication Action ──────────────────────────────────────────────────
  Future<void> _handleSignIn() async {
    if (!_isFormValid()) {
      setState(() {
        _showEmailError = !_isEmailValid;
        _showPasswordError = !(_isPasswordLengthValid && _isPasswordUpperValid && _isPasswordNumberValid);
      });
      HapticFeedback.vibrate();
      return;
    }

    _scaleController.forward().then((_) => _scaleController.reverse());
    HapticFeedback.mediumImpact();

    setState(() {
      _isLoading = true;
    });

    // Medical authentication mock delay
    await Future.delayed(const Duration(milliseconds: 1600));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeDashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 720;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        // Non-scrollable layout containing everything strictly within single screen height bounds
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Top Brand Section ──
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: isSmallScreen ? 90 : 110,
                            height: isSmallScreen ? 90 : 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.tealBright.withOpacity(0.18),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          // Small Assembled Brand Logo Stack Component (Static view)
                          SizedBox(
                            width: isSmallScreen ? 50 : 64,
                            height: isSmallScreen ? 50 : 64,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Thin Line
                                Positioned(
                                  top: 109.0 * ((isSmallScreen ? 50 : 64) / 568),
                                  left: 277.0 * ((isSmallScreen ? 50 : 64) / 568),
                                  width: 291.0 * ((isSmallScreen ? 50 : 64) / 568),
                                  height: 457.0 * ((isSmallScreen ? 50 : 64) / 568),
                                  child: Image.asset(
                                    'assets/images/thin line.png',
                                    fit: BoxFit.contain,
                                    color: AppColors.tealBright,
                                    colorBlendMode: BlendMode.srcIn,
                                  ),
                                ),
                                // Left Arc
                                Positioned(
                                  top: 1.0 * ((isSmallScreen ? 50 : 64) / 568),
                                  left: 0.0 * ((isSmallScreen ? 50 : 64) / 568),
                                  width: 331.0 * ((isSmallScreen ? 50 : 64) / 568),
                                  height: 565.0 * ((isSmallScreen ? 50 : 64) / 568),
                                  child: Image.asset(
                                    'assets/images/left hand.png',
                                    fit: BoxFit.contain,
                                    color: AppColors.tealCore,
                                    colorBlendMode: BlendMode.srcIn,
                                  ),
                                ),
                                // Right Arc
                                Positioned(
                                  top: 114.0 * ((isSmallScreen ? 50 : 64) / 568),
                                  left: 240.0 * ((isSmallScreen ? 50 : 64) / 568),
                                  width: 328.0 * ((isSmallScreen ? 50 : 64) / 568),
                                  height: 327.0 * ((isSmallScreen ? 50 : 64) / 568),
                                  child: Image.asset(
                                    'assets/images/right hand.png',
                                    fit: BoxFit.contain,
                                    color: AppColors.tealBright,
                                    colorBlendMode: BlendMode.srcIn,
                                  ),
                                ),
                                // Arm
                                Positioned(
                                  top: 115.0 * ((isSmallScreen ? 50 : 64) / 568),
                                  left: 125.0 * ((isSmallScreen ? 50 : 64) / 568),
                                  width: 443.0 * ((isSmallScreen ? 50 : 64) / 568),
                                  height: 451.0 * ((isSmallScreen ? 50 : 64) / 568),
                                  child: Image.asset(
                                    'assets/images/human hand.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                // Head
                                Positioned(
                                  top: 11.0 * ((isSmallScreen ? 50 : 64) / 568),
                                  left: 103.0 * ((isSmallScreen ? 50 : 64) / 568),
                                  width: 257.0 * ((isSmallScreen ? 50 : 64) / 568),
                                  height: 260.0 * ((isSmallScreen ? 50 : 64) / 568),
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
                      const SizedBox(height: 8),
                      Text(
                        'INTELI-REHAB',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: isSmallScreen ? 22 : 26,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1F2937),
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Smart Rehabilitation System',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                          letterSpacing: 0.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  // ── Welcome Medical Card ──
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1F2937).withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.verified_user_outlined, color: AppColors.tealCore, size: 18),
                            const SizedBox(width: 8),
                            const Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Sign in to continue your rehabilitation program.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // ── Input Fields Section ──
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildAnimatedTextField(
                        controller: _emailController,
                        focusNode: _emailFocus,
                        hintText: 'Enter your email',
                        labelText: 'Email',
                        leadingIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        showError: _showEmailError,
                        errorText: 'Please enter a valid email address',
                      ),
                      const SizedBox(height: 12),
                      _buildAnimatedTextField(
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        hintText: 'Enter your password',
                        labelText: 'Password',
                        leadingIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        showError: _showPasswordError,
                        errorText: 'Password must include uppercase, numbers, and be >= 6 chars',
                        trailingWidget: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: const Color(0xFF6B7280),
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),

                      // Live validation checkers
                      if (_passwordFocus.hasFocus || _passwordController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 2,
                            children: [
                              _buildValidationLabel('6+ Chars', _isPasswordLengthValid),
                              _buildValidationLabel('1 uppercase', _isPasswordUpperValid),
                              _buildValidationLabel('1 number', _isPasswordNumberValid),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // ── Remember Me & Forgot Password ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: Checkbox(
                              value: _rememberMe,
                              activeColor: AppColors.tealCore,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (val) {
                                setState(() {
                                  _rememberMe = val ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _rememberMe = !_rememberMe;
                              });
                            },
                            child: const Text(
                              'Remember Me',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: _showForgotPasswordDialog,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.tealCore,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ── Sign In & Outlines ──
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: _isFormValid() && !_isLoading
                                ? LinearGradient(
                                    colors: [AppColors.tealCore, AppColors.tealBright],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  )
                                : null,
                            color: !_isFormValid() || _isLoading ? const Color(0xFFE5E7EB) : null,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: _isFormValid() && !_isLoading
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
                            onPressed: _isFormValid() && !_isLoading ? _handleSignIn : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.0,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Sign In',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      SizedBox(width: 6),
                                      Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR',
                              style: TextStyle(color: const Color(0xFF6B7280), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.8),
                            ),
                          ),
                          const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                        ],
                      ),
                      const SizedBox(height: 12),

                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const CreateAccountScreen()),
                          );
                        },
                        icon: Icon(Icons.person_add_alt_1_outlined, size: 16, color: AppColors.tealCore),
                        label: const Text(
                          'Create New Account',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          foregroundColor: const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),

                  // ── HIPAA Security Footer Info ──
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.tealBright.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.tealBright.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.shield_outlined, color: AppColors.tealCore, size: 14),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Your rehabilitation data is securely protected.',
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Footer Copyrights ──
                  Column(
                    children: [
                      const Text(
                        'Version 1.0',
                        style: TextStyle(fontSize: 10.5, color: Color(0xFF6B7280)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildFooterLink('Privacy Policy'),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text('•', style: TextStyle(color: Color(0xFF6B7280))),
                          ),
                          _buildFooterLink('Terms of Use'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Text Field Widget Builder ──────────────────────────────────────────────
  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required String labelText,
    required IconData leadingIcon,
    bool obscureText = false,
    bool showError = false,
    required String errorText,
    TextInputType keyboardType = TextInputType.text,
    Widget? trailingWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([focusNode, controller]),
          builder: (context, _) {
            final isFocused = focusNode.hasFocus;
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color: AppColors.tealBright.withOpacity(0.15),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                obscureText: obscureText,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  labelText: labelText,
                  labelStyle: TextStyle(
                    color: isFocused ? AppColors.tealCore : const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  hintText: hintText,
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13.5),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(leadingIcon, color: isFocused ? AppColors.tealCore : const Color(0xFF9CA3AF), size: 18),
                  suffixIcon: trailingWidget,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: showError ? const Color(0xFFEF4444) : const Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: showError ? const Color(0xFFEF4444) : AppColors.tealCore, width: 1.5),
                  ),
                ),
              ),
            );
          },
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 6),
            child: Text(
              errorText,
              style: const TextStyle(color: Color(0xFFEF4444), fontSize: 10.5, fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }

  Widget _buildValidationLabel(String label, bool isValid) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.circle_outlined,
          color: isValid ? const Color(0xFF22C55E) : const Color(0xFF9CA3AF),
          size: 13,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: isValid ? const Color(0xFF22C55E) : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLink(String label) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening $label...'),
            backgroundColor: AppColors.tealCore,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: AppColors.tealCore,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  // ── Dialog Handlers ────────────────────────────────────────────────────────
  // ── Dialog Handlers ────────────────────────────────────────────────────────
  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        int resetStep = 1; // 1: Email, 2: OTP, 3: New Password, 4: Success
        final emailCtrl = TextEditingController();
        final otpCtrl = TextEditingController();
        final passCtrl = TextEditingController();
        final confirmPassCtrl = TextEditingController();
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            String title = 'Reset Password';
            IconData titleIcon = Icons.lock_reset;
            if (resetStep == 2) {
              title = 'Verify OTP';
              titleIcon = Icons.pin_outlined;
            } else if (resetStep == 3) {
              title = 'New Password';
              titleIcon = Icons.lock_outline;
            } else if (resetStep == 4) {
              title = 'Password Updated';
              titleIcon = Icons.check_circle_outline;
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(titleIcon, color: AppColors.tealCore),
                  const SizedBox(width: 8),
                  Text(title),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (resetStep == 1) ...[
                      const Text(
                        'Enter your registered email address to receive a reset code.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'user@example.com',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ] else if (resetStep == 2) ...[
                      Text(
                        'Enter the 4-digit code sent to ${emailCtrl.text}.',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: otpCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 8),
                        decoration: InputDecoration(
                          hintText: '0000',
                          counterText: '',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ] else if (resetStep == 3) ...[
                      const Text(
                        'Create a new strong password for your medical portal.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'New Password',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: confirmPassCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ] else if (resetStep == 4) ...[
                      const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Your password has been successfully updated. You can now log in with your new password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13.5, color: Color(0xFF1E293B)),
                      ),
                    ],
                    if (isSubmitting) ...[
                      const SizedBox(height: 16),
                      const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F766E)))),
                    ],
                  ],
                ),
              ),
              actions: [
                if (resetStep < 4)
                  TextButton(
                    onPressed: isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (resetStep == 1) {
                            if (emailCtrl.text.trim().isEmpty) return;
                            setDialogState(() => isSubmitting = true);
                            await Future.delayed(const Duration(milliseconds: 1200));
                            setDialogState(() {
                              isSubmitting = false;
                              resetStep = 2;
                            });
                          } else if (resetStep == 2) {
                            if (otpCtrl.text.trim().length < 4) return;
                            setDialogState(() => isSubmitting = true);
                            await Future.delayed(const Duration(milliseconds: 1000));
                            setDialogState(() {
                              isSubmitting = false;
                              resetStep = 3;
                            });
                          } else if (resetStep == 3) {
                            if (passCtrl.text.isEmpty || passCtrl.text != confirmPassCtrl.text) return;
                            setDialogState(() => isSubmitting = true);
                            await Future.delayed(const Duration(milliseconds: 1200));
                            setDialogState(() {
                              isSubmitting = false;
                              resetStep = 4;
                            });
                          } else if (resetStep == 4) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please sign in with your new credentials.'),
                                backgroundColor: Color(0xFF0F766E),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tealCore,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(resetStep == 4 ? 'Return to Login' : 'Continue'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
