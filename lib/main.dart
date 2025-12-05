import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/sms_provider.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TrueInboxApp());
}

class TrueInboxApp extends StatelessWidget {
  const TrueInboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SmsProvider(),
        ),
        // if you have other providers, add them here
      ],
      child: MaterialApp(
        title: 'TrueInbox',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
          ),
        ),
        // We start on Splash, which then decides Onboarding vs Home
        home: const SplashScreen(),

        // Optional: you can still keep routes if you want
        routes: {
          SplashScreen.routeName: (_) => const SplashScreen(),
          OnboardingScreen.routeName: (_) => const OnboardingScreen(),
          HomeScreen.routeName: (_) => const HomeScreen(),
        },
      ),
    );
  }
}
