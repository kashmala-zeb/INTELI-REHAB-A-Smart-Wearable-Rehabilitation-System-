import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:inteli_rehab/presentation/exercises/widgets/twin_3d_stub.dart'
    if (dart.library.js_util) 'package:inteli_rehab/presentation/exercises/widgets/twin_3d_web.dart';
import 'package:video_player/video_player.dart';
import 'package:inteli_rehab/presentation/exercises/session_summary.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Color & Spacing Tokens
// ─────────────────────────────────────────────────────────────────────────────
const _primary = Color(0xFF0F766E);
const _secondary = Color(0xFF14B8A6);
const _success = Color(0xFF22C55E);
const _warning = Color(0xFFF97316);
const _danger = Color(0xFFEF4444);

Color _muscleColor(double pct) {
  if (pct < 30) return const Color(0xFF3B82F6); // Blue – Low
  if (pct < 55) return const Color(0xFF22C55E); // Green – Normal
  if (pct < 78) return const Color(0xFFF97316); // Orange – High
  return const Color(0xFFEF4444); // Red – Peak
}

String _fmt(int s) {
  final m = s ~/ 60;
  final sec = s % 60;
  return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Messages
// ─────────────────────────────────────────────────────────────────────────────
const _aiMessages = [
  ('Raise your arm higher', 'guide'),
  ('Excellent posture — keep it up', 'success'),
  ('Slow down the movement', 'warn'),
  ('Keep your elbow straight', 'guide'),
  ('Hold at peak — 3 seconds', 'guide'),
  ('Control the descent slowly', 'guide'),
  ('Perfect range of motion!', 'success'),
  ('Breathe out as you raise', 'guide'),
];

// ─────────────────────────────────────────────────────────────────────────────
// Live Exercise Screen
// ─────────────────────────────────────────────────────────────────────────────
class LiveExerciseScreen extends StatefulWidget {
  final String exerciseName;
  final int targetReps;
  final int totalSeconds;

  const LiveExerciseScreen({
    super.key,
    this.exerciseName = 'Shoulder Rehabilitation',
    this.targetReps = 12,
    this.totalSeconds = 300,
  });

  @override
  State<LiveExerciseScreen> createState() => _LiveExerciseScreenState();
}

class _LiveExerciseScreenState extends State<LiveExerciseScreen>
    with TickerProviderStateMixin {
  // ── Exercise state ─────────────────────────────────────────────────────────
  int _elapsed = 155;
  int _reps = 8;
  double _romDeg = 84;
  double _bicepsPct = 72;
  double _deltoidPct = 58;
  double _forearmPct = 40;
  final double _accuracy = 95;
  int _msgIdx = 0;
  bool _isPaused = false;

  // ── Voice Guidance State ───────────────────────────────────────────────────
  final FlutterTts _tts = FlutterTts();
  bool _voiceEnabled = true;

  // ── Digital Twin transform ─────────────────────────────────────────────────
  double _rotY = -10;
  double _rotX = -5;
  double _zoom = 1.0;
  Offset? _dragOrigin;

  // ── Arm pose (driven by animation) ─────────────────────────────────────────
  double _armAngle = 8;
  double _elbowFlex = 20;

  // ── Animation controllers ───────────────────────────────────────────────────
  late AnimationController _exerciseCtrl; // drives arm oscillation

  int _frameCount = 0;
  int _lastRepCycle = 0;
  Timer? _clockTimer;
  Timer? _msgTimer;
  VideoPlayerController? _videoCtrl;
  bool _isVideoReady = false;

  @override
  void initState() {
    super.initState();

    // Initialize TTS settings
    _initTts();

    // ── Arm animation: ticks every 16ms (~60fps) ──────────────────────────────
    _exerciseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16));
    _exerciseCtrl.addListener(_onExerciseTick);
    _exerciseCtrl.repeat();


    // ── 1-second clock timer ──────────────────────────────────────────────────
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused && mounted) {
        setState(() {
          if (_elapsed < widget.totalSeconds) _elapsed++;
        });
      }
    });

    // ── AI message rotation every 3.8s ────────────────────────────────────────
    _msgTimer = Timer.periodic(const Duration(milliseconds: 3800), (_) {
      if (!_isPaused && mounted) {
        setState(() {
          _msgIdx = (_msgIdx + 1) % _aiMessages.length;
        });
        _speak(_aiMessages[_msgIdx].$1);
      }
    });

    final bool isPronation = widget.exerciseName.toLowerCase().contains('pronation');
    if (isPronation) {
      _videoCtrl = VideoPlayerController.asset('assets/videos/pronation.mp4')
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoReady = true;
            });
            _videoCtrl?.setLooping(true);
            _videoCtrl?.setVolume(0.0);
            _videoCtrl?.play();
          }
        });
    }
  }

  void _initTts() {
    _tts.setSpeechRate(0.48);
    _tts.setVolume(1.0);
    _tts.setPitch(1.0);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _speak(_aiMessages[_msgIdx].$1);
      }
    });
  }

  Future<void> _speak(String text) async {
    if (!_voiceEnabled || _isPaused) return;
    try {
      await _tts.stop();
      await _tts.setLanguage('en-US');
      await _tts.speak(text);
    } catch (e) {
      debugPrint("TTS error: $e");
    }
  }

  void _onExerciseTick() {
    if (_isPaused || !mounted) return;
    setState(() {
      _frameCount++;
      final t = _frameCount / 60.0;

      final cycleT = (t % 5) / 5;
      final phase = math.sin(cycleT * 2 * math.pi);
      _armAngle = 8 + 64 * math.max(0.0, phase);
      _elbowFlex = 15 + 30 * math.max(0.0, phase);
      _romDeg = 8 + 92 * math.max(0.0, phase);

      final peak = math.max(0.0, phase);
      _bicepsPct = 35 + 55 * peak;
      _deltoidPct = 42 + 46 * peak;
      _forearmPct = 28 + 30 * peak;

      final cycle = (t / 5).floor();
      if (cycle > _lastRepCycle) {
        _lastRepCycle = cycle;
        if (_reps < widget.targetReps) {
          _reps++;
          HapticFeedback.lightImpact();

          if (_reps == widget.targetReps) {
            _navigateToSummary();
          }
        }
      }
    });
  }

  void _navigateToSummary() {
    _clockTimer?.cancel();
    _msgTimer?.cancel();
    _tts.stop();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseSummaryScreen(
          exerciseName: widget.exerciseName,
          repsCompleted: _reps,
          targetReps: widget.targetReps,
          accuracy: _accuracy,
          maxRom: _romDeg.round(),
          durationText: _fmt(_elapsed))));
  }

  @override
  void dispose() {
    _tts.stop();
    _exerciseCtrl.removeListener(_onExerciseTick);
    _exerciseCtrl.dispose();
    _clockTimer?.cancel();
    _msgTimer?.cancel();
    _videoCtrl?.dispose();
    super.dispose();
  }

  void _resetView() => setState(() {
    _rotY = -10;
    _rotX = -5;
    _zoom = 1.0;
  });
  void _zoomIn() => setState(() => _zoom = (_zoom + 0.18).clamp(0.55, 1.9));
  void _zoomOut() => setState(() => _zoom = (_zoom - 0.18).clamp(0.55, 1.9));

  @override
  Widget build(BuildContext context) {
    final msg = _aiMessages[_msgIdx];
    final msgText = msg.$1;
    final msgType = msg.$2;
    final msgColor = msgType == 'success'
        ? _success
        : msgType == 'warn'
        ? _warning
        : _primary;

    final progressPct = _elapsed / widget.totalSeconds;

    Widget? videoPlayerWidget;
    if (_videoCtrl != null && _isVideoReady) {
      videoPlayerWidget = FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: _videoCtrl!.value.size.width,
          height: _videoCtrl!.value.size.height,
          child: VideoPlayer(_videoCtrl!),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => _showStopDialog(),
        ),
        centerTitle: true,
        title: Text(
          widget.exerciseName.toUpperCase(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: Colors.black54,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _voiceEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: _voiceEnabled ? _primary : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _voiceEnabled = !_voiceEnabled;
              });
              if (_voiceEnabled) {
                _speak(msgText);
              } else {
                _tts.stop();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Stats Row (Reps and ROM)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reps Completed
                  Expanded(
                    child: Column(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                            ),
                            children: [
                              TextSpan(text: '$_reps'),
                              TextSpan(
                                text: '/${widget.targetReps}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'REPS COMPLETED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.black38,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Vertical divider
                  Container(
                    width: 1,
                    height: 50,
                    color: const Color(0xFFE2E8F0),
                  ),
                  // Current ROM
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${_romDeg.round()}°',
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'CURRENT ROM',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.black38,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Timer & Progress Bar
              Column(
                children: [
                  Text(
                    'TIME: ${_fmt(_elapsed)} / ${_fmt(widget.totalSeconds)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressPct,
                      minHeight: 4,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: const AlwaysStoppedAnimation(_primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. AI Coach Card (clean, English only)
              _AICoachCard(
                message: msgText,
                color: msgColor,
              ),
              const SizedBox(height: 24),

              // 4. Digital Twin Card (Premium Dark Slate Viewport)
              SizedBox(
                height: 480,
                child: _DigitalTwinCard(
                  videoPlayer: videoPlayerWidget,
                  armAngle: _armAngle,
                  elbowFlex: _elbowFlex,
                  bicepsPct: _bicepsPct,
                  deltoidPct: _deltoidPct,
                  forearmPct: _forearmPct,
                  romDeg: _romDeg.round(),
                  rotY: _rotY,
                  rotX: _rotX,
                  zoom: _zoom,
                  onPanStart: (d) => _dragOrigin = d.globalPosition,
                  onPanUpdate: (d) {
                    if (_dragOrigin == null) return;
                    final dx = d.globalPosition.dx - _dragOrigin!.dx;
                    final dy = d.globalPosition.dy - _dragOrigin!.dy;
                    setState(() {
                      _rotY = (_rotY + dx * 0.45).clamp(-55, 55);
                      _rotX = (_rotX + dy * 0.30).clamp(-25, 25);
                      _dragOrigin = d.globalPosition;
                    });
                  },
                  onPanEnd: (_) => _dragOrigin = null,
                  onReset: _resetView,
                  onZoomIn: _zoomIn,
                  onZoomOut: _zoomOut,
                ),
              ),
              const SizedBox(height: 32),

              // 5. Session Controls
              _SessionControls(
                isPaused: _isPaused,
                onPause: () {
                  setState(() => _isPaused = true);
                  _tts.stop();
                },
                onResume: () {
                  setState(() => _isPaused = false);
                  _speak(msgText);
                },
                onStop: () => _showStopDialog(),
                onPass: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    if (_reps < widget.targetReps) {
                      _reps++;
                      if (_reps == widget.targetReps) {
                        _navigateToSummary();
                      }
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showStopDialog() {
    setState(() => _isPaused = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Stop Session?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18)),
        content: const Text(
          'Are you sure you want to stop this session? Your progress will be saved.',
          style: TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isPaused = false);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _danger,
              foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Pop AlertDialog
              _navigateToSummary(); // Navigate to Summary Screen
            },
            child: const Text(
              'Stop',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600))),
        ]));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Digital Twin Card
// ─────────────────────────────────────────────────────────────────────────────
class _DigitalTwinCard extends StatelessWidget {
  final double armAngle, elbowFlex, bicepsPct, deltoidPct, forearmPct;
  final int romDeg;
  final double rotY, rotX, zoom;
  final void Function(DragStartDetails) onPanStart;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function(DragEndDetails) onPanEnd;
  final VoidCallback onReset, onZoomIn, onZoomOut;
  final Widget? videoPlayer;

  const _DigitalTwinCard({
    required this.armAngle,
    required this.elbowFlex,
    required this.bicepsPct,
    required this.deltoidPct,
    required this.forearmPct,
    required this.romDeg,
    required this.rotY,
    required this.rotX,
    required this.zoom,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onReset,
    required this.onZoomIn,
    required this.onZoomOut,
    this.videoPlayer,
  });

  @override
  Widget build(BuildContext context) {
    if (videoPlayer != null) {
      return Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: videoPlayer!),
            // "VIDEO GUIDANCE" badge
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'VIDEO GUIDANCE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final Widget viewer = build3DViewer(
      armAngle: armAngle,
      elbowFlex: elbowFlex,
      bicepsPct: bicepsPct,
      deltoidPct: deltoidPct,
      forearmPct: forearmPct,
      romDeg: romDeg,
      rotY: rotY,
      rotX: rotX,
      zoom: zoom,
    );

    final bool is3D = viewer is! SizedBox;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background grid (subtle dark style)
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(
                gridColor: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),

          // 3D/2D Viewer
          Positioned.fill(
            child: is3D
                ? viewer
                : GestureDetector(
                    onPanStart: onPanStart,
                    onPanUpdate: onPanUpdate,
                    onPanEnd: onPanEnd,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(rotY * math.pi / 180)
                        ..rotateX(rotX * math.pi / 180)
                        // ignore: deprecated_member_use
                        ..scale(zoom, zoom, 1.0),
                      child: CustomPaint(
                        painter: _DigitalTwinPainter(
                          armAngle: armAngle,
                          elbowFlex: elbowFlex,
                          bicepsPct: bicepsPct,
                          deltoidPct: deltoidPct,
                          forearmPct: forearmPct,
                          romDeg: romDeg,
                        ),
                        size: const Size(double.infinity, double.infinity),
                      ),
                    ),
                  ),
          ),

          // "DIGITAL TWIN · LIVE" badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'DIGITAL TWIN · LIVE',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Drag hint
          const Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'DRAG TO ROTATE',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: Colors.white30,
                  ),
                ),
              ],
            ),
          ),

          // Controls (Reset / Zoom)
          Positioned(
            top: 12,
            right: 12,
            child: Column(
              children: [
                _TwinControlBtn(
                  icon: Icons.refresh_rounded,
                  onTap: onReset,
                ),
                const SizedBox(height: 6),
                _TwinControlBtn(
                  icon: Icons.add_rounded,
                  onTap: onZoomIn,
                ),
                const SizedBox(height: 6),
                _TwinControlBtn(
                  icon: Icons.remove_rounded,
                  onTap: onZoomOut,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TwinControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TwinControlBtn({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grid Painter (background of digital twin card)
// ─────────────────────────────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  final Color gridColor;
  _GridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8;
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Digital Twin Painter
// ─────────────────────────────────────────────────────────────────────────────
class _DigitalTwinPainter extends CustomPainter {
  final double armAngle, elbowFlex, bicepsPct, deltoidPct, forearmPct;
  final int romDeg;

  const _DigitalTwinPainter({
    required this.armAngle,
    required this.elbowFlex,
    required this.bicepsPct,
    required this.deltoidPct,
    required this.forearmPct,
    required this.romDeg,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 240;
    final scaleY = size.height / 250;
    final scale = math.min(scaleX, scaleY) * 0.9;
    final tx = (size.width - 240 * scale) / 2;
    final ty = (size.height - 250 * scale) / 2;

    canvas.save();
    canvas.translate(tx, ty);
    canvas.scale(scale);
    _drawFigure(canvas);
    canvas.restore();
  }

  void _drawFigure(Canvas canvas) {
    final bicepsColor = _muscleColor(bicepsPct);
    final deltoidColor = _muscleColor(deltoidPct);
    final forearmColor = _muscleColor(forearmPct);

    const shoulderX = 163.0;
    const shoulderY = 72.0;
    const upperArmLen = 52.0;
    const forearmLen = 42.0;

    final rad = math.pi / 180;
    final elbowX = shoulderX + upperArmLen * math.sin(armAngle * rad);
    final elbowY = shoulderY + upperArmLen * math.cos(armAngle * rad);

    final forearmAngle = armAngle - elbowFlex;
    final wristX = elbowX + forearmLen * math.sin(forearmAngle * rad);
    final wristY = elbowY + forearmLen * math.cos(forearmAngle * rad);

    // ── HEAD ─────────────────────────────────────────────────────────────────
    final headFill = Paint()..color = const Color(0xFFE2E8F0);
    final headStroke = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(120, 22), width: 38, height: 44),
      headFill);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(120, 22), width: 38, height: 44),
      headStroke);

    // Eyes
    final eyeFill = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.5);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(112, 18), width: 6, height: 7),
      eyeFill);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(128, 18), width: 6, height: 7),
      eyeFill);

    // Smile
    final smilePath = Path()
      ..moveTo(113, 28)
      ..quadraticBezierTo(120, 33, 127, 28);
    canvas.drawPath(
      smilePath,
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round);

    // Hair
    final hairPath = Path()
      ..moveTo(101, 16)
      ..quadraticBezierTo(103, 4, 120, 2)
      ..quadraticBezierTo(137, 4, 139, 16);
    canvas.drawPath(
      hairPath,
      Paint()..color = const Color(0xFFCBD5E1).withValues(alpha: 0.7));

    // ── NECK ─────────────────────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(113, 40, 14, 22),
        const Radius.circular(7)),
      Paint()..color = const Color(0xFFD1D5DB));

    // ── TORSO ────────────────────────────────────────────────────────────────
    final torsoPath = Path()
      ..moveTo(77, 62)
      ..quadraticBezierTo(72, 70, 74, 105)
      ..quadraticBezierTo(76, 130, 80, 148)
      ..lineTo(160, 148)
      ..quadraticBezierTo(164, 130, 166, 105)
      ..quadraticBezierTo(168, 70, 163, 62)
      ..quadraticBezierTo(142, 54, 120, 54)
      ..quadraticBezierTo(98, 54, 77, 62)
      ..close();
    canvas.drawPath(torsoPath, Paint()..color = const Color(0xFFE2E8F0));
    canvas.drawPath(
      torsoPath,
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2);

    // Clavicle
    final clavPath = Path()
      ..moveTo(83, 65)
      ..quadraticBezierTo(120, 59, 157, 65);
    canvas.drawPath(
      clavPath,
      Paint()
        ..color = const Color(0xFF94A3B8).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);

    // Rib lines
    for (final y in [82.0, 96.0, 110.0, 124.0]) {
      final ribPath = Path()
        ..moveTo(88, y)
        ..quadraticBezierTo(120, y - 3, 152, y);
      canvas.drawPath(
        ribPath,
        Paint()
          ..color = const Color(0xFF94A3B8).withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7);
    }

    // ── LEFT SHOULDER JOINT ───────────────────────────────────────────────────
    canvas.drawCircle(
      const Offset(77, 68),
      11,
      Paint()..color = const Color(0xFFD1D5DB));
    canvas.drawCircle(
      const Offset(77, 68),
      11,
      Paint()
        ..color = const Color(0xFFC1C9D4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2);

    // ── LEFT ARM (passive / resting) ──────────────────────────────────────────
    final passiveFill = Paint()..color = const Color(0xFFD1D5DB);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(70, 68, 14, 50),
        const Radius.circular(7)),
      passiveFill);
    canvas.drawCircle(
      const Offset(77, 118),
      8,
      Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(71, 118, 12, 38),
        const Radius.circular(6)),
      passiveFill);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(77, 162), width: 16, height: 20),
      Paint()..color = const Color(0xFFE2E8F0));

    // ── RIGHT SHOULDER — DELTOID GLOW ─────────────────────────────────────────
    canvas.drawCircle(
      const Offset(shoulderX, shoulderY),
      20,
      Paint()
        ..color = deltoidColor.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawCircle(
      const Offset(shoulderX, shoulderY),
      14,
      Paint()..color = deltoidColor.withValues(alpha: 0.55));
    canvas.drawCircle(
      const Offset(shoulderX, shoulderY),
      10,
      Paint()..color = deltoidColor.withValues(alpha: 0.80));
    canvas.drawCircle(
      const Offset(shoulderX, shoulderY),
      7,
      Paint()..color = const Color(0xFF94A3B8));
    canvas.drawCircle(
      const Offset(shoulderX, shoulderY),
      7,
      Paint()
        ..color = const Color(0xFF64748B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);

    // ── RIGHT UPPER ARM ───────────────────────────────────────────────────────
    final midUpperX = (shoulderX + elbowX) / 2;
    final midUpperY = (shoulderY + elbowY) / 2;

    // Biceps highlight ellipse
    canvas.save();
    canvas.translate(midUpperX, midUpperY);
    canvas.rotate(armAngle * rad);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 22, height: 50),
      Paint()..color = bicepsColor.withValues(alpha: 0.65));
    canvas.restore();

    // Triceps hint
    canvas.save();
    canvas.translate(midUpperX + 4, midUpperY);
    canvas.rotate(armAngle * rad);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 14, height: 42),
      Paint()..color = const Color(0xFF3B82F6).withValues(alpha: 0.18));
    canvas.restore();

    // Upper arm bone
    canvas.drawLine(
      const Offset(shoulderX, shoulderY),
      Offset(elbowX, elbowY),
      Paint()
        ..color = const Color(0xFFB0BEC5).withValues(alpha: 0.7)
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round);

    // Elbow joint
    canvas.drawCircle(
      Offset(elbowX, elbowY),
      8,
      Paint()..color = const Color(0xFF94A3B8));
    canvas.drawCircle(
      Offset(elbowX, elbowY),
      8,
      Paint()
        ..color = const Color(0xFF64748B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);

    // ── RIGHT FOREARM ─────────────────────────────────────────────────────────
    final midForeX = (elbowX + wristX) / 2;
    final midForeY = (elbowY + wristY) / 2;

    canvas.save();
    canvas.translate(midForeX, midForeY);
    canvas.rotate(forearmAngle * rad);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 16, height: 38),
      Paint()..color = forearmColor.withValues(alpha: 0.45));
    canvas.restore();

    // Forearm bone
    canvas.drawLine(
      Offset(elbowX, elbowY),
      Offset(wristX, wristY),
      Paint()
        ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.85)
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round);

    // Wrist
    canvas.drawCircle(
      Offset(wristX, wristY),
      6,
      Paint()..color = const Color(0xFF94A3B8));

    // Hand
    final handX = wristX + 5 * math.sin(forearmAngle * rad);
    final handY = wristY + 5 * math.cos(forearmAngle * rad);
    canvas.save();
    canvas.translate(handX, handY);
    canvas.rotate(forearmAngle * rad);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 16, height: 20),
      Paint()..color = const Color(0xFFE2E8F0));
    canvas.restore();

    // ── ROM ARC ───────────────────────────────────────────────────────────────
    const arcR = 36.0;
    final arcRect = Rect.fromCircle(
      center: const Offset(shoulderX, shoulderY),
      radius: arcR);
    canvas.drawArc(
      arcRect,
      math.pi / 2,
      -(armAngle * rad),
      false,
      Paint()
        ..color = _secondary.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round);

    // ROM degree label
    final labelX = shoulderX + (arcR + 10) * math.sin((armAngle / 2) * rad);
    final labelY = shoulderY + (arcR + 10) * math.cos((armAngle / 2) * rad);
    _drawText(
      canvas,
      '$romDeg°',
      Offset(labelX - 6, labelY - 4),
      _primary,
      8,
      FontWeight.w700);

    // ── MUSCLE LABELS ─────────────────────────────────────────────────────────
    // Deltoid
    canvas.drawLine(
      Offset(shoulderX + 11, shoulderY - 4),
      Offset(shoulderX + 20, shoulderY - 12),
      Paint()
        ..color = deltoidColor.withValues(alpha: 0.8)
        ..strokeWidth = 0.8);
    _drawText(
      canvas,
      'DELTOID',
      Offset(shoulderX + 22, shoulderY - 17),
      deltoidColor,
      6.5,
      FontWeight.w800);

    // Biceps
    canvas.drawLine(
      Offset(midUpperX + 11, midUpperY),
      Offset(midUpperX + 22, midUpperY),
      Paint()
        ..color = bicepsColor.withValues(alpha: 0.8)
        ..strokeWidth = 0.8);
    _drawText(
      canvas,
      'BICEPS',
      Offset(midUpperX + 24, midUpperY + 3),
      bicepsColor,
      6.5,
      FontWeight.w800);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos,
    Color color,
    double size,
    FontWeight weight) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: weight)),
      textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant _DigitalTwinPainter old) =>
      old.armAngle != armAngle ||
      old.bicepsPct != bicepsPct ||
      old.deltoidPct != deltoidPct ||
      old.forearmPct != forearmPct;
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Coach Card
// ─────────────────────────────────────────────────────────────────────────────
class _AICoachCard extends StatelessWidget {
  final String message;
  final Color color;

  const _AICoachCard({
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2)),
        ]),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(colors: [_primary, _secondary]),
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI COACH',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: _primary)),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    message,
                    key: ValueKey(message),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis)),
              ])),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Session Controls
// ─────────────────────────────────────────────────────────────────────────────
class _SessionControls extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onPause, onResume, onStop, onPass;
  const _SessionControls({
    required this.isPaused,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    required this.onPass,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isPaused)
          ElevatedButton.icon(
            onPressed: onPause,
            icon: const Icon(Icons.pause_rounded, size: 18),
            label: const Text('Pause'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: onResume,
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text('Resume'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: onPass,
          icon: const Icon(Icons.skip_next_rounded, size: 18),
          label: const Text('Pass Rep'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF64748B),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: onStop,
          icon: const Icon(Icons.stop_rounded, size: 18),
          label: const Text('End'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _danger,
            side: const BorderSide(color: Color(0xFFFECACA), width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}
