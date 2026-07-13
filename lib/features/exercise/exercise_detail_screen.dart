import 'package:flutter/material.dart';
import 'package:inteli_rehab/features/exercise/models/exercise.dart';
import 'package:inteli_rehab/features/exercise/utils/app_colors.dart';
import 'package:inteli_rehab/features/exercise/widgets/exercise_image.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;
  const ExerciseDetailScreen({super.key, required this.exercise});

  String _getImagePath(String id) {
    switch (id) {
      case 'ex_shoulder_flexion':
        return 'assets/images/shoulder_flexion.jpeg';
      case 'ex_shoulder_abduction':
        return 'assets/images/shoulder_abduction.jpg';
      case 'ex_elbow_flexion':
        return 'assets/images/elbow_flexion.png';

      case 'ex_elbow_extension':
        return 'assets/images/elbow_extension.jpg';
      case 'ex_forearm_supination':
        return 'assets/images/supination.png';
      case 'ex_forearm_pronation':
        return 'assets/images/pronation.jpeg';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.slate.shade900,
        title: Text(
          exercise.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Exercise Image / Icon ──────────────────────────────────
              Center(
                child: Hero(
                  tag: 'exercise_${exercise.id}',
                  child: ExerciseImage(
                    assetPath: _getImagePath(exercise.id),
                    fallbackIcon: exercise.fallbackIcon,
                    size: 140,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Title + Difficulty ─────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      exercise.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.slate.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: exercise.diffColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      exercise.difficulty,
                      style: TextStyle(
                        color: exercise.diffColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                exercise.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.slate.shade600,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),

              // ── Stats Grid ─────────────────────────────────────────────
              _sectionTitle('Exercise Details'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _infoChip(Icons.timer_outlined, 'Duration', exercise.durationLabel),
                  _infoChip(Icons.restart_alt_rounded, 'Repetitions', exercise.repsLabel),
                  _infoChip(Icons.layers_rounded, 'Sets', exercise.setsLabel),
                  _infoChip(Icons.hourglass_bottom_rounded, 'Rest', exercise.restLabel),
                  _infoChip(Icons.self_improvement_rounded, 'Target Joint', exercise.targetJoint),
                  _infoChip(Icons.healing_outlined, 'Assigned By', exercise.physio),
                ],
              ),
              const SizedBox(height: 24),

              // ── Target Muscles ─────────────────────────────────────────
              _sectionTitle('Target Muscles'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.slate.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: exercise.targetMuscles.asMap().entries.map((entry) {
                    final isPrimary = entry.key == 0;
                    return Padding(
                      padding: EdgeInsets.only(bottom: entry.key < exercise.targetMuscles.length - 1 ? 10 : 0),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: isPrimary ? AppColors.tealCore : AppColors.slate.shade300,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w500,
                                color: isPrimary ? AppColors.slate.shade900 : AppColors.slate.shade500,
                              ),
                            ),
                          ),
                          if (isPrimary)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.tealCore.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Primary',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.tealCore,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.slate.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Secondary',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.slate.shade500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // ── Range of Motion ────────────────────────────────────────
              _sectionTitle('Target Range of Motion'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.slate.shade100),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.tealBright, AppColors.tealCore],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${exercise.targetAngleDegrees}°',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Goal: ${exercise.targetAngleDegrees}° of Motion',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'The IMU sensors will measure your joint angle in real-time and compare it against this target.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.slate.shade500,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Physiotherapist Tips ───────────────────────────────────
              _sectionTitle('Physiotherapist Tips'),
              const SizedBox(height: 12),
              ...exercise.tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.slate.shade100),
                  ),
                  child: Row(
                    children: [
                      Text('💡', style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.slate.shade700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 16),

              // ── Warning Card ───────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Stop immediately if you experience sharp pain or discomfort.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Start Exercise Button ──────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.tealBright, AppColors.tealCore],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.tealCore.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to Sensor Calibration Screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_circle_rounded, color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Start Session',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.slate.shade800,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppColors.tealCore),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate.shade400,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.slate.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
