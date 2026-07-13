import 'package:inteli_rehab/domain/entities/exercise.dart';

abstract class ExerciseRepository {
  Future<List<Exercise>> getExercises();
}
