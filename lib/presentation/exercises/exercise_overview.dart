import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:inteli_rehab/domain/entities/exercise.dart';
import 'package:inteli_rehab/presentation/exercises/calibration.dart';
import 'package:inteli_rehab/data/datasources/local/dummy_data.dart';

class _C {
  static const Color primary    = Color(0xFF0F766E); // Brand Green (Deep Teal)
}

class ExerciseOverviewScreen extends StatefulWidget {
  final Exercise exercise;
  const ExerciseOverviewScreen({super.key, required this.exercise});

  @override
  State<ExerciseOverviewScreen> createState() => _ExerciseOverviewScreenState();
}

class _ExerciseOverviewScreenState extends State<ExerciseOverviewScreen> {
  late List<Exercise> _exercises;
  late int _currentIndex;
  late int _currentDurationSeconds;
  VideoPlayerController? _videoCtrl;
  bool _isVideoReady = false;

  @override
  void initState() {
    super.initState();
    _exercises = buildDummyExercises();
    _currentIndex = _exercises.indexWhere((e) => e.id == widget.exercise.id);
    if (_currentIndex == -1) {
      _currentIndex = 0;
    }
    _currentDurationSeconds = _exercises[_currentIndex].durationMinutes * 60;
    _initializeVideo();
  }

  void _initializeVideo() {
    final String videoAsset = _getVideoAssetPath(_exercises[_currentIndex].id);
    _videoCtrl = VideoPlayerController.asset(videoAsset)
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

  void _switchExercise(int newIndex) {
    if (newIndex < 0 || newIndex >= _exercises.length) return;

    _videoCtrl?.dispose();
    _videoCtrl = null;

    setState(() {
      _currentIndex = newIndex;
      _isVideoReady = false;
      _currentDurationSeconds = _exercises[newIndex].durationMinutes * 60;
    });

    _initializeVideo();
  }

  String _getVideoAssetPath(String id) {
    switch (id) {
      case 'ex_shoulder_flexion':
        return 'assets/videos/shoulder_flexion.mp4';
      case 'ex_shoulder_abduction':
        return 'assets/videos/shoulder_abduction.mp4';
      case 'ex_elbow_flexion':
        return 'assets/videos/elbow_flexion.mp4';
      case 'ex_elbow_extension':
        return 'assets/videos/elbow_extension.mp4';
      case 'ex_forearm_supination':
        return 'assets/videos/supination.mp4';
      case 'ex_forearm_pronation':
        return 'assets/videos/pronation.mp4';
      default:
        return 'assets/videos/pronation.mp4';
    }
  }

  String _getHighlightedAreaImage(String id) {
    switch (id) {
      case 'ex_shoulder_flexion':
        return 'assets/images/shoulder_flexion_highlighted.jpeg';
      case 'ex_shoulder_abduction':
        return 'assets/images/shoulder_abduction_highlighted.jpeg';
      case 'ex_elbow_flexion':
        return 'assets/images/elbow_flexion_highlighted.jpeg';
      case 'ex_elbow_extension':
        return 'assets/images/elbow_extension_highlighted.jpeg';
      case 'ex_forearm_supination':
        return 'assets/images/forearm_supination_highlighted.jpeg';
      case 'ex_forearm_pronation':
        return 'assets/images/forearm_pronation_highlighted.jpeg';
      default:
        return 'assets/images/shoulder_flexion_highlighted.jpeg';
    }
  }

  static List<String> _getCommonMistakes(String title) {
    switch (title) {
      case 'Shoulder Flexion':
        return [
          'Shrugging or raising your shoulder blade: Avoid elevating the scapular region.',
          'Leaning your torso backwards during the raise: Maintain a tight, upright core posture.',
          'Bending your elbow: Keep the active arm completely straight.'
        ];
      case 'Shoulder Abduction':
        return [
          'Leaning your body: Do not lean to the opposite side to assist lateral raises.',
          'Lifting arm past shoulder level: Keep motion strictly within a 90-degree range.',
          'Shrugging your shoulder: Focus lateral deltoid pull without neck compensation.'
        ];
      case 'Elbow Flexion':
        return [
          'Flaring elbow: Keep your upper arm tucked close to your ribcage.',
          'Swinging the body: Do not use body momentum to curl up.',
          'Incomplete range: Ensure full elbow extension at the bottom.'
        ];
      case 'Elbow Extension':
        return [
          'Letting elbow drift: Keep upper arm fixed vertically.',
          'Locking joint: Avoid hyperextension or snapping the joint at the end.',
          'Arching back: Keep spine neutral; push solely using your triceps.'
        ];
      case 'Forearm Supination':
        return [
          'Separating elbow: Keep elbow pinned firmly to your waist.',
          'Shoulder rotation: Rotate strictly at the radioulnar joint.',
          'Wrist flexion: Maintain a flat wrist line without bending.'
        ];
      case 'Forearm Pronation':
        return [
          'Separating elbow: Keep elbow pinned firmly to your side.',
          'Shoulder rotation: Prevent proximal shoulder compensations.',
          'Wrist flexion: Focus movement on pure forearm twisting.'
        ];
      default:
        return [
          'Performing exercise too quickly: Execute in a slow, controlled manner.',
          'Moving outside pain-free zone: Stop if sharp pain is felt.',
          'Compensating with adjacent joints: Isolate movement to target joints.'
        ];
    }
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentEx = _exercises[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header (Title only)
            Text(
              currentEx.title.toUpperCase(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 20),

            // 2. Video Card Container (Always shows video)
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.5),
                child: _videoCtrl != null && _isVideoReady
                    ? FittedBox(
                        fit: BoxFit.cover,
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox(
                          width: _videoCtrl!.value.size.width,
                          height: _videoCtrl!.value.size.height,
                          child: VideoPlayer(_videoCtrl!),
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(color: _C.primary),
                      ),
              ),
            ),
            const SizedBox(height: 28),

            // 3. Duration Adjuster Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'DURATION',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: _C.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_currentDurationSeconds > 30) {
                          setState(() {
                            _currentDurationSeconds -= 30;
                          });
                        }
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.remove, color: Colors.black87, size: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _formatDuration(_currentDurationSeconds),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentDurationSeconds += 30;
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, color: Colors.black87, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),

            // 4. Instructions Section
            const Text(
              'INSTRUCTIONS',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: _C.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            ...currentEx.tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    tip,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                )),
            const SizedBox(height: 28),

            // 5. Focus Area Section (chips + highlighted area image)
            const Text(
              'FOCUS AREA',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: _C.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: currentEx.targetMuscles.map((muscle) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.fiber_manual_record, size: 8, color: _C.primary),
                        const SizedBox(width: 6),
                        Text(
                          muscle,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
            ),
            const SizedBox(height: 16),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  _getHighlightedAreaImage(currentEx.id),
                  height: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 220,
                    color: const Color(0xFFF3F4F6),
                    child: const Center(
                      child: Icon(Icons.image_not_supported_rounded, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // 6. Common Mistakes Section
            const Text(
              'COMMON MISTAKES',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: _C.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            ..._getCommonMistakes(currentEx.title).asMap().entries.map((entry) {
              final index = entry.key + 1;
              final mistake = entry.value;
              final parts = mistake.split(':');
              final title = parts[0];
              final detail = parts.length > 1 ? parts[1].trim() : '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE6F4F1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$index',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _C.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          if (detail.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              detail,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              IconButton(
                onPressed: _currentIndex > 0
                    ? () => _switchExercise(_currentIndex - 1)
                    : null,
                icon: const Icon(Icons.skip_previous_rounded),
                iconSize: 32,
                color: _C.primary,
                disabledColor: Colors.grey.shade300,
              ),
              Text(
                '${_currentIndex + 1}/${_exercises.length}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: _currentIndex < _exercises.length - 1
                    ? () => _switchExercise(_currentIndex + 1)
                    : null,
                icon: const Icon(Icons.skip_next_rounded),
                iconSize: 32,
                color: _C.primary,
                disabledColor: Colors.grey.shade300,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CalibrationScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'START SESSION',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
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
