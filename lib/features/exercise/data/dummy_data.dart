import 'package:flutter/material.dart';
import 'package:inteli_rehab/features/exercise/models/exercise.dart';
import 'package:inteli_rehab/features/exercise/utils/app_colors.dart';

/// Local in-memory dummy database of clinically relevant upper-limb
/// rehabilitation exercises aligned with the INTELI-REHAB FYP scope.
/// All exercises target the Shoulder, Elbow, or Wrist joints and are
/// trackable using the dual IMU + dual EMG sensor wearable.
List<Exercise> buildDummyExercises() {
  final now = DateTime.now();
  return [
    // ── SHOULDER EXERCISES ─────────────────────────────────────────────────
    Exercise(
      id: 'ex_shoulder_flexion',
      title: 'Shoulder Flexion',
      description:
          'Raise your arm forward in a controlled arc to improve glenohumeral range of motion and decrease anterior capsular stiffness.',
      category: 'Shoulder',
      difficulty: 'Easy',
      diffColor: AppColors.emerald,
      durationMinutes: 5,
      reps: 15,
      sets: 3,
      restSeconds: 30,
      targetJoint: 'Glenohumeral (Shoulder)',
      targetMuscles: ['Anterior Deltoid', 'Supraspinatus', 'Biceps Brachii (Long Head)'],
      targetAngleDegrees: 90,
      tips: [
        'Move slowly and steadily through the full arc.',
        'Keep your back straight and do not lean backwards.',
        'Do not shrug or elevate your shoulder blade.',
      ],
      physio: 'Dr. Ahmad Khan',
      fallbackIcon: Icons.accessibility_new_rounded,
      progress: 1.0,
      status: ExerciseStatus.completed,
      createdAt: now.subtract(const Duration(days: 3)),
    ),

    Exercise(
      id: 'ex_shoulder_abduction',
      title: 'Shoulder Abduction',
      description:
          'Raise your arm sideways away from the body to rehabilitate the rotator cuff and restore full lateral glenohumeral mobility.',
      category: 'Shoulder',
      difficulty: 'Medium',
      diffColor: Colors.amber.shade800,
      durationMinutes: 6,
      reps: 12,
      sets: 3,
      restSeconds: 45,
      targetJoint: 'Glenohumeral (Shoulder)',
      targetMuscles: ['Middle Deltoid', 'Supraspinatus', 'Serratus Anterior'],
      targetAngleDegrees: 90,
      tips: [
        'Keep your elbow straight throughout the movement.',
        'Lift to shoulder height only — do not exceed 90° if pain occurs.',
        'Lead with your thumb pointing upward to reduce impingement risk.',
      ],
      physio: 'Dr. Ahmad Khan',
      fallbackIcon: Icons.social_distance_rounded,
      progress: 0.5,
      status: ExerciseStatus.inProgress,
      createdAt: now.subtract(const Duration(days: 2)),
    ),

    // ── ELBOW EXERCISES ────────────────────────────────────────────────────
    Exercise(
      id: 'ex_elbow_flexion',
      title: 'Elbow Flexion',
      description:
          'Bend your elbow by curling the forearm toward the shoulder to rebuild biceps brachii strength and humeroulnar mobility after injury.',
      category: 'Elbow',
      difficulty: 'Easy',
      diffColor: AppColors.emerald,
      durationMinutes: 5,
      reps: 15,
      sets: 3,
      restSeconds: 30,
      targetJoint: 'Humeroulnar (Elbow)',
      targetMuscles: ['Biceps Brachii', 'Brachialis', 'Brachioradialis'],
      targetAngleDegrees: 130,
      tips: [
        'Keep your upper arm still and close to your body.',
        'Flex as far as comfortable without forcing the joint.',
        'Lower the arm slowly — the eccentric phase is equally important.',
      ],
      physio: 'Dr. Ahmad Khan',
      fallbackIcon: Icons.fitness_center_rounded,
      progress: 0.0,
      status: ExerciseStatus.notStarted,
      createdAt: now.subtract(const Duration(days: 1)),
    ),

    Exercise(
      id: 'ex_elbow_extension',
      title: 'Elbow Extension',
      description:
          'Slowly extend your elbow completely to regain full terminal extension and stretch the posterior elbow capsule safely.',
      category: 'Elbow',
      difficulty: 'Medium',
      diffColor: Colors.amber.shade800,
      durationMinutes: 8,
      reps: 12,
      sets: 3,
      restSeconds: 45,
      targetJoint: 'Humeroulnar (Elbow)',
      targetMuscles: ['Triceps Brachii', 'Anconeus'],
      targetAngleDegrees: 0,
      tips: [
        'Extend your elbow until it is fully straight — 0° is the goal.',
        'Do not lock the elbow forcefully if you feel resistance.',
        'Perform the movement in a pain-free range and report any sharp pain.',
      ],
      physio: 'Dr. Ahmad Khan',
      fallbackIcon: Icons.straighten_rounded,
      progress: 0.4,
      status: ExerciseStatus.inProgress,
      createdAt: now.subtract(const Duration(hours: 8)),
    ),

    // ── WRIST / FOREARM EXERCISES ──────────────────────────────────────────
    Exercise(
      id: 'ex_forearm_supination',
      title: 'Forearm Supination',
      description:
          'Rotate your palm upwards to restore proximal and distal radioulnar joint flexibility and biceps tendon function.',
      category: 'Wrist',
      difficulty: 'Easy',
      diffColor: AppColors.emerald,
      durationMinutes: 4,
      reps: 15,
      sets: 3,
      restSeconds: 30,
      targetJoint: 'Radioulnar (Forearm)',
      targetMuscles: ['Biceps Brachii', 'Supinator'],
      targetAngleDegrees: 80,
      tips: [
        'Keep your elbow bent at 90° and close to your side.',
        'Rotate until your palm faces fully upward.',
        'Hold the end position for 2 seconds before returning.',
      ],
      physio: 'Dr. Ahmad Khan',
      fallbackIcon: Icons.back_hand_rounded,
      progress: 0.0,
      status: ExerciseStatus.notStarted,
      createdAt: now.subtract(const Duration(hours: 4)),
    ),

    Exercise(
      id: 'ex_forearm_pronation',
      title: 'Forearm Pronation',
      description:
          'Rotate your palm downwards to improve pronator teres and pronator quadratus muscle re-education after upper-limb injury.',
      category: 'Wrist',
      difficulty: 'Easy',
      diffColor: AppColors.emerald,
      durationMinutes: 4,
      reps: 15,
      sets: 3,
      restSeconds: 30,
      targetJoint: 'Radioulnar (Forearm)',
      targetMuscles: ['Pronator Teres', 'Pronator Quadratus'],
      targetAngleDegrees: 80,
      tips: [
        'Keep your elbow fixed at 90° and tucked into your side.',
        'Rotate slowly until your palm faces fully downward.',
        'Pair with supination sets for balanced radioulnar rehabilitation.',
      ],
      physio: 'Dr. Ahmad Khan',
      fallbackIcon: Icons.pan_tool_rounded,
      progress: 0.0,
      status: ExerciseStatus.notStarted,
      createdAt: now.subtract(const Duration(hours: 2)),
    ),
  ];
}
