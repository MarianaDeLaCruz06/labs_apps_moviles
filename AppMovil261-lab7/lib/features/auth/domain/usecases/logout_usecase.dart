import 'package:appmovil261/di/dependecy_container.dart';
import 'package:appmovil261/features/auth/domain/repo/auth_repo.dart';

class LogoutUsecase {
  AuthRepo repo = sl<AuthRepo>();

  Future<void> execute() async {
    await repo.logout();
  }
}
