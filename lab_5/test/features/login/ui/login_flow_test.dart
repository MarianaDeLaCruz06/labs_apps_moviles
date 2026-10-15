import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:moviles_auth/features/home/ui/screens/home_screen.dart';
import 'package:moviles_auth/features/login/ui/bloc/login_bloc.dart';
import 'package:moviles_auth/features/login/ui/bloc/login_event.dart';
import 'package:moviles_auth/features/login/ui/bloc/login_state.dart';
import 'package:moviles_auth/features/login/ui/screens/login_screen.dart';

void main() {
  test('LoginBloc emits failure when authentication fails', () async {
    final auth = _FakeAuthRepository(
      signInError: StateError('Credenciales inválidas'),
    );
    final bloc = LoginBloc(
      signInUseCase: SignInUseCase(auth, _FakeProfileRepository()),
    );

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<LoginState>().having(
          (state) => state.status,
          'status',
          LoginStatus.loading,
        ),
        isA<LoginState>()
            .having((state) => state.status, 'status', LoginStatus.failure)
            .having(
              (state) => state.errorMessage,
              'errorMessage',
              contains('Credenciales inválidas'),
            )
            .having((state) => state.result, 'result', isNull),
      ]),
    );

    bloc.add(LoginSubmitted(email: 'ana@icesi.edu.co', password: 'incorrecta'));

    await expectation;
    expect(auth.signInCalls, 1);
    await bloc.close();
  });

  testWidgets('successful login navigates with real profile and email', (
    tester,
  ) async {
    final auth = _FakeAuthRepository();
    final profiles = _FakeProfileRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) =>
              LoginBloc(signInUseCase: SignInUseCase(auth, profiles)),
          child: const LoginScreen(),
        ),
        routes: {
          '/home': (context) {
            final arguments = ModalRoute.of(context)?.settings.arguments;
            expect(arguments, isA<SignInResult>());
            final result = arguments! as SignInResult;
            return HomeScreen(
              username: result.profile.username,
              fullName: result.profile.fullName,
              email: result.user.email,
              signOutUseCase: SignOutUseCase(auth),
            );
          },
        },
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'ana@icesi.edu.co');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Ana Gómez'), findsNWidgets(2));
    expect(find.text('@ana'), findsOneWidget);
    expect(find.text('ana@icesi.edu.co'), findsOneWidget);
    expect(profiles.receivedId, 'auth-user-id');
  });

  testWidgets('missing profile shows an error and does not navigate', (
    tester,
  ) async {
    final auth = _FakeAuthRepository();
    final profiles = _FakeProfileRepository(
      getProfileError: StateError('No existe un perfil para este usuario.'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) =>
              LoginBloc(signInUseCase: SignInUseCase(auth, profiles)),
          child: const LoginScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'ana@icesi.edu.co');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.textContaining('No existe un perfil'), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(auth.signOutCalls, 1);
  });

  testWidgets('successful logout waits for signOut and navigates to login', (
    tester,
  ) async {
    final auth = _FakeAuthRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          username: 'ana',
          fullName: 'Ana Gómez',
          email: 'ana@icesi.edu.co',
          signOutUseCase: SignOutUseCase(auth),
        ),
        routes: {'/login': (_) => const Scaffold(body: Text('Login route'))},
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(auth.signOutCalls, 1);
    expect(find.text('Login route'), findsOneWidget);
  });

  testWidgets('logout failure remains on home and shows the error', (
    tester,
  ) async {
    final auth = _FakeAuthRepository(
      signOutError: StateError('No fue posible cerrar la sesión'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          username: 'ana',
          fullName: 'Ana Gómez',
          email: 'ana@icesi.edu.co',
          signOutUseCase: SignOutUseCase(auth),
        ),
        routes: {'/login': (_) => const Scaffold(body: Text('Login route'))},
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.textContaining('No fue posible cerrar'), findsOneWidget);
    expect(find.text('Login route'), findsNothing);
  });
}

class _FakeAuthRepository implements AuthRepository {
  final Object? signInError;
  final Object? signOutError;
  int signInCalls = 0;
  int signOutCalls = 0;

  _FakeAuthRepository({this.signInError, this.signOutError});

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    if (signInError != null) throw signInError!;
    return AuthUser(id: 'auth-user-id', email: email);
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    if (signOutError != null) throw signOutError!;
  }

  @override
  Future<AuthUser> signUp({required String email, required String password}) =>
      throw UnimplementedError();
}

class _FakeProfileRepository implements ProfileRepository {
  final Object? getProfileError;
  String? receivedId;

  _FakeProfileRepository({this.getProfileError});

  @override
  Future<Profile> getProfile(String id) async {
    receivedId = id;
    if (getProfileError != null) throw getProfileError!;
    return const Profile(
      id: 'auth-user-id',
      username: 'ana',
      fullName: 'Ana Gómez',
    );
  }

  @override
  Future<void> createProfile(Profile profile) => throw UnimplementedError();
}
