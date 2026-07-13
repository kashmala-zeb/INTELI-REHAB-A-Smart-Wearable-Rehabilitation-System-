import 'package:inteli_rehab/domain/repositories/auth_repository.dart';

class SignupUseCase {
  final AuthRepository repository;
  SignupUseCase(this.repository);
  Future<bool> call(String name, String email, String password) => repository.signup(name, email, password);
}
