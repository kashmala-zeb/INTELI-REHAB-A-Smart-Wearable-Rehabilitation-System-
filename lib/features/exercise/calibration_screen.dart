import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inteli_rehab/features/exercise/live_exercise_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design System Color Tokens (INTELI-REHAB)
// ─────────────────────────────────────────────────────────────────────────────
class _C {
  static const Color primary = Color(0xFF0F766E); // Teal core
  static const Color secondary = Color(0xFF14B8A6); // Bright cyan
  static const Color background = Color(
    0xFFF8FAFC,
  ); // Clean healthcare slate background
  static const Color card = Colors.white;
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF22C55E);
  static const Color textDark = Color(0xFF0F172A); // Dark slate/charcoal
  static const Color textMid = Color(0xFF475569);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0); // Light border
}

class _S {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double cardRadius = 24; // Spec says 20-24px
}

// ─────────────────────────────────────────────────────────────────────────────
// CalibrationScreen (Stateful for countdown, status steps, scan lines)
// ─────────────────────────────────────────────────────────────────────────────
class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen>
    with TickerProviderStateMixin {
  // Timers & Counters
  int _countdown = 5;
  bool _isCalibrated = false;
  Timer? _tickTimer;
  double _calibrationProgress = 0.0; // 0.0 to 1.0

  // Steps active flags
  // 0 = pending, 1 = loading, 2 = checked
  final List<int> _stepStates = [1, 0, 0, 0];

  // System status chips active flags
  bool _sensorsActive = false;
  bool _digitalTwinReady = false;
  bool _trackingReady = false;

  // Animation Controllers
  late final AnimationController _scanCtrl; // Shoulder to wrist scanner lines
  late final AnimationController
  _pulseCtrl; // Circular countdown card pulse glow
  late final AnimationController _finishCtrl; // Success checkmark scale

  @override
  void initState() {
    super.initState();

    // Pulse animation for calibrating circle
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Finish scale animation
    _finishCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Scan lines animation
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _startCalibration();
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _scanCtrl.dispose();
    _pulseCtrl.dispose();
    _finishCtrl.dispose();
    super.dispose();
  }

  // ── Core Calibration Flow Logic ───────────────────────────────────────────
  void _startCalibration() {
    setState(() {
      _countdown = 5;
      _isCalibrated = false;
      _calibrationProgress = 0.0;
      _stepStates[0] = 1;
      _stepStates[1] = 0;
      _stepStates[2] = 0;
      _stepStates[3] = 0;
      _sensorsActive = false;
      _digitalTwinReady = false;
      _trackingReady = false;
    });
    _finishCtrl.reset();

    // Timer fires every 1.25 seconds.
    // 4 steps * 1.25s = 5 seconds total.
    int ticks = 0;
    _tickTimer = Timer.periodic(const Duration(milliseconds: 1250), (timer) {
      if (!mounted) return;
      ticks++;
      setState(() {
        _countdown = (5 - ticks).clamp(1, 5);
        _calibrationProgress = ticks / 4.0;

        if (ticks == 1) {
          _stepStates[0] = 2; // Step 1 complete
          _stepStates[1] = 1; // Step 2 starts loading
          _sensorsActive = true;
        } else if (ticks == 2) {
          _stepStates[1] = 2; // Step 2 complete
          _stepStates[2] = 1; // Step 3 starts loading
          _digitalTwinReady = true;
        } else if (ticks == 3) {
          _stepStates[2] = 2; // Step 3 complete
          _stepStates[3] = 1; // Step 4 starts loading
        } else if (ticks == 4) {
          _stepStates[3] = 2; // All steps complete
          _trackingReady = true;
          _isCalibrated = true;
          _finishCtrl.forward();
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _C.textDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Step 3 of 6',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _C.textLight,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top linear progress bar
            LinearProgressIndicator(
              value: 3.0 / 6.0,
              backgroundColor: _C.border,
              valueColor: const AlwaysStoppedAnimation<Color>(_C.primary),
              minHeight: 4,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(_S.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title and subtitle
                    const Center(
                      child: Text(
                        'Sensor Calibration',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: _C.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'Stay still while we prepare your wearable.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _C.textMid,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Symmetrical visual card containing body illustration + sensors
                    _VisualCalibrationFrame(
                      scanValue: _scanCtrl.value,
                      pulseValue: _pulseCtrl.value,
                      countdown: _countdown,
                      progress: _calibrationProgress,
                      isCalibrated: _isCalibrated,
                      finishAnimation: _finishCtrl,
                    ),
                    const SizedBox(height: 20),

                    // System status chips
                    _SystemStatusRow(
                      sensorsActive: _sensorsActive,
                      digitalTwinReady: _digitalTwinReady,
                      trackingReady: _trackingReady,
                    ),
                    const SizedBox(height: 20),

                    // Calibration Checklist Progress Card
                    _CalibrationStatusCard(stepStates: _stepStates),
                    const SizedBox(height: 20),

                    // Stay Still reminder card
                    const _StayStillReminderCard(),
                    const SizedBox(height: 28),

                    // Action buttons
                    _ActionButtons(
                      isCalibrated: _isCalibrated,
                      onRestart: _startCalibration,
                      onStart: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LiveExerciseScreen(
                              exerciseName: 'Shoulder Rehabilitation',
                            ),
                          ),
                        );
                      },
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

// ─────────────────────────────────────────────────────────────────────────────
// Symmetrical illustration layout with scan lines and overlapping circular progress
// ─────────────────────────────────────────────────────────────────────────────
class _VisualCalibrationFrame extends StatelessWidget {
  final double scanValue;
  final double pulseValue;
  final int countdown;
  final double progress;
  final bool isCalibrated;
  final Animation<double> finishAnimation;

  const _VisualCalibrationFrame({
    required this.scanValue,
    required this.pulseValue,
    required this.countdown,
    required this.progress,
    required this.isCalibrated,
    required this.finishAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_S.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: _C.border, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_S.cardRadius),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Symmetrical body posture drawing
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 68),
              child: Row(
                children: [
                  // Left placement labels
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _PlacementLabel(
                          title: 'Upper Arm IMU',
                          desc: '(middle lateral side)',
                          alignRight: true,
                        ),
                        SizedBox(height: 48),
                        _PlacementLabel(
                          title: 'Forearm IMU',
                          desc: '(middle dorsal side)',
                          alignRight: true,
                        ),
                      ],
                    ),
                  ),

                  // Center Patient Anatomy Illustration
                  SizedBox(
                    width: 140,
                    height: 250,
                    child: CustomPaint(
                      painter: _PostoPainter(scanOffset: scanValue),
                    ),
                  ),

                  // Right placement labels
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PlacementLabel(
                          title: 'Biceps EMG',
                          desc: '(center front upper)',
                          alignRight: false,
                        ),
                        SizedBox(height: 48),
                        _PlacementLabel(
                          title: 'Triceps EMG',
                          desc: '(center back upper)',
                          alignRight: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Layered animated circular countdown card (positioned at the bottom middle)
            Positioned(
              bottom: 16,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulsing scale backing
                  Transform.scale(
                    scale: 1.0 + (pulseValue * 0.12),
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: _C.secondary.withValues(
                          alpha: 0.08 * (1.0 - pulseValue),
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Progress ring
                  SizedBox(
                    width: 82,
                    height: 82,
                    child: CircularProgressIndicator(
                      value: progress,
                      backgroundColor: _C.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        _C.primary,
                      ),
                      strokeWidth: 5.5,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // Countdown text card
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCalibrated
                          ? ScaleTransition(
                              scale: finishAnimation,
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: _C.success,
                                size: 40,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$countdown',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: _C.primary,
                                  ),
                                ),
                                const Text(
                                  'Calibrating...',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: _C.textLight,
                                  ),
                                ),
                              ],
                            ),
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

class _PlacementLabel extends StatelessWidget {
  final String title;
  final String desc;
  final bool alignRight;
  const _PlacementLabel({
    required this.title,
    required this.desc,
    required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: _C.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          desc,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: _C.textLight,
          ),
        ),
      ],
    );
  }
}

// Symmetrical patient standing painter with sensor dots and scan lines
class _PostoPainter extends CustomPainter {
  final double scanOffset; // 0 to 1
  const _PostoPainter({required this.scanOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 10;

    final bodyPaint = Paint()..color = const Color(0xFFF1F5F9);
    final borderPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final sensorPaint = Paint()
      ..color = _C.secondary
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = _C.secondary.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    // Head
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 80), width: 26, height: 32),
      bodyPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 80), width: 26, height: 32),
      borderPaint,
    );
    // Face elements
    canvas.drawCircle(
      Offset(cx - 4, cy - 82),
      1.5,
      Paint()..color = _C.textLight,
    );
    canvas.drawCircle(
      Offset(cx + 4, cy - 82),
      1.5,
      Paint()..color = _C.textLight,
    );

    // Neck
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 5, cy - 65, 10, 12),
        const Radius.circular(2),
      ),
      bodyPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 5, cy - 65, 10, 12),
        const Radius.circular(2),
      ),
      borderPaint,
    );

    // Torso (Symmetrical front/side body posture)
    final torso = Path()
      ..moveTo(cx - 20, cy - 54)
      ..lineTo(cx + 20, cy - 54)
      ..lineTo(cx + 16, cy + 20)
      ..lineTo(cx - 16, cy + 20)
      ..close();
    canvas.drawPath(torso, bodyPaint);
    canvas.drawPath(torso, borderPaint);

    // Symmetrical Legs
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 15, cy + 20, 12, 80),
        const Radius.circular(5),
      ),
      bodyPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 15, cy + 20, 12, 80),
        const Radius.circular(5),
      ),
      borderPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 3, cy + 20, 12, 80),
        const Radius.circular(5),
      ),
      bodyPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 3, cy + 20, 12, 80),
        const Radius.circular(5),
      ),
      borderPaint,
    );

    // Left arm (Static, hanging relaxed by side)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 31, cy - 50, 10, 75),
        const Radius.circular(5),
      ),
      bodyPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 31, cy - 50, 10, 75),
        const Radius.circular(5),
      ),
      borderPaint,
    );

    // Right arm (Static, hanging relaxed by side)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 21, cy - 50, 10, 75),
        const Radius.circular(5),
      ),
      bodyPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 21, cy - 50, 10, 75),
        const Radius.circular(5),
      ),
      borderPaint,
    );

    // ── Wearable sensor points (drawing on the arms) ───────────────────────
    // Upper Arm IMU (Left Arm Lateral side)
    final uArmIMU = Offset(cx - 31, cy - 25);
    canvas.drawCircle(uArmIMU, 7, glowPaint);
    canvas.drawCircle(uArmIMU, 4.5, sensorPaint);

    // Biceps EMG (Left Arm Anterior side)
    final bicepsEMG = Offset(cx - 24, cy - 25);
    canvas.drawCircle(bicepsEMG, 7, glowPaint);
    canvas.drawCircle(bicepsEMG, 4.5, sensorPaint);

    // Triceps EMG (Left Arm Posterior side)
    final tricepsEMG = Offset(cx - 34, cy - 25);
    canvas.drawCircle(tricepsEMG, 7, glowPaint);
    canvas.drawCircle(tricepsEMG, 4.5, sensorPaint);

    // Forearm IMU (Left Forearm Dorsal side)
    final fArmIMU = Offset(cx - 31, cy + 5);
    canvas.drawCircle(fArmIMU, 7, glowPaint);
    canvas.drawCircle(fArmIMU, 4.5, sensorPaint);

    // ── Symmetrical Pointer Guides ─────────────────────────────────────────
    final guideP = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(uArmIMU, Offset(cx - 50, cy - 25), guideP);
    canvas.drawLine(bicepsEMG, Offset(cx + 50, cy - 25), guideP);
    canvas.drawLine(fArmIMU, Offset(cx - 50, cy + 5), guideP);
    canvas.drawLine(tricepsEMG, Offset(cx + 50, cy + 5), guideP);

    // ── Animated Scan Lines (moving up and down the arm area) ──────────────
    final double scanY = cy - 45 + (scanOffset * 70);
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          _C.secondary.withValues(alpha: 0.60),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(cx - 38, scanY, 15, 2))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawLine(Offset(cx - 38, scanY), Offset(cx - 20, scanY), scanPaint);
  }

  @override
  bool shouldRepaint(covariant _PostoPainter old) =>
      old.scanOffset != scanOffset;
}

// ─────────────────────────────────────────────────────────────────────────────
// System Status Badges Row (Sensors Active, Digital Twin Ready, Tracking Ready)
// ─────────────────────────────────────────────────────────────────────────────
class _SystemStatusRow extends StatelessWidget {
  final bool sensorsActive;
  final bool digitalTwinReady;
  final bool trackingReady;

  const _SystemStatusRow({
    required this.sensorsActive,
    required this.digitalTwinReady,
    required this.trackingReady,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _StatusChip(label: 'Sensors Active', isActive: sensorsActive),
          const SizedBox(width: 8),
          _StatusChip(label: 'Digital Twin Ready', isActive: digitalTwinReady),
          const SizedBox(width: 8),
          _StatusChip(
            label: 'Movement Tracking Ready',
            isActive: trackingReady,
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isActive;
  const _StatusChip({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final col = isActive ? _C.primary : const Color(0xFFE2E8F0);
    final bgCol = isActive
        ? _C.primary.withValues(alpha: 0.08)
        : const Color(0xFFF1F5F9);
    final textCol = isActive ? _C.primary : _C.textLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgCol,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: col, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            const Icon(Icons.check_circle_rounded, color: _C.primary, size: 12)
          else
            const Icon(
              Icons.radio_button_unchecked_rounded,
              color: _C.textLight,
              size: 12,
            ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textCol,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Calibration Status Steps Card
// ─────────────────────────────────────────────────────────────────────────────
class _CalibrationStatusCard extends StatelessWidget {
  final List<int> stepStates; // 0 = pending, 1 = loading, 2 = complete
  const _CalibrationStatusCard({required this.stepStates});

  static const _steps = [
    'Checking IMU alignment',
    'Reading resting muscle signals',
    'Synchronizing sensor data',
    'Preparing movement tracking',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_S.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_S.cardRadius),
        border: Border.all(color: _C.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calibration Status',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _C.textDark,
            ),
          ),
          const SizedBox(height: _S.md),
          ...List.generate(
            _steps.length,
            (i) => _StepProgressRow(label: _steps[i], state: stepStates[i]),
          ),
        ],
      ),
    );
  }
}

class _StepProgressRow extends StatelessWidget {
  final String label;
  final int state; // 0=pending, 1=loading, 2=complete
  const _StepProgressRow({required this.label, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: state == 2 ? FontWeight.w700 : FontWeight.w500,
                color: state == 2
                    ? _C.textDark
                    : (state == 1 ? _C.primary : _C.textLight),
              ),
            ),
          ),
          if (state == 2)
            const Icon(Icons.check_circle_rounded, color: _C.success, size: 18)
          else if (state == 1)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_C.primary),
              ),
            )
          else
            const Icon(Icons.circle_outlined, color: _C.border, size: 18),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stay Still Reminder Card
// ─────────────────────────────────────────────────────────────────────────────
class _StayStillReminderCard extends StatelessWidget {
  const _StayStillReminderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: _S.lg, vertical: _S.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Light calming grey
        borderRadius: BorderRadius.circular(_S.cardRadius),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: _C.textLight),
              SizedBox(width: 8),
              Text(
                'STAY STILL',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _C.textLight,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ReminderItem(
                icon: Icons.accessibility_new_rounded,
                text: 'Relax your arm',
              ),
              _ReminderItem(
                icon: Icons.nature_people_rounded,
                text: 'Keep body still',
              ),
              _ReminderItem(
                icon: Icons.timer_outlined,
                text: 'Wait a few seconds',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReminderItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ReminderItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _C.primary, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: _C.textDark,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action Buttons Row (Start / Restart)
// ─────────────────────────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final bool isCalibrated;
  final VoidCallback onRestart;
  final VoidCallback onStart;

  const _ActionButtons({
    required this.isCalibrated,
    required this.onRestart,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Start Live Exercise Button
        isCalibrated
            ? Container(
                height: 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _C.primary.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: onStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Start Live Exercise',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              )
            : Container(
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'Start Live Exercise',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

        const SizedBox(height: 12),

        // Restart Calibration Button
        OutlinedButton.icon(
          onPressed: onRestart,
          icon: const Icon(Icons.replay_rounded, size: 16),
          label: const Text('Restart Calibration'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _C.primary,
            side: const BorderSide(color: _C.primary, width: 1.5),
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}
