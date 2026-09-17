import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:guitercord/auth/auth_role_wrapper.dart';
import 'package:guitercord/auth/login.dart';
import 'package:guitercord/core/splash_screen.dart';
import 'package:guitercord/firebase_options.dart';
import 'package:guitercord/provider/favorites_provider.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Keep the native splash up until Firebase is ready, so there's no white flash.
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FavoritesManager.init();
  } catch (e) {
    debugPrint("Initialization Error: $e");
  }
  runApp(const ChordApp());
  FlutterNativeSplash.remove();
}

class ChordApp extends StatefulWidget {
  const ChordApp({super.key});

  @override
  State<ChordApp> createState() => _ChordAppState();
}

class _ChordAppState extends State<ChordApp> {
  bool isDarkMode = false;

  void toggleTheme() => setState(() => isDarkMode = !isDarkMode);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guitar Chords',
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      home: const AuthEntryGate(),
    );
  }
}

class AuthEntryGate extends StatelessWidget {
  const AuthEntryGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.hasData && snapshot.data != null) {
          return AuthRoleWrapper(user: snapshot.data!);
        }

        return const LoginScreen();
      },
    );
  }
}

final ThemeData _lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorSchemeSeed: const Color(0xFF6200EE),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF6200EE),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
);

final ThemeData _darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorSchemeSeed: const Color(0xFF8E54E9),
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1F1B24),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
);
