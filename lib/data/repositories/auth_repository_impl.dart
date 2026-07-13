import 'package:inteli_rehab/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<bool> login(String email, String password) async => true;
  @override
  Future<bool> signup(String name, String email, String password) async => true;
}
