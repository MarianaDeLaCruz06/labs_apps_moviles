import 'package:appmovil261/di/dependecy_container.dart';
import 'package:appmovil261/features/login/ui/bloc/login_bloc.dart';
import 'package:appmovil261/features/login/ui/screens/login_screen.dart';
import 'package:appmovil261/core/navigation/main_screen.dart';
import 'package:appmovil261/features/profile/ui/bloc/profile_bloc.dart';
import 'package:appmovil261/features/signup/ui/bloc/signup_bloc.dart';
import 'package:appmovil261/features/signup/ui/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fpianmjkmswezahrnqfx.supabase.co',
    anonKey: 'sb_publishable_cP3fKERWtTvn35dpBD_eeg_texEvON2',
  );

  await initDependencies();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/login': (_) =>
            BlocProvider(create: (_) => sl<LoginBloc>(), child: LoginScreen()),
        '/signup': (_) =>
            BlocProvider(create: (_) => SignupBloc(), child: SignupScreen()),
        '/home': (_) => BlocProvider(
          create: (_) => ProfileBloc(),
          child: const MainScreen(),
        ),
      },
    );
  }
}
