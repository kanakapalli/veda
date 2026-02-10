import 'package:veda_client/veda_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/main_shell.dart';
import 'screens/sign_in_screen.dart';
import 'screens/web/course/course_onboarding_screen.dart';
import 'screens/web/auth/web_creator_auth_flow.dart';

/// Sets up a global client object that can be used to talk to the server from
/// anywhere in our app. The client is generated from your server code
/// and is set up to connect to a Serverpod running on a local server on
/// the default port. You will need to modify this to connect to staging or
/// production servers.
/// In a larger app, you may want to use the dependency injection of your choice
/// instead of using a global client object. This is just a simple example.
late final Client client;

late String serverUrl;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // When you are running the app on a physical device, you need to set the
  // server URL to the IP address of your computer. You can find the IP
  // address by running `ipconfig` on Windows or `ifconfig` on Mac/Linux.
  //
  // You can set the variable when running or building your app like this:
  // E.g. `flutter run --dart-define=SERVER_URL=https://api.example.com/`.
  //
  // Otherwise, the server URL is fetched from the assets/config.json file or
  // defaults to http://$localhost:8080/ if not found.
  final serverUrl = await getServerUrl();

  client = Client(
    serverUrl,
    connectionTimeout: const Duration(seconds: 120),
  )
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();

  client.auth.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const _black = Color(0xFF000000);
  static const _white = Color(0xFFFFFFFF);
  static const _accent = Color(0xFF4A90E2);
  static const _grey800 = Color(0xFF424242);
  static const _grey900 = Color(0xFF212121);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _black,
        colorScheme: const ColorScheme.dark(
          surface: _black,
          primary: _accent,
          onPrimary: _white,
          onSurface: _white,
        ),
        extensions: [
          AuthIdpTheme(
            defaultPinTheme: PinTheme(
              width: 48,
              height: 56,
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                color: _white,
                fontFamily: 'Courier',
                letterSpacing: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: _grey800, width: 1),
              ),
            ),
            focusedPinTheme: PinTheme(
              width: 48,
              height: 56,
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                color: _white,
                fontFamily: 'Courier',
                letterSpacing: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: _accent, width: 1),
              ),
            ),
            errorPinTheme: PinTheme(
              width: 48,
              height: 56,
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                color: Color(0xFFEF5350),
                fontFamily: 'Courier',
                letterSpacing: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: Color(0xFFEF5350), width: 1),
              ),
            ),
            separator: const SizedBox(width: 8),
          ),
        ],

        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: _black,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: _white,
            letterSpacing: -0.5,
          ),
        ),

        // Input fields: 1pt border, no fill, square corners
        inputDecorationTheme: InputDecorationTheme(
          filled: false,
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: _grey800, width: 1),
            borderRadius: BorderRadius.zero,
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: _grey800, width: 1),
            borderRadius: BorderRadius.zero,
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: _accent, width: 1),
            borderRadius: BorderRadius.zero,
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFEF5350), width: 1),
            borderRadius: BorderRadius.zero,
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFEF5350), width: 1),
            borderRadius: BorderRadius.zero,
          ),
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.3,
          ),
          labelStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),

        // ElevatedButton: 56px, outline, transparent bg
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return Colors.transparent;
              }
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.pressed)) {
                return _grey900;
              }
              return Colors.transparent;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return _white.withAlpha(128);
              }
              return _white;
            }),
            elevation: const WidgetStatePropertyAll(0),
            minimumSize:
                const WidgetStatePropertyAll(Size(double.infinity, 56)),
            shape: const WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            side: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return const BorderSide(color: _grey900, width: 1);
              }
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.pressed)) {
                return const BorderSide(color: _white, width: 1);
              }
              return const BorderSide(color: _grey800, width: 1);
            }),
            overlayColor: const WidgetStatePropertyAll(_grey900),
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
              ),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 24),
            ),
          ),
        ),

        // FilledButton: same outline style
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.pressed)) {
                return _grey900;
              }
              return Colors.transparent;
            }),
            foregroundColor: const WidgetStatePropertyAll(_white),
            elevation: const WidgetStatePropertyAll(0),
            minimumSize:
                const WidgetStatePropertyAll(Size(double.infinity, 56)),
            shape: const WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            side: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.pressed)) {
                return const BorderSide(color: _white, width: 1);
              }
              return const BorderSide(color: _grey800, width: 1);
            }),
            overlayColor: const WidgetStatePropertyAll(_grey900),
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),

        // OutlinedButton: same outline style
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: const WidgetStatePropertyAll(_white),
            minimumSize:
                const WidgetStatePropertyAll(Size(double.infinity, 56)),
            shape: const WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            side: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.pressed)) {
                return const BorderSide(color: _white, width: 1);
              }
              return const BorderSide(color: _grey800, width: 1);
            }),
            overlayColor: const WidgetStatePropertyAll(_grey900),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),

        // TextButton: blue accent, no background
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: const WidgetStatePropertyAll(_accent),
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.2,
              ),
            ),
            padding: const WidgetStatePropertyAll(EdgeInsets.zero),
            minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),

        // Progress indicator
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: _accent,
          linearMinHeight: 1,
        ),

        // Text theme per design guidelines
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w300,
            color: _white,
            letterSpacing: -1.2,
            height: 1.0,
          ),
          headlineMedium: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: _white,
            letterSpacing: -0.5,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.grey[500],
            letterSpacing: 0.5,
          ),
          bodyMedium: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: _white,
            letterSpacing: 0.3,
          ),
          bodySmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Colors.grey[700],
            letterSpacing: 0.2,
            height: 1.6,
          ),
          labelLarge: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: _white,
            letterSpacing: 0.3,
          ),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Web: Show Creator Authentication -> Course Onboarding Screen
    if (kIsWeb) {
      return const WebCreatorAuthFlow(
        child: CourseOnboardingScreen(),
      );
    }

    // Mobile (iOS/Android): Show learner authentication flow
    return SignInScreen(
      child: MainShell(
        onSignOut: () async {
          await client.auth.signOutDevice();
        },
      ),
    );
  }
}
