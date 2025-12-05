import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/sms_provider.dart';
import '../../models/sms_message.dart';
import '../../models/sms_category.dart';
import '../widgets/message_card.dart';
import 'report_screen.dart';

enum SecurityFilter {
  allRisk,
  malicious,
  highRiskScore,
  unregistered,
  financial,
  otpHeavy,
}

class SecurityCenterScreen extends StatefulWidget {
  static const routeName = '/security-center';

  final SecurityFilter initialFilter;

  const SecurityCenterScreen({
    super.key,
    this.initialFilter = SecurityFilter.allRisk,
  });

  @override
  State<SecurityCenterScreen> createState() => _SecurityCenterScreenState();
}

class _SecurityCenterScreenState extends State<SecurityCenterScreen> {
  late SecurityFilter _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final smsProvider = context.watch<SmsProvider>();
    final color = Theme.of(context).colorScheme;

    final allMessages = smsProvider.allMessages;
    final filtered = _applyFilter(
      allMessages: allMessages,
      filter: _selectedFilter,
      smsProvider: smsProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Center'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Export report',
            icon: const Icon(Icons.description_rounded),
            onPressed: () {
              Navigator.pushNamed(context, ReportScreen.routeName);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            _SecuritySummaryHeader(),
            const SizedBox(height: 12),
            _FilterChipsRow(
              selected: _selectedFilter,
              onChanged: (f) {
                setState(() {
                  _selectedFilter = f;
                });
              },
            ),
            const SizedBox(height: 12),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Column(
                  children: [
                    Icon(Icons.shield_moon_rounded,
                        size: 64, color: color.outline),
                    const SizedBox(height: 12),
                    Text(
                      'No messages in this category',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your inbox looks clean for the selected filter. Keep staying safe online.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${filtered.length} message(s) matched',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: color.outline),
                  ),
                  const SizedBox(height: 8),
                  ...filtered.map(
                    (msg) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: MessageCard(message: msg),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<SmsMessage> _applyFilter({
    required List<SmsMessage> allMessages,
    required SecurityFilter filter,
    required SmsProvider smsProvider,
  }) {
    final now = DateTime.now();

    switch (filter) {
      case SecurityFilter.allRisk:
        return allMessages
            .where((m) =>
                m.category == SmsCategory.malicious ||
                m.riskScore >= 50 ||
                m.hasSuspiciousLink)
            .toList()
          ..sort((a, b) => b.riskScore.compareTo(a.riskScore));

      case SecurityFilter.malicious:
        return allMessages
            .where((m) => m.category == SmsCategory.malicious)
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      case SecurityFilter.highRiskScore:
        return allMessages
            .where((m) => m.riskScore >= 70)
            .toList()
          ..sort((a, b) => b.riskScore.compareTo(a.riskScore));

      case SecurityFilter.unregistered:
        return allMessages
            .where((m) =>
                !m.isRegisteredHeader &&
                (m.riskScore >= 40 ||
                    m.category == SmsCategory.malicious ||
                    m.hasSuspiciousLink))
            .toList()
          ..sort((a, b) => b.riskScore.compareTo(a.riskScore));

      case SecurityFilter.financial:
        return allMessages
            .where((m) {
              if (m.timestamp
                  .isBefore(now.subtract(const Duration(days: 30)))) {
                return false;
              }
              final text = m.body.toLowerCase();
              final bool isFinanceCategory =
                  m.category == SmsCategory.transactional ||
                      m.category == SmsCategory.promotional;
              final bool hasFinanceKeyword = _any(text, [
                'emi',
                'equated monthly instal',
                'overdue',
                'late fee',
                'penalty',
                'loan',
                'credit card',
                'limit',
              ]);
              return isFinanceCategory && hasFinanceKeyword;
            })
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      case SecurityFilter.otpHeavy:
        final last24hCutoff = now.subtract(const Duration(hours: 24));
        return allMessages
            .where((m) =>
                m.category == SmsCategory.otp &&
                m.timestamp.isAfter(last24hCutoff))
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
  }

  bool _any(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }
}

class _SecuritySummaryHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final smsProvider = context.watch<SmsProvider>();
    final color = Theme.of(context).colorScheme;

    final inboxRisk = smsProvider.inboxRiskScore;
    final highRiskCount = smsProvider.highRiskCount;
    final maliciousCount = smsProvider.maliciousCount;
    final stress = smsProvider.stressReport;
    final otpAbuse = smsProvider.otpAbuseReport;

    final riskLabel = _riskLabel(inboxRisk);
    final riskColor = _riskColor(inboxRisk, color);

    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security overview',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: riskColor.withOpacity(0.1),
                child: Icon(Icons.shield_rounded,
                    color: riskColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inbox risk: $riskLabel ($inboxRisk/100)',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: riskColor,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$highRiskCount high-risk SMS • $maliciousCount malicious SMS',
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
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _MiniChip(
                icon: Icons.account_balance_wallet_rounded,
                label:
                    'Financial stress: ${stress.score}/100',
                color: stress.isHighStress
                    ? color.error
                    : color.primary,
              ),
              _MiniChip(
                icon: Icons.lock_clock_rounded,
                label: otpAbuse.isSuspicious
                    ? 'Unusual OTP activity'
                    : 'OTP activity normal',
                color: otpAbuse.isSuspicious
                    ? color.error
                    : color.tertiary,
              ),
            ],
          ),
        ],
      ),
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

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MiniChip({
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

class _FilterChipsRow extends StatelessWidget {
  final SecurityFilter selected;
  final ValueChanged<SecurityFilter> onChanged;

  const _FilterChipsRow({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = SecurityFilter.values;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final f = filters[index];
          final isSelected = f == selected;
          final label = _labelForFilter(f);
          final icon = _iconForFilter(f);

          return ChoiceChip(
            label: Text(label),
            avatar: Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary,
            ),
            selected: isSelected,
            onSelected: (_) => onChanged(f),
          );
        },
      ),
    );
  }

  String _labelForFilter(SecurityFilter f) {
    switch (f) {
      case SecurityFilter.allRisk:
        return 'All risk';
      case SecurityFilter.malicious:
        return 'Malicious';
      case SecurityFilter.highRiskScore:
        return 'High risk score';
      case SecurityFilter.unregistered:
        return 'Unregistered senders';
      case SecurityFilter.financial:
        return 'Financial';
      case SecurityFilter.otpHeavy:
        return 'OTP heavy';
    }
  }

  IconData _iconForFilter(SecurityFilter f) {
    switch (f) {
      case SecurityFilter.allRisk:
        return Icons.shield_moon_rounded;
      case SecurityFilter.malicious:
        return Icons.warning_amber_rounded;
      case SecurityFilter.highRiskScore:
        return Icons.dangerous_rounded;
      case SecurityFilter.unregistered:
        return Icons.verified_user_outlined;
      case SecurityFilter.financial:
        return Icons.account_balance_wallet_rounded;
      case SecurityFilter.otpHeavy:
        return Icons.lock_clock_rounded;
    }
  }
}
