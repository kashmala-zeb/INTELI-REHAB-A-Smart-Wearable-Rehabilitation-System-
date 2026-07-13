import 'package:inteli_rehab/domain/entities/progress.dart';

abstract class ProgressRepository {
  Future<ProgressReport> getProgress();
}
