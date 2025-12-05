import 'package:flutter/material.dart';

import '../../services/financial_stress_service.dart';

class FinancialHealthCard extends StatelessWidget {
  final FinancialStressReport report;

  const FinancialHealthCard({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    final score = report.score.clamp(0, 100);
    final label = _label(score);
    final scoreColor = _color(score, color);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Icon(Icons.account_balance_wallet_rounded,
                  color: scoreColor),
              const SizedBox(width: 8),
              Text(
                'Financial stress',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Text(
                '$label ($score/100)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scoreColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: score / 100.0,
              color: scoreColor,
              backgroundColor: color.surfaceVariant.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _StatChip(
                icon: Icons.receipt_long_rounded,
                label: 'EMI / bills: ${report.emiCountLast30d}',
                color: color.primary,
              ),
              _StatChip(
                icon: Icons.warning_amber_rounded,
                label: 'Overdue: ${report.overdueCount}',
                color: color.error,
              ),
              _StatChip(
                icon: Icons.error_outline_rounded,
                label: 'Penalties: ${report.penaltyCount}',
                color: color.error,
              ),
              _StatChip(
                icon: Icons.request_page_rounded,
                label: 'Loan offers: ${report.loanOfferCount}',
                color: color.tertiary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            report.explanation,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: color.outline),
          ),
          if (report.isHighStress) ...[
            const SizedBox(height: 6),
            Text(
              'Tip: Consider reviewing your EMIs, due bills and avoiding suspicious loan offers. If needed, talk to your bank or a financial advisor.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: color.error),
            ),
          ],
        ],
      ),
    );
  }

  String _label(int score) {
    if (score >= 70) return 'High';
    if (score >= 40) return 'Medium';
    return 'Low';
  }

  Color _color(int score, ColorScheme scheme) {
    if (score >= 70) return scheme.error;
    if (score >= 40) return scheme.tertiary;
    return scheme.primary;
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
