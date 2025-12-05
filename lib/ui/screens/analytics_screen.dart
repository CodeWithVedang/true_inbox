import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/sms_provider.dart';
import '../../models/sms_message.dart';
import '../../models/sms_category.dart';

class AnalyticsScreen extends StatelessWidget {
  static const routeName = '/analytics';

  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final smsProvider = context.watch<SmsProvider>();
    final messages = smsProvider.allMessages;

    final categoryStats = _buildCategoryStats(messages);
    final last7DaysStats = _buildLast7DaysStats(messages);
    final riskStats = _buildRiskStats(messages);

    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox analytics'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            _SectionCard(
              title: 'Message categories',
              subtitle:
                  'Distribution of OTP, promotional, transactional and other SMS.',
              child: Column(
                children: [
                  for (final stat in categoryStats)
                    _HorizontalBarRow(
                      label: stat.label,
                      icon: stat.icon,
                      color: stat.color,
                      value: stat.count,
                      percentage: stat.percentage,
                    ),
                  if (messages.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'No messages to analyze yet.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: color.outline),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Last 7 days activity',
              subtitle:
                  'How many SMS you received per day (all categories).',
              child: _Last7DaysChart(stats: last7DaysStats),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Risk distribution',
              subtitle: 'Breakdown of low, medium and high-risk messages.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HorizontalBarRow(
                    label: 'Low risk',
                    icon: Icons.shield_rounded,
                    color: Colors.green,
                    value: riskStats.lowCount,
                    percentage: riskStats.lowPercent,
                  ),
                  _HorizontalBarRow(
                    label: 'Medium risk',
                    icon: Icons.shield_moon_rounded,
                    color: color.tertiary,
                    value: riskStats.mediumCount,
                    percentage: riskStats.mediumPercent,
                  ),
                  _HorizontalBarRow(
                    label: 'High risk',
                    icon: Icons.dangerous_rounded,
                    color: color.error,
                    value: riskStats.highCount,
                    percentage: riskStats.highPercent,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Average inbox risk score: ${smsProvider.inboxRiskScore}/100',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: color.outline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- CATEGORY STATS ----------

  List<_CategoryStat> _buildCategoryStats(List<SmsMessage> messages) {
    final total = messages.length;
    if (total == 0) {
      return SmsCategory.values
          .where((c) => c != SmsCategory.all)
          .map(
            (c) => _CategoryStat(
              label: c.label,
              icon: c.icon,
              color: c.color,
              count: 0,
              percentage: 0,
            ),
          )
          .toList();
    }

    final Map<SmsCategory, int> counts = {
      for (final c in SmsCategory.values) c: 0,
    };

    for (final m in messages) {
      counts[m.category] = (counts[m.category] ?? 0) + 1;
    }

    final list = <_CategoryStat>[];
    for (final c in SmsCategory.values) {
      if (c == SmsCategory.all) continue;
      final count = counts[c] ?? 0;
      final percent = ((count / total) * 100).round();
      list.add(
        _CategoryStat(
          label: c.label,
          icon: c.icon,
          color: c.color,
          count: count,
          percentage: percent,
        ),
      );
    }

    list.sort((a, b) => b.count.compareTo(a.count));
    return list;
  }

  // ---------- LAST 7 DAYS ----------

  List<_DayStat> _buildLast7DaysStats(List<SmsMessage> messages) {
    final now = DateTime.now();
    final Map<String, int> counts = {};

    for (int i = 0; i < 7; i++) {
      final d = now.subtract(Duration(days: i));
      final key = _dayKey(d);
      counts[key] = 0;
    }

    for (final m in messages) {
      final d = DateTime(m.timestamp.year, m.timestamp.month, m.timestamp.day);
      final key = _dayKey(d);
      if (counts.containsKey(key)) {
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }

    final List<_DayStat> result = [];
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final key = _dayKey(d);
      result.add(
        _DayStat(
          label: _shortDayLabel(d),
          count: counts[key] ?? 0,
        ),
      );
    }

    return result;
  }

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _shortDayLabel(DateTime d) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[d.weekday % 7];
  }

  // ---------- RISK STATS ----------

  _RiskStats _buildRiskStats(List<SmsMessage> messages) {
    if (messages.isEmpty) {
      return const _RiskStats(
        lowCount: 0,
        mediumCount: 0,
        highCount: 0,
        lowPercent: 0,
        mediumPercent: 0,
        highPercent: 0,
      );
    }

    int low = 0, med = 0, high = 0;

    for (final m in messages) {
      final s = m.riskScore;
      if (s >= 70) {
        high++;
      } else if (s >= 40) {
        med++;
      } else {
        low++;
      }
    }

    final total = messages.length;
    int pct(int c) => ((c / total) * 100).round();

    return _RiskStats(
      lowCount: low,
      mediumCount: med,
      highCount: high,
      lowPercent: pct(low),
      mediumPercent: pct(med),
      highPercent: pct(high),
    );
  }
}

// ===== Helper data models for analytics =====

class _CategoryStat {
  final String label;
  final IconData icon;
  final Color color;
  final int count;
  final int percentage;

  _CategoryStat({
    required this.label,
    required this.icon,
    required this.color,
    required this.count,
    required this.percentage,
  });
}

class _DayStat {
  final String label;
  final int count;

  _DayStat({
    required this.label,
    required this.count,
  });
}

class _RiskStats {
  final int lowCount;
  final int mediumCount;
  final int highCount;
  final int lowPercent;
  final int mediumPercent;
  final int highPercent;

  const _RiskStats({
    required this.lowCount,
    required this.mediumCount,
    required this.highCount,
    required this.lowPercent,
    required this.mediumPercent,
    required this.highPercent,
  });
}

// ===== Reusable UI widgets =====

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.04),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: color.outline),
            ),
          ],
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _HorizontalBarRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int value;
  final int percentage; // 0–100

  const _HorizontalBarRow({
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: (percentage.clamp(0, 100)) / 100.0,
                color: color,
                backgroundColor:
                    scheme.surfaceVariant.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              value == 0 ? '-' : '$value (${percentage.clamp(0, 100)}%)',
              textAlign: TextAlign.end,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: scheme.outline),
            ),
          ),
        ],
      ),
    );
  }
}

class _Last7DaysChart extends StatelessWidget {
  final List<_DayStat> stats;

  const _Last7DaysChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (stats.isEmpty) {
      return Text(
        'No recent activity.',
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: scheme.outline),
      );
    }

    final maxCount = stats.fold<int>(0, (max, d) => d.count > max ? d.count : max);
    final safeMax = maxCount == 0 ? 1 : maxCount;

    return Row(
      children: stats.map((d) {
        final fraction = d.count / safeMax;
        final barHeight = 60.0 * (fraction == 0 ? 0.1 : fraction);

        return Expanded(
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: barHeight,
                width: 10,
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(
                      fraction == 0 ? 0.15 : (0.3 + 0.4 * fraction)),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                d.label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: scheme.outline),
              ),
              const SizedBox(height: 2),
              Text(
                d.count == 0 ? '-' : d.count.toString(),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
