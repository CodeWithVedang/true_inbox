import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/sms_provider.dart';
import '../../models/sms_message.dart';
import '../../models/sms_category.dart';
import '../widgets/financial_health_card.dart';
import '../widgets/message_card.dart';

class FinancialInsightsScreen extends StatelessWidget {
  const FinancialInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final smsProvider = context.watch<SmsProvider>();
    final color = Theme.of(context).colorScheme;

    final financialMessages =
        _buildFinancialMessages(smsProvider.allMessages);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial insights'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            FinancialHealthCard(
              report: smsProvider.stressReport,
            ),
            const SizedBox(height: 12),
            Text(
              'Financial-related SMS (last 30 days)',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            if (financialMessages.isEmpty)
              Text(
                'No recent EMI, overdue, penalty or loan-offer messages detected.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: color.outline),
              )
            else
              ...financialMessages.map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: MessageCard(message: m),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<SmsMessage> _buildFinancialMessages(
      List<SmsMessage> allMessages) {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(days: 30));

    return allMessages
        .where((m) {
          if (m.timestamp.isBefore(cutoff)) return false;
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
            'bill',
            'due amount',
          ]);
          return isFinanceCategory && hasFinanceKeyword;
        })
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  bool _any(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }
}
