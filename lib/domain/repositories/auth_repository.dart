abstract interface class AuthRepository {
  Future<LoginResult> login(String username, String password);
}

class LoginResult {
  const LoginResult._({required this.isSuccess, this.message});

  const LoginResult.success() : this._(isSuccess: true);

  const LoginResult.failure(String? message)
    : this._(isSuccess: false, message: message);

  final bool isSuccess;
  final String? message;
}
