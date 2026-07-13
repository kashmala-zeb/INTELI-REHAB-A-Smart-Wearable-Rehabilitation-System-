class RecoverySetupModel {
  String? affectedArm;          // 'Left', 'Right'
  String? rehabArea;            // 'Shoulder', 'Elbow', 'Forearm', 'Wrist', 'Hand'
  String? recoveryStage;        // 'Early', 'Intermediate', 'Advanced'
  bool? therapistAssigned;      // true, false
  String? therapistCode;        // Code e.g. 'ABC-2041'
  String? exerciseFrequency;    // 'Every Day', '5 Days/Week', '3 Days/Week', 'Custom'
  List<String> selectedDays;    // ['Mon', 'Wed', 'Fri'] etc.
  String? reminderTime;         // 'Morning (8:00 AM)', 'Afternoon (1:00 PM)', 'Evening (6:00 PM)', 'Custom'
  String? profilePhoto;         // Path to image asset

  RecoverySetupModel({
    this.affectedArm,
    this.rehabArea,
    this.recoveryStage,
    this.therapistAssigned,
    this.therapistCode,
    this.exerciseFrequency,
    this.selectedDays = const [],
    this.reminderTime,
    this.profilePhoto,
  });
}
