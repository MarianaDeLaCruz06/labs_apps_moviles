import 'package:flutter_test/flutter_test.dart';
import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_out_usecase.dart';

void main() {
  test('delegates sign out to the auth repository', () async {
    final repository = _FakeAuthRepository();

    await SignOutUseCase(repository)();

    expect(repository.signOutCalls, 1);
  });

  test('propagates a sign out failure to the caller', () async {
    final error = StateError('sign out failed');
    final repository = _FakeAuthRepository(error: error);

    await expectLater(SignOutUseCase(repository)(), throwsA(same(error)));
  });
}

class _FakeAuthRepository implements AuthRepository {
  final Object? error;
  int signOutCalls = 0;

  _FakeAuthRepository({this.error});

  @override
  Future<void> signOut() async {
    signOutCalls++;
    if (error != null) throw error!;
  }

  @override
  Future<AuthUser> signIn({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<AuthUser> signUp({required String email, required String password}) =>
      throw UnimplementedError();
}
