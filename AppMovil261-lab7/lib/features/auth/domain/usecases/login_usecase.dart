import 'package:appmovil261/di/dependecy_container.dart';
import 'package:appmovil261/features/auth/domain/repo/auth_repo.dart';

class LoginUsecase {
  AuthRepo repo = sl<AuthRepo>();

  Future<void> execute(String email, String password) async {
    await repo.login(email, password);
  }
}
