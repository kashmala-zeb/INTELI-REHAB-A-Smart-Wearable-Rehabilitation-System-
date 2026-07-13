import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'twin_3d_stub.dart' if (dart.library.js_util) 'twin_3d_web.dart';
import 'package:video_player/video_player.dart';
import 'package:inteli_rehab/features/exercise/exercise_summary_screen.dart';


const Map<String, String> _urduTranslations = {
  'Raise your arm higher': 'اپنا ہاتھ اور اوپر اٹھائیں',
  'Excellent posture — keep it up': 'بہترین پوزیشن - ایسے ہی رکھیں',
  'Slow down the movement': 'حرکت آہستہ کریں',
  'Keep your elbow straight': 'اپنی کہنی سیدھی رکھیں',
  'Hold at peak — 3 seconds': 'اوپر روکیں - ۳ سیکنڈ کے لیے',
  'Control the descent slowly': 'آہستہ آہستہ ہاتھ نیچے لائیں',
  'Perfect range of motion!': 'حرکت کا دائرہ بالکل ٹھیک ہے!',
  'Breathe out as you raise': 'اوپر اٹھاتے ہوئے سانس باہر نکالیں',
};

const Map<String, String> _romanUrduTranslations = {
  'Raise your arm higher': 'Apna haath aur oopar uthain',
  'Excellent posture — keep it up': 'Behtareen position, aise hi rakhain',
  'Slow down the movement': 'Harkat aahista karain',
  'Keep your elbow straight': 'Apni kohnee seedhi rakhain',
  'Hold at peak — 3 seconds': 'Oopar rokain, teen second ke liye',
  'Control the descent slowly': 'Aahista aahista haath neeche lain',
  'Perfect range of motion!': 'Harkat ka daira bilkul theek hai',
  'Breathe out as you raise': 'Oopar uthatay huay saans bahar nikalain',
};

// ─────────────────────────────────────────────────────────────────────────────
// Color & Spacing Tokens
// ─────────────────────────────────────────────────────────────────────────────
const _primary = Color(0xFF0F766E);
const _secondary = Color(0xFF14B8A6);
const _bg = Color(0xFFF8FAFC);
const _card = Colors.white;
const _success = Color(0xFF22C55E);
const _warning = Color(0xFFF97316);
const _danger = Color(0xFFEF4444);

Color _muscleColor(double pct) {
  if (pct < 30) return const Color(0xFF3B82F6); // Blue – Low
  if (pct < 55) return const Color(0xFF22C55E); // Green – Normal
  if (pct < 78) return const Color(0xFFF97316); // Orange – High
  return const Color(0xFFEF4444); // Red – Peak
}

String _muscleLabel(double pct) {
  if (pct < 30) return 'Low';
  if (pct < 55) return 'Normal';
  if (pct < 78) return 'High';
  return 'Peak';
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
  double _tricepsPct = 28;
  double _deltoidPct = 58;
  double _forearmPct = 40;
  final double _accuracy = 95;
  int _msgIdx = 0;
  bool _isPaused = false;
  bool _repFlash = false;

  // ── Voice Guidance State ───────────────────────────────────────────────────
  final FlutterTts _tts = FlutterTts();
  bool _voiceEnabled = true;
  String _voiceLanguage = 'EN'; // 'EN' or 'UR'

  // ── Digital Twin transform ─────────────────────────────────────────────────
  double _rotY = -10;
  double _rotX = -5;
  double _zoom = 1.0;
  Offset? _dragOrigin;

  // ── Arm pose (driven by animation) ─────────────────────────────────────────
  double _armAngle = 8;
  double _elbowFlex = 20;

  // ── Animation controllers ───────────────────────────────────────────────────
  late AnimationController
  _exerciseCtrl; // drives arm oscillation (~16ms per frame)
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

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

    // ── Pulse for live dots ───────────────────────────────────────────────────
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.5,
      end: 1.0).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

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
            _videoCtrl?.play();
          }
        });
    }
  }


  void _initTts() {
    _tts.setSpeechRate(0.5);
    _tts.setVolume(1.0);
    _tts.setPitch(1.0);

    // Speak initial message after widget builds
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
      if (_voiceLanguage == 'UR') {
        final urText = _urduTranslations[text] ?? text;
        final romanText = _romanUrduTranslations[text] ?? text;

        // Check if Urdu locale is supported by system/browser using dynamic casts
        bool hasUrdu = false;
        try {
          final dynamic result = await _tts.isLanguageAvailable('ur-PK');
          final dynamic resultAlt = await _tts.isLanguageAvailable('ur');
          hasUrdu =
              (result == true ||
              result == 1 ||
              resultAlt == true ||
              resultAlt == 1);
        } catch (_) {
          hasUrdu = false;
        }

        if (hasUrdu) {
          // Native Urdu is supported!
          final dynamic langResult = await _tts.setLanguage('ur-PK');
          if (langResult != true && langResult != 1) {
            await _tts.setLanguage('ur');
          }

          // Scan available voices for a female Urdu speaker
          try {
            dynamic voices = await _tts.getVoices;
            if (voices != null && voices is List) {
              bool foundVoice = false;
              for (var voice in voices) {
                if (voice is Map) {
                  final String name = voice["name"]?.toString() ?? "";
                  final String locale = voice["locale"]?.toString() ?? "";

                  if (locale.toLowerCase().contains("ur")) {
                    if (name.toLowerCase().contains("uzma") ||
                        name.toLowerCase().contains("female") ||
                        name.toLowerCase().contains("google") ||
                        name.toLowerCase().contains("sfg") ||
                        name.toLowerCase().contains("local")) {
                      await _tts.setVoice({
                        "name": voice["name"],
                        "locale": voice["locale"],
                      });
                      foundVoice = true;
                      break;
                    }
                  }
                }
              }
              if (!foundVoice) {
                for (var voice in voices) {
                  if (voice is Map) {
                    final String locale = voice["locale"]?.toString() ?? "";
                    if (locale.toLowerCase().contains("ur")) {
                      await _tts.setVoice({
                        "name": voice["name"],
                        "locale": voice["locale"],
                      });
                      break;
                    }
                  }
                }
              }
            }
          } catch (e) {
            debugPrint("Failed selecting native voice: $e");
          }

          await _tts.setSpeechRate(0.40); // Fluent Urdu pace
          await _tts.setPitch(1.1); // Slightly higher pitch for female voice
          await _tts.speak(urText);
        } else {
          // Native Urdu is not supported on this machine.
          // Fallback: Use Indian English (en-IN) engine to speak Roman Urdu phonetically.
          // Indian-English TTS voice engine pronounces Romanized Urdu words perfectly!
          bool hasIndianEnglish = false;
          try {
            final dynamic result = await _tts.isLanguageAvailable('en-IN');
            hasIndianEnglish = (result == true || result == 1);
          } catch (_) {
            hasIndianEnglish = false;
          }

          if (hasIndianEnglish) {
            await _tts.setLanguage('en-IN');
          } else {
            await _tts.setLanguage('en-US');
          }

          // Scan for a female Indian/English voice (often named Google, Premium, or contains female)
          try {
            dynamic voices = await _tts.getVoices;
            if (voices != null && voices is List) {
              for (var voice in voices) {
                if (voice is Map) {
                  final String name = voice["name"]?.toString() ?? "";
                  final String locale = voice["locale"]?.toString() ?? "";
                  if (locale.toLowerCase().contains("in") ||
                      locale.toLowerCase().contains("en")) {
                    if (name.toLowerCase().contains("female") ||
                        name.toLowerCase().contains("google") ||
                        name.toLowerCase().contains("local")) {
                      await _tts.setVoice({
                        "name": voice["name"],
                        "locale": voice["locale"],
                      });
                      break;
                    }
                  }
                }
              }
            }
          } catch (_) {}

          await _tts.setSpeechRate(
            0.38); // Slower speech rate so phonetics sound clear and natural
          await _tts.setPitch(
            1.15); // Slightly higher pitch for clear female articulation
          await _tts.speak(romanText); // Speak the Romanized Urdu phrasings
        }
      } else {
        await _tts.setLanguage('en-US');
        await _tts.setSpeechRate(0.5);
        await _tts.setPitch(1.0);
        await _tts.speak(text);
      }
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
      _tricepsPct = 18 + 28 * (1 - peak);
      _forearmPct = 28 + 30 * peak;

      final cycle = (t / 5).floor();
      if (cycle > _lastRepCycle) {
        _lastRepCycle = cycle;
        if (_reps < widget.targetReps) {
          _reps++;
          HapticFeedback.lightImpact();
          _repFlash = true;

          if (_reps == widget.targetReps) {
            _navigateToSummary();
          } else {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) setState(() => _repFlash = false);
            });
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
    _pulseCtrl.dispose();
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

  // ── Build ──────────────────────────────────────────────────────────────────
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
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────────────
              _buildHeader(progressPct),

              // ── Digital Twin ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 210,
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
                    onZoomOut: _zoomOut))),

              const SizedBox(height: 8),

              // ── Metrics Row ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Reps
                    Expanded(
                      flex: 3,
                      child: _RepsCard(
                        reps: _reps,
                        target: widget.targetReps,
                        flash: _repFlash)),
                    const SizedBox(width: 8),
                    // ROM
                    Expanded(flex: 3, child: _ROMCard(romDeg: _romDeg.round())),
                    const SizedBox(width: 8),
                    // Muscle Activity
                    Expanded(
                      flex: 6,
                      child: _MuscleActivityCard(
                        bicepsPct: _bicepsPct,
                        tricepsPct: _tricepsPct)),
                  ])),

              const SizedBox(height: 6),

              // ── Accuracy ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _AccuracyCard(accuracy: _accuracy)),

              const SizedBox(height: 8),

              // ── AI Coach ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _AICoachCard(
                  message: msgText,
                  color: msgColor,
                  pulseAnim: _pulseAnim,
                  voiceEnabled: _voiceEnabled,
                  voiceLanguage: _voiceLanguage,
                  onVoiceToggle: () {
                    setState(() {
                      _voiceEnabled = !_voiceEnabled;
                    });
                    if (_voiceEnabled) {
                      _speak(msgText);
                    } else {
                      _tts.stop();
                    }
                  },
                  onLanguageToggle: () {
                    setState(() {
                      _voiceLanguage = _voiceLanguage == 'EN' ? 'UR' : 'EN';
                    });
                    _speak(msgText);
                  })),

              const SizedBox(height: 10),

              // ── Session Controls ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SessionControls(
                  isPaused: _isPaused,
                  onPause: () {
                    setState(() => _isPaused = true);
                    _tts.stop();
                  },
                  onResume: () {
                    setState(() => _isPaused = false);
                    _speak(msgText);
                  },
                  onStop: () => _showStopDialog())),

              const SizedBox(height: 8),
            ])), // SingleChildScrollView
      ));
  }

  // ── Header: status + title + timer + progress bar ──────────────────────────
  Widget _buildHeader(double progressPct) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (_, __) => Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _success,
                              boxShadow: [
                                BoxShadow(
                                  color: _success.withValues(
                                    alpha: _pulseAnim.value * 0.5),
                                  blurRadius: 6,
                                  spreadRadius: 2),
                              ]))),
                        const SizedBox(width: 6),
                        Text(
                          'EXERCISE IN PROGRESS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: _primary)),
                      ]),
                    const SizedBox(height: 3),
                    Text(
                      widget.exerciseName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B))),
                    const SizedBox(height: 2),
                    const Text(
                      'Lateral Raise · Set 2 of 3',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w400)),
                  ])),
              // Timer card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF99F6E4))),
                child: Column(
                  children: [
                    const Text(
                      'TIME',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                        color: Color(0xFF5EEAD4))),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _primary),
                        children: [
                          TextSpan(text: _fmt(_elapsed)),
                          const TextSpan(
                            text: ' / ',
                            style: TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontWeight: FontWeight.w400)),
                          TextSpan(
                            text: _fmt(widget.totalSeconds),
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                        ])),
                  ])),
            ]),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressPct,
              minHeight: 5,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation(_secondary))),
          const SizedBox(height: 10),
        ]));
  }

  void _showStopDialog() {
    setState(() => _isPaused = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Stop Exercise?',
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
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFCCFBF1)),
          boxShadow: [
            BoxShadow(
              color: _primary.withValues(alpha: 0.14),
              blurRadius: 32,
              offset: const Offset(0, 6)),
          ],
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
                  color: const Color(0xF0F0FDFA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF99F6E4))),
                child: const Text(
                  'VIDEO GUIDANCE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: _primary)))),
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
      zoom: zoom);

    // If the helper returns a SizedBox.shrink() (like on stub), fallback to 2D
    final bool is3D = viewer is! SizedBox;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFCCFBF1)),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.14),
            blurRadius: 32,
            offset: const Offset(0, 6)),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFFF0FDFA), Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight)),
      child: Stack(
        children: [
          // Background grid
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),

          // Draggable Twin (3D Viewer if on web, otherwise 2D stick-figure fallback)
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
                        ..scale(zoom, zoom, 1.0),
                      child: CustomPaint(
                        painter: _DigitalTwinPainter(
                          armAngle: armAngle,
                          elbowFlex: elbowFlex,
                          bicepsPct: bicepsPct,
                          deltoidPct: deltoidPct,
                          forearmPct: forearmPct,
                          romDeg: romDeg),
                        size: const Size(double.infinity, double.infinity))))),

          // "DIGITAL TWIN · LIVE" badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xF0F0FDFA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF99F6E4))),
              child: const Text(
                'DIGITAL TWIN · LIVE',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: _primary)))),

          // Drag hint
          const Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _HintLine(),
                SizedBox(width: 6),
                Text(
                  'DRAG TO ROTATE',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: Color(0xFF94A3B8))),
                SizedBox(width: 6),
                _HintLine(),
              ])),

          // Controls (Reset / Zoom In / Zoom Out)
          Positioned(
            top: 12,
            right: 12,
            child: Column(
              children: [
                _TwinControlBtn(
                  icon: Icons.refresh_rounded,
                  onTap: onReset,
                  label: 'Reset'),
                const SizedBox(height: 6),
                _TwinControlBtn(
                  icon: Icons.add_rounded,
                  onTap: onZoomIn,
                  label: 'Zoom In'),
                const SizedBox(height: 6),
                _TwinControlBtn(
                  icon: Icons.remove_rounded,
                  onTap: onZoomOut,
                  label: 'Zoom Out'),
              ])),
        ]));
  }
}

class _HintLine extends StatelessWidget {
  const _HintLine();
  @override
  Widget build(BuildContext context) =>
      Container(width: 28, height: 1, color: const Color(0xFFCBD5E1));
}

class _TwinControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String label;
  const _TwinControlBtn({
    required this.icon,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFCCFBF1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4),
          ]),
        child: Icon(icon, size: 14, color: _primary)));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grid Painter (background of digital twin card)
// ─────────────────────────────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _primary.withValues(alpha: 0.035)
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
// Digital Twin Painter — mirrors the SVG from App.tsx exactly
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
    // Scale the 240×250 SVG viewBox to fill the canvas
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

    // Shoulder at SVG coords (163, 72)
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
// Metric Cards
// ─────────────────────────────────────────────────────────────────────────────

class _RepsCard extends StatelessWidget {
  final int reps, target;
  final bool flash;
  const _RepsCard({
    required this.reps,
    required this.target,
    required this.flash,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: flash ? const Color(0xFFF0FDFA) : _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: flash ? _secondary : const Color(0xFFEBEEF2),
          width: flash ? 1.5 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2)),
        ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'REPS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
              color: Color(0xFF94A3B8))),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$reps',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: flash ? _primary : const Color(0xFF1E293B))),
              Text(
                '/$target',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFCBD5E1))),
            ]),
          const SizedBox(height: 6),
          Wrap(
            spacing: 3,
            runSpacing: 3,
            children: List.generate(
              target,
              (i) => Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < reps ? _secondary : const Color(0xFFE2E8F0))))),
        ]));
  }
}

class _ROMCard extends StatelessWidget {
  final int romDeg;
  const _ROMCard({required this.romDeg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEBEEF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2)),
        ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ROM',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
              color: Color(0xFF94A3B8))),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$romDeg',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B))),
                    const Text(
                      '°',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8))),
                  ])),
              _RomGauge(value: romDeg),
            ]),
          const SizedBox(height: 2),
          const Text(
            'Max: 180°',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w400)),
        ]));
  }
}

class _RomGauge extends StatelessWidget {
  final int value;
  const _RomGauge({required this.value});

  @override
  Widget build(BuildContext context) {
    final pct = value / 180.0;
    final color = _muscleColor(value / 1.8);
    return SizedBox(
      width: 36,
      height: 36,
      child: CustomPaint(
        painter: _RomGaugePainter(pct: pct, color: color)));
  }
}

class _RomGaugePainter extends CustomPainter {
  final double pct;
  final Color color;
  const _RomGaugePainter({required this.pct, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const r = 14.0;
    final rect = Rect.fromCircle(center: center, radius: r);

    // Track
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5);

    // Fill
    canvas.drawArc(
      rect,
      -math.pi / 2,
      pct * 2 * math.pi,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant _RomGaugePainter old) =>
      old.pct != pct || old.color != color;
}

class _MuscleActivityCard extends StatelessWidget {
  final double bicepsPct, tricepsPct;
  const _MuscleActivityCard({
    required this.bicepsPct,
    required this.tricepsPct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEBEEF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2)),
        ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MUSCLE ACTIVITY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
              color: Color(0xFF94A3B8))),
          const SizedBox(height: 8),
          _MuscleBar(label: 'Biceps', pct: bicepsPct),
          const SizedBox(height: 6),
          _MuscleBar(label: 'Triceps', pct: tricepsPct),
        ]));
  }
}

class _MuscleBar extends StatelessWidget {
  final String label;
  final double pct;
  const _MuscleBar({required this.label, required this.pct});

  @override
  Widget build(BuildContext context) {
    final color = _muscleColor(pct);
    final lbl = _muscleLabel(pct);
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B))),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20)),
              child: Text(
                lbl,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color))),
            const SizedBox(width: 4),
            Text(
              '${pct.round()}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color)),
          ]),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct / 100,
            minHeight: 5,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation(color))),
      ]);
  }
}

class _AccuracyCard extends StatelessWidget {
  final double accuracy;
  const _AccuracyCard({required this.accuracy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [_primary, _secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.40),
            blurRadius: 20,
            offset: const Offset(0, 6)),
        ]),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ACCURACY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.4,
                  color: Color(0xFF99F6E4))),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${accuracy.round()}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
                  const Text(
                    '%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF99F6E4))),
                ]),
            ]),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(10)),
                child: const Text(
                  'Excellent',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white))),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (i) {
                  final filled = i < (accuracy / 20).round();
                  return Container(
                    margin: const EdgeInsets.only(left: 4),
                    width: filled ? 16 : 8,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: filled
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.25)));
                })),
            ]),
        ]));
  }
}

class _AICoachCard extends StatelessWidget {
  final String message;
  final Color color;
  final Animation<double> pulseAnim;
  final bool voiceEnabled;
  final String voiceLanguage;
  final VoidCallback onVoiceToggle;
  final VoidCallback onLanguageToggle;

  const _AICoachCard({
    required this.message,
    required this.color,
    required this.pulseAnim,
    required this.voiceEnabled,
    required this.voiceLanguage,
    required this.onVoiceToggle,
    required this.onLanguageToggle,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = voiceLanguage == 'UR'
        ? (_urduTranslations[message] ?? message)
        : message;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEBEEF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2)),
        ]),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(colors: [_primary, _secondary]),
              boxShadow: [
                BoxShadow(
                  color: _primary.withValues(alpha: 0.40),
                  blurRadius: 12),
              ]),
            child: const Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI COACH',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.3,
                    color: _primary)),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    displayText,
                    key: ValueKey(displayText),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis)),
              ])),
          const SizedBox(width: 4),
          // Sound Mute/Unmute
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: Icon(
              voiceEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: voiceEnabled ? _primary : const Color(0xFF94A3B8),
              size: 20),
            onPressed: onVoiceToggle),
          // Language Switcher Pill
          GestureDetector(
            onTap: onLanguageToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF99F6E4))),
              child: Text(
                voiceLanguage == 'EN' ? 'EN' : 'اردو',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _primary)))),
          const SizedBox(width: 6),
          AnimatedBuilder(
            animation: pulseAnim,
            builder: (_, __) => Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _success,
                boxShadow: [
                  BoxShadow(
                    color: _success.withValues(alpha: pulseAnim.value * 0.5),
                    blurRadius: 6,
                    spreadRadius: 2),
                ]))),
        ]));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Session Controls
// ─────────────────────────────────────────────────────────────────────────────
class _SessionControls extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onPause, onResume, onStop;
  const _SessionControls({
    required this.isPaused,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CtrlBtn(
            icon: Icons.pause_rounded,
            label: 'PAUSE',
            textColor: const Color(0xFF64748B),
            fillColor: _card,
            borderColor: const Color(0xFFE2E8F0),
            enabled: !isPaused,
            onTap: onPause,
            iconFill: true)),
        const SizedBox(width: 8),
        Expanded(
          child: _CtrlBtn(
            icon: Icons.play_arrow_rounded,
            label: 'RESUME',
            textColor: _primary,
            fillColor: const Color(0xFFF0FDFA),
            borderColor: const Color(0xFF99F6E4),
            enabled: isPaused,
            onTap: onResume)),
        const SizedBox(width: 8),
        Expanded(
          child: _CtrlBtn(
            icon: Icons.stop_rounded,
            label: 'STOP',
            textColor: _danger,
            fillColor: const Color(0xFFFFF5F5),
            borderColor: const Color(0xFFFECACA),
            enabled: true,
            onTap: onStop,
            iconFill: true)),
      ]);
  }
}

class _CtrlBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color textColor, fillColor, borderColor;
  final bool enabled, iconFill;
  final VoidCallback onTap;

  const _CtrlBtn({
    required this.icon,
    required this.label,
    required this.textColor,
    required this.fillColor,
    required this.borderColor,
    required this.enabled,
    required this.onTap,
    this.iconFill = false,
  });

  @override
  State<_CtrlBtn> createState() => _CtrlBtnState();
}

class _CtrlBtnState extends State<_CtrlBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0);
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => _ctrl.reverse() : null,
      onTapUp: widget.enabled
          ? (_) {
              _ctrl.forward();
              widget.onTap();
            }
          : null,
      onTapCancel: () => _ctrl.forward(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: widget.enabled ? 1.0 : 0.35,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: widget.fillColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: widget.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
              ]),
            child: Column(
              children: [
                Icon(widget.icon, size: 20, color: widget.textColor),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                    color: widget.textColor)),
              ])))));
  }
}
