import 'package:flutter/material.dart';

import '../../services/otp_abuse_service.dart';

class OtpAlertCard extends StatelessWidget {
  final OtpAbuseReport report;

  const OtpAlertCard({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    if (!report.isSuspicious) {
      // No card if pattern is normal.
      return const SizedBox.shrink();
    }

    final color = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.errorContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.error.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security_rounded, color: color.error, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unusual OTP activity detected',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color.error,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  report.explanation,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _StatChip(
                      icon: Icons.lock_clock_rounded,
                      label: 'Last 1 hour: ${report.otpLastHour}',
                      color: color.error,
                    ),
                    _StatChip(
                      icon: Icons.schedule_rounded,
                      label: 'Last 24 hours: ${report.otpLast24h}',
                      color: color.error,
                    ),
                    _StatChip(
                      icon: Icons.bolt_rounded,
                      label: 'Max in 5 min: ${report.burstMaxIn5Min}',
                      color: color.error,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'If you did not request these OTPs, your accounts may be under attack. Change passwords and contact your bank/service provider.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: color.error),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
