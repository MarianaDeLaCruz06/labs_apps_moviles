import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:moviles_auth/features/home/ui/screens/home_screen.dart';
import 'package:moviles_auth/features/login/ui/screens/login_screen.dart';
import 'package:moviles_auth/features/login/ui/bloc/login_bloc.dart';
import 'package:moviles_auth/features/register/ui/bloc/register_bloc.dart';
import 'package:moviles_auth/features/register/ui/screens/register_screen.dart';

void main() {
  testWidgets('sign in validates required fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => LoginBloc(
            signInUseCase: SignInUseCase(
              _FakeAuthRepository(),
              _FakeProfileRepository(),
            ),
          ),
          child: const LoginScreen(),
        ),
      ),
    );
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pump();
    expect(find.text('Escribe tu correo y tu contraseña'), findsOneWidget);

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('sign up rejects mismatched passwords and accepts valid input', (
    tester,
  ) async {
    final useCase = SignUpUseCase(
      _FakeAuthRepository(),
      _FakeProfileRepository(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => RegisterBloc(signUpUseCase: useCase),
          child: const RegisterScreen(),
        ),
        routes: {
          '/home': (context) {
            final profile =
                ModalRoute.of(context)!.settings.arguments! as Profile;
            return HomeScreen(
              username: profile.username,
              fullName: profile.fullName,
              email: 'ana@icesi.edu.co',
              signOutUseCase: SignOutUseCase(_FakeAuthRepository()),
            );
          },
        },
      ),
    );
    expect(find.text('Crea tu cuenta'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'ana');
    await tester.enterText(find.byType(TextField).at(1), 'Ana Gómez');
    await tester.enterText(find.byType(TextField).at(2), 'ana@icesi.edu.co');
    await tester.enterText(find.byType(TextField).at(3), '123456');
    await tester.enterText(find.byType(TextField).at(4), '654321');
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Registrarme'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Registrarme'));
    await tester.pump();
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(4), '123456');
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Registrarme'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Registrarme'));
    await tester.pumpAndSettle();

    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Ana Gómez'), findsNWidgets(2));
    expect(find.text('@ana'), findsOneWidget);
  });
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    return AuthUser(id: 'auth-user-id', email: email);
  }

  @override
  Future<AuthUser> signIn({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<void> createProfile(Profile profile) async {}

  @override
  Future<Profile> getProfile(String id) => throw UnimplementedError();
}
