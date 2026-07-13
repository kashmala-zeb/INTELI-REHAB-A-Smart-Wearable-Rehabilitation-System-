import 'package:inteli_rehab/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);
  Future<bool> call(String email, String password) => repository.login(email, password);
}
