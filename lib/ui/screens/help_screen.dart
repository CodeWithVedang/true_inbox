import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('How to use TrueInbox'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _SectionCard(
              icon: Icons.sms_rounded,
              title: '1. Grant SMS permission',
              child: Text(
                'On first launch, TrueInbox will ask for permission to read SMS. '
                'You must allow this so the app can categorise your messages into OTP, transactional, promotional, genuine and malicious. '
                'All analysis is done locally on your device.',
                style: textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              icon: Icons.inbox_rounded,
              title: '2. Home screen overview',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The home screen shows:',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  _Bullet('Top stats for malicious SMS, OTP today and inbox risk score.'),
                  _Bullet(
                      'Smart reminders section for upcoming bills, deliveries and appointments extracted from transactional SMS.'),
                  _Bullet(
                      'Financial health card showing your estimated financial stress score from SMS.'),
                  _Bullet(
                      'Search bar and category filters (All / OTP / Transactional / Promotional / Genuine / Malicious).'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              icon: Icons.shield_rounded,
              title: '3. Understanding risk score & badges',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Every message gets a risk score from 0–100 based on keywords, links, header validity and patterns:',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  _Bullet('0–39: Low risk – usually safe / transactional / known sender.'),
                  _Bullet('40–69: Medium risk – unknown sender, marketing, or slightly suspicious content.'),
                  _Bullet('70–100: High risk – strong scam/phishing patterns or very suspicious links.'),
                  const SizedBox(height: 10),
                  Text(
                    'Badges you might see:',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  _Bullet('“Malicious” category – message flagged as clearly risky.'),
                  _Bullet('“Suspicious link” tag – URL pattern looks dangerous (shorteners, random domains, etc.).'),
                  _Bullet('“Unregistered sender” – does not match TRAI header list (for Indian promotional senders).'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              icon: Icons.lock_clock_rounded,
              title: '4. OTP abuse / identity misuse alert',
              child: Text(
                'TrueInbox tracks how many OTP messages you receive. If there are many OTPs in a short time, '
                'it shows an “Unusual OTP activity” warning on the home screen. This may indicate someone is trying to log in or reset passwords on your accounts. '
                'If you see this and you did not request OTPs, change your passwords and contact your bank / services.',
                style: textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              icon: Icons.account_balance_wallet_rounded,
              title: '5. Financial stress card',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The Financial Stress card uses only SMS patterns such as EMIs, overdue reminders, penalties and loan offers. '
                    'It gives a score from 0–100:',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  _Bullet('0–39: Low – normal financial messages, few or no overdue alerts.'),
                  _Bullet('40–69: Medium – some overdue / penalty messages or frequent loan offers.'),
                  _Bullet('70–100: High – many overdue / penalty messages and frequent loan offers.'),
                  const SizedBox(height: 6),
                  Text(
                    'This is not a bank statement – it is only an approximate stress indication based on SMS content.',
                    style: textTheme.bodySmall?.copyWith(
                      color: color.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              icon: Icons.event_rounded,
              title: '6. Smart reminders from SMS',
              child: Text(
                'TrueInbox scans your transactional SMS (bills, orders, bookings) and extracts approximate due dates or event dates. '
                'These are shown as “Smart reminders” on the home screen with short descriptions like bill payments, deliveries or appointments.',
                style: textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              icon: Icons.shield_moon_rounded,
              title: '7. Security Center',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From the top bar on the home screen you can open the Security Center. It lets you:',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  _Bullet('See a security summary for your inbox.'),
                  _Bullet('Filter by malicious, high risk, unregistered senders, financial risk and OTP-heavy messages.'),
                  _Bullet('Open detailed view of any risky SMS to inspect the content and links.'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              icon: Icons.insights_rounded,
              title: '8. Analytics & report',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bullet(
                      'Analytics screen: shows category distribution, risk distribution and last 7 days activity chart.'),
                  _Bullet(
                      'Security report: generates a plain-text summary that you can copy into your project report or share.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tip: This help screen is great to show during your viva to explain what each part of TrueInbox does.',
              style: textTheme.bodySmall?.copyWith(
                color: color.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;

  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
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
