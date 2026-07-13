import 'package:flutter/material.dart';

enum ExerciseStatus { notStarted, inProgress, completed }

extension ExerciseStatusX on ExerciseStatus {
  String get label {
    switch (this) {
      case ExerciseStatus.notStarted:
        return 'Not Started';
      case ExerciseStatus.inProgress:
        return 'In Progress';
      case ExerciseStatus.completed:
        return 'Completed';
    }
  }
}

class Exercise {
  final String id;
  final String title;
  final String description;
  final String category; // Shoulder, Elbow, Wrist
  final String difficulty; // Easy, Medium, Hard
  final Color diffColor;
  final int durationMinutes;
  final int reps;
  final int sets;
  final int restSeconds;
  final String targetJoint; // e.g. Glenohumeral, Humeroulnar, Radioulnar
  final List<String> targetMuscles; // e.g. ['Anterior Deltoid', 'Biceps Brachii']
  final int targetAngleDegrees; // ROM target in degrees
  final List<String> tips; // Physiotherapist tips
  final String physio;
  final IconData fallbackIcon;
  double progress;
  ExerciseStatus status;
  final DateTime createdAt;

  Exercise({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.diffColor,
    required this.durationMinutes,
    required this.reps,
    required this.sets,
    required this.restSeconds,
    required this.targetJoint,
    required this.targetMuscles,
    required this.targetAngleDegrees,
    required this.tips,
    required this.physio,
    required this.fallbackIcon,
    required this.progress,
    required this.status,
    required this.createdAt,
  });

  String get durationLabel => '$durationMinutes min';
  String get repsLabel => '$reps reps';
  String get setsLabel => '$sets sets';
  String get restLabel => '${restSeconds}s rest';
  String get musclesLabel => targetMuscles.take(2).join(', ');

  Exercise copyWith({double? progress, ExerciseStatus? status}) {
    return Exercise(
      id: id,
      title: title,
      description: description,
      category: category,
      difficulty: difficulty,
      diffColor: diffColor,
      durationMinutes: durationMinutes,
      reps: reps,
      sets: sets,
      restSeconds: restSeconds,
      targetJoint: targetJoint,
      targetMuscles: targetMuscles,
      targetAngleDegrees: targetAngleDegrees,
      tips: tips,
      physio: physio,
      fallbackIcon: fallbackIcon,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
