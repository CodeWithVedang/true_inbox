import 'package:flutter/material.dart';

import 'about_screen.dart';
import 'security_center_screen.dart';
import 'analytics_screen.dart';
import 'report_screen.dart';
import 'help_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & More'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text(
              'Quick actions',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            _CardWrapper(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.shield_rounded,
                        color: color.primary),
                    title: const Text('Open Security Center'),
                    subtitle: const Text(
                        'View high-risk SMS, filters and security summary.'),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        SecurityCenterScreen.routeName,
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.insights_rounded,
                        color: color.tertiary),
                    title: const Text('View Inbox Analytics'),
                    subtitle: const Text(
                        'Category distribution, activity and risk breakdown.'),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AnalyticsScreen.routeName,
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.description_rounded,
                        color: color.secondary),
                    title: const Text('Generate Security Report'),
                    subtitle: const Text(
                        'Plain-text report for project / export / sharing.'),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        ReportScreen.routeName,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Appearance',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            _CardWrapper(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.dark_mode_rounded),
                    title: const Text('Theme'),
                    subtitle: const Text(
                      'Uses system light / dark mode by default.',
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Theme follows system setting in this version.'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'About & help',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            _CardWrapper(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.info_outline_rounded,
                        color: color.primary),
                    title: const Text('About TrueInbox'),
                    subtitle: const Text(
                        'Project description, features and credits.'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AboutScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.menu_book_rounded,
                        color: color.tertiary),
                    title: const Text('How to use TrueInbox'),
                    subtitle: const Text(
                        'Step-by-step explanation of features and scores.'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HelpScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.privacy_tip_rounded,
                        color: color.tertiary),
                    title: const Text('Privacy & data'),
                    subtitle: const Text(
                      'All SMS analysis is done locally on-device in this project build.',
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Current prototype does not upload SMS to any server.',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'TrueInbox • Student Project',
                style: textTheme.bodySmall?.copyWith(
                  color: color.outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardWrapper extends StatelessWidget {
  final Widget child;

  const _CardWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 3),
            color: Colors.black.withOpacity(0.04),
          ),
        ],
      ),
      child: child,
    );
  }
}
