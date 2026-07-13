import 'package:inteli_rehab/domain/entities/progress.dart';
import 'package:inteli_rehab/domain/repositories/progress_repository.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  @override
  Future<ProgressReport> getProgress() async => ProgressReport(averageAccuracy: 95.0, totalMinutes: 120);
}
