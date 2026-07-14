import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inteli_rehab/core/constants/app_colors.dart';

import 'package:inteli_rehab/core/constants/onboarding_constants.dart';
import 'package:inteli_rehab/presentation/onboarding/onboarding_flow.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> with SingleTickerProviderStateMixin {
  // Input Controllers
  final TextEditingController _nameController = TextEditingController(text: OnboardingConstants.defaultName);
  final TextEditingController _emailController = TextEditingController(text: OnboardingConstants.defaultEmail);
  final TextEditingController _phoneController = TextEditingController(text: OnboardingConstants.defaultPhone);
  final TextEditingController _passwordController = TextEditingController(text: OnboardingConstants.defaultPassword);
  final TextEditingController _confirmPasswordController = TextEditingController(text: OnboardingConstants.defaultPassword);

  // Focus Nodes
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  // Interactive States
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = true;
  bool _isLoading = false;
  String _selectedCountryCode = '+92';

  // Validation States
  bool _isEmailValid = true;
  bool _isPhoneValid = true;
  bool _isPasswordLengthValid = true;
  bool _isPasswordUpperValid = true;
  bool _isPasswordNumberValid = true;
  bool _passwordsMatch = true;

  // Scale animation for button tap
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

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
    _phoneController.addListener(_validatePhone);
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    _scaleController.dispose();
    super.dispose();
  }

  // ── Validation Helpers ─────────────────────────────────────────────────────
  void _validateEmail() {
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    setState(() {
      _isEmailValid = emailRegex.hasMatch(email);
    });
  }

  void _validatePhone() {
    final phone = _phoneController.text.trim();
    setState(() {
      _isPhoneValid = phone.length >= 7 && phone.length <= 15 && RegExp(r'^[0-9]+$').hasMatch(phone);
    });
  }

  void _validatePassword() {
    final pass = _passwordController.text;
    setState(() {
      _isPasswordLengthValid = pass.length >= 6;
      _isPasswordUpperValid = pass.contains(RegExp(r'[A-Z]'));
      _isPasswordNumberValid = pass.contains(RegExp(r'[0-9]'));
      _validateConfirmPassword();
    });
  }

  void _validateConfirmPassword() {
    setState(() {
      _passwordsMatch = _passwordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  int _getPasswordStrength() {
    final pass = _passwordController.text;
    if (pass.isEmpty) return 0;
    int score = 0;
    if (pass.length >= 6) score++;
    if (pass.contains(RegExp(r'[A-Z]'))) score++;
    if (pass.contains(RegExp(r'[0-9]'))) score++;
    return score;
  }

  String _getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
        return '';
      case 1:
        return 'Weak';
      case 2:
        return 'Medium';
      case 3:
        return 'Strong';
      default:
        return '';
    }
  }

  Color _getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 1:
        return const Color(0xFFEF4444);
      case 2:
        return const Color(0xFFF59E0B);
      case 3:
        return const Color(0xFF22C55E);
      default:
        return Colors.transparent;
    }
  }

  bool _isFormValid() {
    return _nameController.text.trim().isNotEmpty &&
        _isEmailValid &&
        _isPhoneValid &&
        _isPasswordLengthValid &&
        _isPasswordUpperValid &&
        _isPasswordNumberValid &&
        _passwordsMatch &&
        _agreedToTerms;
  }

  // ── Authentication Action ──────────────────────────────────────────────────
  Future<void> _handleCreateAccount() async {
    if (!_isFormValid()) return;

    _scaleController.forward().then((_) => _scaleController.reverse());
    HapticFeedback.mediumImpact();

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 1800));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const OnboardingManagerScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 760;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        // Non-scrollable centered layout inside safe boundaries
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Top Brand Header ──
                Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: isSmallScreen ? 80 : 100,
                      height: isSmallScreen ? 80 : 100,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                    const SizedBox(height: 6),
                    Text(
                      'Create Your Account',
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
                      'Create your account to begin your rehabilitation journey.',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                      textAlign: TextAlign.center,
                    ),

                // ── Registration Inputs Card ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1F2937).withValues(alpha: 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      // ── Full Name Field ──
                      _buildFormTextField(
                        controller: _nameController,
                        focusNode: _nameFocus,
                        hintText: 'Enter your full name',
                        labelText: 'Full Name',
                        leadingIcon: Icons.person_outline,
                      ),
                      const SizedBox(height: 10),

                      // ── Email Field ──
                      _buildFormTextField(
                        controller: _emailController,
                        focusNode: _emailFocus,
                        hintText: 'Enter your email address',
                        labelText: 'Email Address',
                        leadingIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        showCheckmark: _isEmailValid,
                      ),
                      const SizedBox(height: 10),

                      // ── Phone Number Field ──
                      _buildPhoneField(),
                      const SizedBox(height: 10),

                      // ── Password Field ──
                      _buildFormTextField(
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        hintText: 'Create a password',
                        labelText: 'Password',
                        leadingIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        trailingWidget: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: const Color(0xFF6B7280),
                            size: 16,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),

                      // Password strength indicators
                      if (_passwordFocus.hasFocus || _passwordController.text.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _buildPasswordStrengthBar(),
                      ],
                      const SizedBox(height: 10),

                      // ── Confirm Password Field ──
                      _buildFormTextField(
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocus,
                        hintText: 'Confirm your password',
                        labelText: 'Confirm Password',
                        leadingIcon: Icons.lock_outline,
                        obscureText: _obscureConfirmPassword,
                        showCheckmark: _passwordsMatch,
                        trailingWidget: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: const Color(0xFF6B7280),
                            size: 16,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Terms & Privacy Checkbox ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _agreedToTerms,
                        activeColor: AppColors.tealCore,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (val) {
                          setState(() {
                            _agreedToTerms = val ?? false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _agreedToTerms = !_agreedToTerms;
                          });
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'I agree to the ',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), height: 1.3),
                            children: [
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(color: AppColors.tealCore, fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(color: AppColors.tealCore, fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Primary Action Button & Divider ──
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
                                    color: AppColors.tealCore.withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: ElevatedButton(
                          onPressed: _isFormValid() && !_isLoading ? _handleCreateAccount : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Creating Account...',
                                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'Create Account',
                                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

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
                    const SizedBox(height: 10),

                    // Google signup
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Connecting to medical Google Auth services...')),
                        );
                      },
                      icon: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'G',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            foreground: Paint()
                              ..shader = const LinearGradient(
                                colors: [
                                  Color(0xFF4285F4),
                                  Color(0xFFEA4335),
                                  Color(0xFFFBBC05),
                                  Color(0xFF34A853),
                                ],
                              ).createShader(const Rect.fromLTWH(0, 0, 14, 14)),
                          ),
                        ),
                      ),
                      label: const Text(
                        'Continue with Google',
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

                // ── Sign In Navigation Link ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Sign In',
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

  // ── Form Text Field Builder ────────────────────────────────────────────────
  Widget _buildFormTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required String labelText,
    required IconData leadingIcon,
    bool obscureText = false,
    bool showCheckmark = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? trailingWidget,
  }) {
    return AnimatedBuilder(
      animation: Listenable.merge([focusNode, controller]),
      builder: (context, _) {
        final isFocused = focusNode.hasFocus;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.tealBright.withValues(alpha: 0.15),
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
                fontSize: 12,
              ),
              hintText: hintText,
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(leadingIcon, color: isFocused ? AppColors.tealCore : const Color(0xFF9CA3AF), size: 16),
              suffixIcon: showCheckmark
                  ? const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 16)
                  : trailingWidget,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.tealCore, width: 1.5),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Phone Input with Country Code Selector Dropdown ──
  Widget _buildPhoneField() {
    final codes = ['+92', '+1', '+44', '+971', '+61'];

    return Row(
      children: [
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          alignment: Alignment.center,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCountryCode,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6B7280), size: 16),
              items: codes.map((c) {
                return DropdownMenuItem<String>(
                  value: c,
                  child: Text(
                    c,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedCountryCode = val;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildFormTextField(
            controller: _phoneController,
            focusNode: _phoneFocus,
            hintText: 'Enter your phone number',
            labelText: 'Phone Number',
            leadingIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            showCheckmark: _isPhoneValid,
          ),
        ),
      ],
    );
  }

  // ── Password Strength Bar Component ──
  Widget _buildPasswordStrengthBar() {
    final int strength = _getPasswordStrength();
    final String text = _getPasswordStrengthText(strength);
    final Color color = _getPasswordStrengthColor(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Password Strength: ',
              style: TextStyle(fontSize: 10.5, color: Color(0xFF6B7280)),
            ),
            Text(
              text,
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(3, (index) {
            final active = index < strength;
            return Expanded(
              child: Container(
                height: 3,
                margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                decoration: BoxDecoration(
                  color: active ? color : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
