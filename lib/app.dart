import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/message_detail_screen.dart';
import 'ui/screens/security_center_screen.dart';
import 'ui/screens/analytics_screen.dart';
import 'ui/screens/report_screen.dart';
import 'models/sms_message.dart';

class TrueInboxApp extends StatelessWidget {
  const TrueInboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrueInbox',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: OnboardingScreen.routeName,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case OnboardingScreen.routeName:
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());

          case HomeScreen.routeName:
            return MaterialPageRoute(builder: (_) => const HomeScreen());

          case SecurityCenterScreen.routeName:
            return MaterialPageRoute(
              builder: (_) => const SecurityCenterScreen(),
            );

          case AnalyticsScreen.routeName:
            return MaterialPageRoute(
              builder: (_) => const AnalyticsScreen(),
            );

          case ReportScreen.routeName:
            return MaterialPageRoute(
              builder: (_) => const ReportScreen(),
            );

          case MessageDetailScreen.routeName:
            final sms = settings.arguments as SmsMessage;
            return MaterialPageRoute(
              builder: (_) => MessageDetailScreen(message: sms),
            );

          default:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
      },
    );
  }
}
