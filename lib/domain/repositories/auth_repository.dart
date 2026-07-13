abstract class AuthRepository {
  Future<bool> login(String email, String password);
  Future<bool> signup(String name, String email, String password);
}
