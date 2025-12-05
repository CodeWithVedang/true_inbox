import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About TrueInbox'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        color.primary.withOpacity(0.12),
                    child: Icon(
                      Icons.shield_rounded,
                      color: color.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TrueInbox',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Smart SMS inbox with fraud detection, TRAI header checks, financial stress analysis and reminders.',
                          style: textTheme.bodySmall?.copyWith(
                            color: color.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Version 1.0.0 (Student Project)',
                          style: textTheme.labelSmall?.copyWith(
                            color: color.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Project overview',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'TrueInbox is an SMS-aware Android application built with Flutter. '
              'It automatically reads SMS (with user permission), categorises them into OTP, transactional, promotional, personal and malicious, '
              'and then applies additional intelligence like TRAI header validation, scam risk scoring, OTP abuse detection and financial stress analysis.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Key capabilities',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            _BulletPoint(
              icon: Icons.rule_folder_rounded,
              text:
                  'TRAI-compliant header and principal entity checking for India-specific senders.',
            ),
            _BulletPoint(
              icon: Icons.security_rounded,
              text:
                  'Per-message scam risk score with highlighting of suspicious links and patterns.',
            ),
            _BulletPoint(
              icon: Icons.lock_clock_rounded,
              text:
                  'OTP abuse / identity misuse detection based on unusual OTP patterns.',
            ),
            _BulletPoint(
              icon: Icons.account_balance_wallet_rounded,
              text:
                  'Financial stress estimation using EMIs, overdue, penalties and loan offers from SMS.',
            ),
            _BulletPoint(
              icon: Icons.event_rounded,
              text:
                  'Automatic reminders for bills, deliveries, appointments and travel.',
            ),
            _BulletPoint(
              icon: Icons.insights_rounded,
              text:
                  'Inbox analytics dashboard with category distribution, risk breakdown and 7-day activity.',
            ),
            const SizedBox(height: 16),
            Text(
              'Privacy & data',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'All analysis is done locally on the device using your SMS inbox. '
              'No SMS content is uploaded to any external server in this project implementation. '
              'This design keeps the user in control and is suitable for academic / prototype use.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Project details',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            _LabelValueRow(
              label: 'Student',
              value: 'Your Name (replace here)',
            ),
            _LabelValueRow(
              label: 'Institute',
              value: 'Your College / University',
            ),
            _LabelValueRow(
              label: 'Course',
              value: 'e.g. MCA / B.E. (Computer Engineering)',
            ),
            _LabelValueRow(
              label: 'Guide / Mentor',
              value: 'Guide Name (replace here)',
            ),
            _LabelValueRow(
              label: 'Academic year',
              value: '2024–2025',
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BulletPoint({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelValueRow extends StatelessWidget {
  final String label;
  final String value;

  const _LabelValueRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
