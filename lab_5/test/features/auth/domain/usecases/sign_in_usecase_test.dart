import 'package:flutter_test/flutter_test.dart';
import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_in_usecase.dart';

void main() {
  test(
    'signs in before retrieving and returning the matching profile',
    () async {
      final calls = <String>[];
      final auth = _FakeAuthRepository(calls);
      final profiles = _FakeProfileRepository(calls);
      final useCase = SignInUseCase(auth, profiles);

      final result = await useCase(
        email: 'student@example.com',
        password: 'password',
      );

      expect(calls, ['auth.signIn', 'profiles.getProfile:auth-user-id']);
      expect(result.user, same(auth.user));
      expect(result.profile, same(profiles.profile));
      expect(profiles.receivedId, auth.user.id);
    },
  );

  test('does not retrieve a profile when sign in fails', () async {
    final calls = <String>[];
    final useCase = SignInUseCase(
      _FakeAuthRepository(
        calls,
        signInError: StateError('invalid credentials'),
      ),
      _FakeProfileRepository(calls),
    );

    await expectLater(
      useCase(email: 'student@example.com', password: 'wrong'),
      throwsA(isA<StateError>()),
    );

    expect(calls, ['auth.signIn']);
  });

  test('signs out and preserves the profile retrieval error', () async {
    final calls = <String>[];
    final profileError = StateError('profile not found');
    final useCase = SignInUseCase(
      _FakeAuthRepository(calls),
      _FakeProfileRepository(calls, getProfileError: profileError),
    );

    await expectLater(
      useCase(email: 'student@example.com', password: 'password'),
      throwsA(same(profileError)),
    );

    expect(calls, [
      'auth.signIn',
      'profiles.getProfile:auth-user-id',
      'auth.signOut',
    ]);
  });

  test(
    'preserves the profile error even when cleanup sign out fails',
    () async {
      final calls = <String>[];
      final profileError = StateError('profile not found');
      final useCase = SignInUseCase(
        _FakeAuthRepository(calls, signOutError: StateError('sign out failed')),
        _FakeProfileRepository(calls, getProfileError: profileError),
      );

      await expectLater(
        useCase(email: 'student@example.com', password: 'password'),
        throwsA(same(profileError)),
      );
    },
  );
}

class _FakeAuthRepository implements AuthRepository {
  final List<String> calls;
  final Object? signInError;
  final Object? signOutError;
  final AuthUser user = const AuthUser(
    id: 'auth-user-id',
    email: 'student@example.com',
  );

  _FakeAuthRepository(this.calls, {this.signInError, this.signOutError});

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    calls.add('auth.signIn');
    if (signInError != null) throw signInError!;
    return user;
  }

  @override
  Future<void> signOut() async {
    calls.add('auth.signOut');
    if (signOutError != null) throw signOutError!;
  }

  @override
  Future<AuthUser> signUp({required String email, required String password}) =>
      throw UnimplementedError();
}

class _FakeProfileRepository implements ProfileRepository {
  final List<String> calls;
  final Object? getProfileError;
  final Profile profile = const Profile(
    id: 'auth-user-id',
    username: 'student',
    fullName: 'Student Name',
  );
  String? receivedId;

  _FakeProfileRepository(this.calls, {this.getProfileError});

  @override
  Future<Profile> getProfile(String id) async {
    calls.add('profiles.getProfile:$id');
    receivedId = id;
    if (getProfileError != null) throw getProfileError!;
    return profile;
  }

  @override
  Future<void> createProfile(Profile profile) => throw UnimplementedError();
}
