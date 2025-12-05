import 'package:flutter/material.dart';

class StatsHeader extends StatelessWidget {
  final int maliciousCount;
  final int otpToday;
  final int inboxRiskScore;
  final int highRiskCount;

  const StatsHeader({
    super.key,
    required this.maliciousCount,
    required this.otpToday,
    required this.inboxRiskScore,
    required this.highRiskCount,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    final riskLabel = _riskLabel(inboxRiskScore);
    final riskColor = _riskColor(inboxRiskScore, color);

    return Row(
      children: [
        Expanded(
          child: _RiskCard(
            label: 'Inbox risk',
            riskLabel: riskLabel,
            score: inboxRiskScore,
            highRiskCount: highRiskCount,
            color: riskColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Malicious SMS',
            value: maliciousCount.toString(),
            subtitle: 'OTPs today: $otpToday',
            icon: Icons.warning_amber_rounded,
            color: color.error,
          ),
        ),
      ],
    );
  }

  String _riskLabel(int score) {
    if (score >= 70) return 'High';
    if (score >= 40) return 'Medium';
    return 'Low';
  }

  Color _riskColor(int score, ColorScheme scheme) {
    if (score >= 70) return scheme.error;
    if (score >= 40) return scheme.tertiary;
    return scheme.primary;
  }
}

class _RiskCard extends StatelessWidget {
  final String label;
  final String riskLabel;
  final int score;
  final int highRiskCount;
  final Color color;

  const _RiskCard({
    required this.label,
    required this.riskLabel,
    required this.score,
    required this.highRiskCount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ).borderRadius,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.outline),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(
                  Icons.shield_rounded,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$riskLabel (${score.clamp(0, 100)}/100)',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$highRiskCount high-risk SMS detected',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.outline),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
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
            radius: 18,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: scheme.outline),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: scheme.outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
