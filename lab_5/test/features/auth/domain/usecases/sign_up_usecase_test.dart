import 'package:flutter_test/flutter_test.dart';
import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:moviles_auth/features/register/ui/bloc/register_bloc.dart';
import 'package:moviles_auth/features/register/ui/bloc/register_event.dart';
import 'package:moviles_auth/features/register/ui/bloc/register_state.dart';

void main() {
  test(
    'signUp creates the account before creating and returning the profile',
    () async {
      final calls = <String>[];
      final auth = _FakeAuthRepository(calls);
      final profiles = _FakeProfileRepository(calls);
      final useCase = SignUpUseCase(auth, profiles);

      final result = await useCase(
        username: 'student',
        fullName: 'Student Name',
        email: 'student@example.com',
        password: 'password',
      );

      expect(calls, ['auth.signUp', 'profiles.createProfile']);
      expect(result.id, 'auth-user-id');
      expect(result.username, 'student');
      expect(result.fullName, 'Student Name');
      expect(profiles.receivedProfile, same(result));
    },
  );

  test('a profile creation error reaches RegisterBloc as failure', () async {
    final calls = <String>[];
    final useCase = SignUpUseCase(
      _FakeAuthRepository(calls),
      _FakeProfileRepository(calls, shouldFail: true),
    );
    final bloc = RegisterBloc(signUpUseCase: useCase);

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<RegisterState>().having(
          (state) => state.status,
          'status',
          RegisterStatus.loading,
        ),
        isA<RegisterState>()
            .having((state) => state.status, 'status', RegisterStatus.failure)
            .having(
              (state) => state.errorMessage,
              'errorMessage',
              contains('profile insert failed'),
            ),
      ]),
    );

    bloc.add(
      RegisterSubmitted(
        username: 'student',
        fullName: 'Student Name',
        email: 'student@example.com',
        password: 'password',
      ),
    );

    await expectation;
    expect(calls, ['auth.signUp', 'profiles.createProfile']);
    await bloc.close();
  });
}

class _FakeAuthRepository implements AuthRepository {
  final List<String> calls;

  _FakeAuthRepository(this.calls);

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    calls.add('auth.signUp');
    return const AuthUser(id: 'auth-user-id', email: 'student@example.com');
  }
}

class _FakeProfileRepository implements ProfileRepository {
  final List<String> calls;
  final bool shouldFail;
  Profile? receivedProfile;

  _FakeProfileRepository(this.calls, {this.shouldFail = false});

  @override
  Future<void> createProfile(Profile profile) async {
    calls.add('profiles.createProfile');
    receivedProfile = profile;

    if (shouldFail) {
      throw StateError('profile insert failed');
    }
  }
}
