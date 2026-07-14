import 'package:flutter/material.dart';
import 'package:inteli_rehab/domain/entities/exercise.dart';
import 'package:inteli_rehab/core/constants/app_colors.dart';
import 'package:inteli_rehab/core/utils/snackbar_utils.dart';
import 'package:inteli_rehab/presentation/exercises/widgets/exercise_image.dart';

class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onStart;
  final VoidCallback onResume;
  final VoidCallback onRepeat;
  final VoidCallback onTapCard;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onStart,
    required this.onResume,
    required this.onRepeat,
    required this.onTapCard,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(_) => setState(() => _scale = 0.98);
  void _onTapUp(_) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

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
    final exercise = widget.exercise;
    final isDone = exercise.status == ExerciseStatus.completed;
    final isInProgress = exercise.status == ExerciseStatus.inProgress;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTapCard,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.slate.shade900.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: AppColors.slate.shade100, width: 1.4),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExerciseImage(
                          assetPath: _getImagePath(exercise.id),
                          fallbackIcon: exercise.fallbackIcon,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      exercise.title,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.slate.shade900,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: exercise.diffColor.withValues(alpha: 
                                        0.10,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      exercise.difficulty,
                                      style: TextStyle(
                                        color: exercise.diffColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _metaBadge(
                          Icons.timer_outlined,
                          exercise.durationLabel,
                        ),
                        const SizedBox(width: 8),
                        _metaBadge(
                          Icons.restart_alt_rounded,
                          exercise.repsLabel,
                        ),
                        const SizedBox(width: 8),
                        _metaBadge(
                          Icons.layers_rounded,
                          exercise.setsLabel,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _metaBadge(
                            Icons.self_improvement_rounded,
                            exercise.targetJoint.split(' ').first,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Routine Target Status',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.slate.shade400,
                              ),
                            ),
                            Text(
                              isDone
                                  ? 'Completed'
                                  : (isInProgress
                                        ? '${(exercise.progress * 100).round()}% Executed'
                                        : 'Pending Action'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDone
                                    ? const Color(0xFF16A34A)
                                    : (isInProgress
                                          ? AppColors.tealCore
                                          : AppColors.slate.shade500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 7,
                            decoration: BoxDecoration(
                              color: AppColors.slate.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: AnimatedFractionallySizedBox(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                              alignment: Alignment.centerLeft,
                              widthFactor: exercise.progress.clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: isDone
                                        ? [
                                            AppColors.emerald.shade400,
                                            const Color(0xFF16A34A),
                                          ]
                                        : [
                                            AppColors.tealBright,
                                            AppColors.tealCore,
                                          ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.slate.shade50,
                  border: Border(
                    top: BorderSide(color: AppColors.slate.shade100, width: 1),
                  ),
                ),
                child: _buildCardAction(context, exercise),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.slate.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.slate.shade100, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.slate.shade500),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.slate.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardAction(BuildContext context, Exercise exercise) {
    if (exercise.status == ExerciseStatus.completed) {
      return Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF16A34A),
            size: 20,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Session Finalized Successfully',
              style: TextStyle(
                color: Color(0xFF15803D),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  title: const Text('Repeat Exercise?'),
                  content: Text('Do you want to repeat "${exercise.title}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.slate.shade500),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tealCore,
                      ),
                      child: const Text(
                        'Repeat',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                widget.onRepeat();
              }
            },
            icon: const Icon(Icons.replay_rounded, size: 14),
            label: const Text('Repeat'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.tealCore,
              backgroundColor: AppColors.tealCore.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      );
    }

    final bool isInProgress = exercise.status == ExerciseStatus.inProgress;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            isInProgress
                ? 'Resumes hardware pairing...'
                : 'Requires wearable sync',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.slate.shade400,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.tealBright, AppColors.tealCore],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.tealCore.withValues(alpha: 0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                if (isInProgress) {
                  widget.onResume();
                } else {
                  widget.onStart();
                  AppSnackbar.info(context, 'Starting ${exercise.title}...');
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isInProgress ? 'Resume Session' : 'Start Session',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
