import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inteli_rehab/core/constants/app_colors.dart';
import 'package:inteli_rehab/presentation/home/home_dashboard.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  State<NotificationPermissionScreen> createState() => _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState extends State<NotificationPermissionScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handlePermissionResponse(bool accepted) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
    });

    // Simulate HIPAA registration and permission register lag
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Route to Dashboard Screen
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
                color: AppColors.tealCore.withOpacity(0.04),
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
                color: const Color(0xFF14B8A6).withOpacity(0.04),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Title
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        "Stay Connected",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 24 : 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Get real-time feedback, sensor sync notifications,\nand daily rehabilitation exercise reminders.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),

                  // Center Vector illustration (Phone -> Notification Bell -> Wearable -> Shield)
                  Expanded(
                    child: Center(
                      child: Container(
                        height: isSmallScreen ? 260 : 320,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: SyncIllustrationPainter(
                                progress: _pulseController.value,
                                activeColor: AppColors.tealCore,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Bottom Action Buttons
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F766E).withOpacity(0.18),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () => _handlePermissionResponse(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  "Allow Notifications",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => _handlePermissionResponse(false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Not Now",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter to draw Phone -> Bell -> Wearable -> Shield layout with pulsing connection lines
class SyncIllustrationPainter extends CustomPainter {
  final double progress;
  final Color activeColor;

  SyncIllustrationPainter({
    required this.progress,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Define Node Positions
    final Offset phoneCenter = Offset(width * 0.22, height * 0.3);
    final Offset wearableCenter = Offset(width * 0.78, height * 0.3);
    final Offset bellCenter = Offset(width * 0.32, height * 0.7);
    final Offset shieldCenter = Offset(width * 0.68, height * 0.7);

    // Glowing connection line paint
    final Paint linePaint = Paint()
      ..color = activeColor.withOpacity(0.18 + 0.12 * (1.0 - progress))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final Paint pulsePaint = Paint()
      ..color = activeColor.withOpacity(0.55 * (1.0 - progress))
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw connection path lines
    canvas.drawLine(phoneCenter, wearableCenter, linePaint);
    canvas.drawLine(phoneCenter, bellCenter, linePaint);
    canvas.drawLine(wearableCenter, shieldCenter, linePaint);
    canvas.drawLine(bellCenter, shieldCenter, linePaint);

    // Draw pulsing moving connection nodes
    _drawPulsingLine(canvas, phoneCenter, wearableCenter, progress, pulsePaint);
    _drawPulsingLine(canvas, phoneCenter, bellCenter, progress, pulsePaint);
    _drawPulsingLine(canvas, wearableCenter, shieldCenter, progress, pulsePaint);
    _drawPulsingLine(canvas, bellCenter, shieldCenter, progress, pulsePaint);

    // Draw Nodes
    _drawPhone(canvas, phoneCenter, 34, 58, activeColor);
    _drawWearable(canvas, wearableCenter, 24, activeColor);
    _drawBell(canvas, bellCenter, 26, activeColor);
    _drawShield(canvas, shieldCenter, 26, activeColor);
  }

  void _drawPulsingLine(Canvas canvas, Offset start, Offset end, double progress, Paint paint) {
    final Offset currentPos = Offset.lerp(start, end, progress)!;
    canvas.drawCircle(currentPos, 4, paint);
  }

  void _drawPhone(Canvas canvas, Offset center, double width, double height, Color color) {
    final RRect outerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: width, height: height),
      const Radius.circular(8),
    );

    // Phone casing
    canvas.drawRRect(outerRect, Paint()..color = Colors.white..style = PaintingStyle.fill);
    canvas.drawRRect(
      outerRect,
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );

    // Screen content lines
    final Paint screenPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(center.dx - 10, center.dy - 12), Offset(center.dx + 10, center.dy - 12), screenPaint);
    canvas.drawLine(Offset(center.dx - 10, center.dy - 4), Offset(center.dx + 4, center.dy - 4), screenPaint);
    canvas.drawLine(Offset(center.dx - 10, center.dy + 4), Offset(center.dx + 8, center.dy + 4), screenPaint);

    // Home button dot
    canvas.drawCircle(Offset(center.dx, center.dy + 22), 2.5, Paint()..color = color);
  }

  void _drawWearable(Canvas canvas, Offset center, double radius, Color color) {
    // Watch wrist strap
    final Paint strapPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(center.dx, center.dy - 25), Offset(center.dx, center.dy + 25), strapPaint);

    // Watch head casing
    canvas.drawCircle(center, radius, Paint()..color = Colors.white..style = PaintingStyle.fill);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );

    // Watch inner display sensors (glowing heart/nodes)
    canvas.drawCircle(center, 4, Paint()..color = color);
    canvas.drawCircle(Offset(center.dx - 6, center.dy), 2.5, Paint()..color = color.withOpacity(0.4));
    canvas.drawCircle(Offset(center.dx + 6, center.dy), 2.5, Paint()..color = color.withOpacity(0.4));
  }

  void _drawBell(Canvas canvas, Offset center, double size, Color color) {
    final Path bellPath = Path();
    bellPath.moveTo(center.dx - size * 0.4, center.dy + size * 0.3);
    bellPath.quadraticBezierTo(center.dx - size * 0.4, center.dy - size * 0.2, center.dx, center.dy - size * 0.5);
    bellPath.quadraticBezierTo(center.dx + size * 0.4, center.dy - size * 0.2, center.dx + size * 0.4, center.dy + size * 0.3);
    bellPath.lineTo(center.dx - size * 0.5, center.dy + size * 0.3);
    bellPath.close();

    // Bell casing
    canvas.drawPath(bellPath, Paint()..color = Colors.white..style = PaintingStyle.fill);
    canvas.drawPath(
      bellPath,
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );

    // Bell clapper bottom
    canvas.drawCircle(Offset(center.dx, center.dy + size * 0.42), 4.5, Paint()..color = color);
  }

  void _drawShield(Canvas canvas, Offset center, double size, Color color) {
    final Path shieldPath = Path();
    shieldPath.moveTo(center.dx, center.dy - size * 0.5);
    shieldPath.quadraticBezierTo(center.dx + size * 0.4, center.dy - size * 0.4, center.dx + size * 0.45, center.dy);
    shieldPath.quadraticBezierTo(center.dx + size * 0.4, center.dy + size * 0.4, center.dx, center.dy + size * 0.6);
    shieldPath.quadraticBezierTo(center.dx - size * 0.4, center.dy + size * 0.4, center.dx - size * 0.45, center.dy);
    shieldPath.quadraticBezierTo(center.dx - size * 0.4, center.dy - size * 0.4, center.dx, center.dy - size * 0.5);
    shieldPath.close();

    // Shield casing
    canvas.drawPath(shieldPath, Paint()..color = Colors.white..style = PaintingStyle.fill);
    canvas.drawPath(
      shieldPath,
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );

    // Checkmark inside shield
    final Paint checkPaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(center.dx - 6, center.dy), Offset(center.dx - 1, center.dy + 5), checkPaint);
    canvas.drawLine(Offset(center.dx - 1, center.dy + 5), Offset(center.dx + 7, center.dy - 3), checkPaint);
  }

  @override
  bool shouldRepaint(covariant SyncIllustrationPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
