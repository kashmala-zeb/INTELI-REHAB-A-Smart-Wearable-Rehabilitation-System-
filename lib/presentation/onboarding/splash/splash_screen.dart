import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inteli_rehab/presentation/onboarding/login/login_screen.dart';

enum OnboardingScene { splash, feedback, bumper, login }

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  OnboardingScene _currentScene = OnboardingScene.splash;
  Timer? _sceneTimer;

  // Scene 1: Splash Animation Controllers & Tweens
  late final AnimationController _splashController;
  late final Animation<double> _thinLineOpacity;
  late final Animation<double> _thinLineScale;
  late final Animation<double> _leftArcOpacity;
  late final Animation<Offset> _leftArcSlide;
  late final Animation<double> _rightArcOpacity;
  late final Animation<Offset> _rightArcSlide;
  late final Animation<double> _armOpacity;
  late final Animation<double> _armScale;
  late final Animation<double> _headOpacity;
  late final Animation<double> _headSlide;
  late final Animation<double> _splashTextOpacity;
  late final Animation<double> _splashTextScale;

  // Scene 2: Feedback Card Animation Controllers & Tweens
  late final AnimationController _feedbackController;
  late final List<Animation<double>> _cardOpacities;
  late final List<Animation<Offset>> _cardSlides;
  late final Animation<double> _feedbackHeaderOpacity;

  // Scene 3: Bumper Animation Controllers & Tweens
  late final AnimationController _bumperController;
  late final Animation<double> _bumperLogoOpacity;
  late final Animation<double> _bumperLogoScale;
  late final Animation<double> _bumperTextOpacity;

  // Color Palette Constants
  final Color _teal = const Color(
    0xFF14B8A6,
  ); // AppColors.tealBright (bright teal)
  final Color _blue = const Color(0xFF0F766E); // AppColors.tealCore (dark teal)
  final Color _ink = const Color(0xFF0F2733);
  final Color _inkSoft = const Color(0xFF4C6470);
  final Color _bg = const Color(0xFFF2FAFA);
  final Color _line = const Color(0xFFDDEEEE);
  final Color _coral = const Color(0xFFFF8A66);

  @override
  void initState() {
    super.initState();

    _initSplashAnimations();
    _initFeedbackAnimations();
    _initBumperAnimations();

    _startOnboardingSequence();
  }

  // ── Initializations ────────────────────────────────────────────────────────
  void _initSplashAnimations() {
    _splashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _thinLineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );
    _thinLineScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOutBack),
      ),
    );

    _leftArcOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.20, 0.45, curve: Curves.easeIn),
      ),
    );
    _leftArcSlide = Tween<Offset>(begin: const Offset(-50, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _splashController,
            curve: const Interval(0.20, 0.45, curve: Curves.easeOutCubic),
          ),
        );

    _rightArcOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.30, 0.55, curve: Curves.easeIn),
      ),
    );
    _rightArcSlide = Tween<Offset>(begin: const Offset(50, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _splashController,
            curve: const Interval(0.30, 0.55, curve: Curves.easeOutCubic),
          ),
        );

    _armOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.50, 0.75, curve: Curves.easeIn),
      ),
    );
    _armScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.50, 0.75, curve: Curves.easeOutBack),
      ),
    );

    _headOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.68, 0.85, curve: Curves.easeIn),
      ),
    );
    _headSlide = Tween<double>(begin: -100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.68, 0.88, curve: Curves.bounceOut),
      ),
    );

    _splashTextOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.80, 1.0, curve: Curves.easeIn),
      ),
    );
    _splashTextScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.80, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  void _initFeedbackAnimations() {
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _feedbackHeaderOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _feedbackController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _cardOpacities = [];
    _cardSlides = [];

    // 4 cards staggered timings
    final List<List<double>> intervals = [
      [0.2, 0.5],
      [0.4, 0.7],
      [0.6, 0.9],
      [0.75, 1.0],
    ];

    for (int i = 0; i < 4; i++) {
      _cardOpacities.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _feedbackController,
            curve: Interval(
              intervals[i][0],
              intervals[i][1],
              curve: Curves.easeIn,
            ),
          ),
        ),
      );
      _cardSlides.add(
        Tween<Offset>(begin: const Offset(0, 30), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _feedbackController,
            curve: Interval(
              intervals[i][0],
              intervals[i][1],
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
      );
    }
  }

  void _initBumperAnimations() {
    _bumperController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _bumperLogoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bumperController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    _bumperLogoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _bumperController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );
    _bumperTextOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bumperController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  // ── Onboarding Controller Sequence ──────────────────────────────────────────
  void _startOnboardingSequence() {
    // 1. Play Splash Screen
    _splashController.forward();
    _sceneTimer = Timer(const Duration(milliseconds: 3800), () {
      if (mounted) {
        setState(() {
          _currentScene = OnboardingScene.feedback;
          _feedbackController.forward();
        });
        _scheduleFeedbackTransition();
      }
    });
  }

  void _scheduleFeedbackTransition() {
    // 2. Play Feedback onboarding cards
    _sceneTimer = Timer(const Duration(milliseconds: 6500), () {
      if (mounted) {
        setState(() {
          _currentScene = OnboardingScene.bumper;
          _bumperController.forward();
        });
        _scheduleBumperTransition();
      }
    });
  }

  void _scheduleBumperTransition() {
    // 3. Play Bumper logo reveal
    _sceneTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  void _skipOnboarding() {
    _sceneTimer?.cancel();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _sceneTimer?.cancel();
    _splashController.dispose();
    _feedbackController.dispose();
    _bumperController.dispose();
    super.dispose();
  }

  // ── Layout Assembly ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _buildSceneContent(),
        ),
      ),
    );
  }

  Widget _buildSceneContent() {
    switch (_currentScene) {
      case OnboardingScene.splash:
        return _buildSplashScene();
      case OnboardingScene.feedback:
        return _buildFeedbackScene();
      case OnboardingScene.bumper:
        return _buildBumperScene();
      case OnboardingScene.login:
        return const SizedBox.shrink(); // Handled by routing replacement
    }
  }

  // ── Scene 1: Splash ────────────────────────────────────────────────────────
  Widget _buildSplashScene() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double logoSize = (screenWidth * 0.58).clamp(160.0, 240.0);

    return Container(
      key: const ValueKey('splash_scene'),
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLogoStack(logoSize, animate: true),
          const SizedBox(height: 36),
          AnimatedBuilder(
            animation: _splashController,
            builder: (context, child) => Opacity(
              opacity: _splashTextOpacity.value,
              child: Transform.scale(
                scale: _splashTextScale.value,
                child: child,
              ),
            ),
            child: Column(
              children: [
                RichText(
                  text: TextSpan(
                    text: 'INTELI-',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                      color: _ink,
                      letterSpacing: 0.5,
                    ),
                    children: [
                      TextSpan(
                        text: 'REHAB',
                        style: TextStyle(color: _teal),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'A SMART WEARABLE REHABILITATION SYSTEM',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _inkSoft,
                    letterSpacing: 1.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoStack(double logoSize, {required bool animate}) {
    if (animate) {
      return AnimatedBuilder(
        animation: _splashController,
        builder: (context, _) => _buildStaticLogoStack(logoSize, animate: true),
      );
    } else {
      return _buildStaticLogoStack(logoSize, animate: false);
    }
  }

  Widget _buildStaticLogoStack(double logoSize, {required bool animate}) {
    final double scale = logoSize / 568.0;

    final double thinOpacity = animate ? _thinLineOpacity.value : 1.0;
    final double thinScale = animate ? _thinLineScale.value : 1.0;

    final double leftOpacity = animate ? _leftArcOpacity.value : 1.0;
    final Offset leftSlide = animate ? _leftArcSlide.value : Offset.zero;

    final double rightOpacity = animate ? _rightArcOpacity.value : 1.0;
    final Offset rightSlide = animate ? _rightArcSlide.value : Offset.zero;

    final double armOpacity = animate ? _armOpacity.value : 1.0;
    final double armScaleFactor = animate ? _armScale.value : 1.0;

    final double headOpacityVal = animate ? _headOpacity.value : 1.0;
    final double headSlideVal = animate ? _headSlide.value : 0.0;

    return SizedBox(
      width: logoSize,
      height: logoSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Component 1: Thin Line
          Positioned(
            top: 95.0 * scale,
            left: 279.0 * scale,
            width: 289.0 * scale,
            height: 454.0 * scale,
            child: Opacity(
              opacity: thinOpacity,
              child: Transform.scale(
                scale: thinScale,
                child: Image.asset(
                  'assets/images/thin line.png',
                  fit: BoxFit.contain,
                  color: _teal,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
          ),

          // Component 2: Left Arc
          Positioned(
            top: 2.0 * scale,
            left: 1.0 * scale,
            width: 329.0 * scale,
            height: 562.0 * scale,
            child: Opacity(
              opacity: leftOpacity,
              child: Transform.translate(
                offset: leftSlide * scale,
                child: Image.asset(
                  'assets/images/left hand.png',
                  fit: BoxFit.contain,
                  color: _blue,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
          ),

          // Component 3: Right Arc
          Positioned(
            top: 69.0 * scale,
            left: 78.0 * scale,
            width: 267.0 * scale,
            height: 267.0 * scale,
            child: Opacity(
              opacity: rightOpacity,
              child: Transform.translate(
                offset: rightSlide * scale,
                child: Image.asset(
                  'assets/images/right hand.png',
                  fit: BoxFit.contain,
                  color: _teal,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
          ),

          // Component 4: Arm (Natural skin color)
          Positioned(
            top: 128.0 * scale,
            left: 168.0 * scale,
            width: 357.0 * scale,
            height: 364.0 * scale,
            child: Opacity(
              opacity: armOpacity,
              child: Transform.scale(
                scale: armScaleFactor,
                child: Image.asset(
                  'assets/images/human hand.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Component 5: Head
          Positioned(
            top: (12.0 + headSlideVal) * scale,
            left: 103.0 * scale,
            width: 90.0 * scale,
            height: 90.0 * scale,
            child: Opacity(
              opacity: headOpacityVal,
              child: Image.asset(
                'assets/images/filled circle.png',
                fit: BoxFit.contain,
                color: _teal,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Scene 2: Feedback ──────────────────────────────────────────────────────
  Widget _buildFeedbackScene() {
    final reviews = [
      _ReviewItem(
        'AM',
        'Ayesha M.',
        'Knee rehab · Week 6',
        'The sensor caught a bad rep before I even felt it. My range of motion is finally back.',
      ),
      _ReviewItem(
        'RK',
        'Raheel K.',
        'Shoulder recovery',
        'Feels like a therapist on my arm, guiding every movement.',
      ),
      _ReviewItem('SN', 'Sana N.', 'Post-surgery, Day 40', 'I am pain free.'),
      _ReviewItem(
        'HZ',
        'Hamza Z.',
        'Elbow rehab',
        "Couldn't have done it without this team.",
      ),
    ];

    return Container(
      key: const ValueKey('feedback_scene'),
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedBuilder(
                animation: _feedbackHeaderOpacity,
                builder: (context, _) => Opacity(
                  opacity: _feedbackHeaderOpacity.value,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REAL PROGRESS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _teal,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Loved by our patients',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: _skipOnboarding,
                style: TextButton.styleFrom(foregroundColor: _inkSoft),
                child: const Text(
                  'Skip',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: 4,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, idx) {
                final item = reviews[idx];
                return AnimatedBuilder(
                  animation: _feedbackController,
                  builder: (context, _) => Opacity(
                    opacity: _cardOpacities[idx].value,
                    child: Transform.translate(
                      offset: _cardSlides[idx].value,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _line),
                          boxShadow: [
                            BoxShadow(
                              color: _ink.withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [_teal, _blue],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    item.avatar,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: _ink,
                                      ),
                                    ),
                                    Text(
                                      item.meta,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        color: _inkSoft,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  '★★★★★',
                                  style: TextStyle(
                                    color: _coral,
                                    fontSize: 10,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '"${item.quote}"',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                                color: _ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Scene 3: Bumper ────────────────────────────────────────────────────────
  Widget _buildBumperScene() {
    return Container(
      key: const ValueKey('bumper_scene'),
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _bumperController,
        builder: (context, child) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: _bumperLogoOpacity.value,
              child: Transform.scale(
                scale: _bumperLogoScale.value,
                child: _buildLogoStack(96.0, animate: false),
              ),
            ),
            const SizedBox(height: 18),
            Opacity(
              opacity: _bumperTextOpacity.value,
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'INTELI-',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        color: _ink,
                      ),
                      children: [
                        TextSpan(
                          text: 'REHAB',
                          style: TextStyle(color: _teal),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A SMART WEARABLE REHABILITATION SYSTEM',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: _inkSoft,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Support Classes ──────────────────────────────────────────────────────────
class _ReviewItem {
  final String avatar;
  final String name;
  final String meta;
  final String quote;
  _ReviewItem(this.avatar, this.name, this.meta, this.quote);
}
