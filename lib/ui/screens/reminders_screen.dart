import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/sms_provider.dart';
import '../../models/reminder.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final smsProvider = context.watch<SmsProvider>();
    final reminders = smsProvider.upcomingReminders;
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart reminders'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: reminders.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'No upcoming reminders found from SMS yet.\n\n'
                    'When you receive bills, deliveries or booking messages, '
                    'TrueInbox will try to extract dates and show them here.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                ),
              )
            : ListView.separated(
                padding:
                    const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: reminders.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final r = reminders[index];
                  return _ReminderTile(reminder: r);
                },
              ),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final Reminder reminder;

  const _ReminderTile({required this.reminder});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final dateStr =
        '${reminder.dueDate.day.toString().padLeft(2, '0')}/'
        '${reminder.dueDate.month.toString().padLeft(2, '0')}/'
        '${reminder.dueDate.year}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 3),
            color: Colors.black.withOpacity(0.04),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor:
                color.primary.withOpacity(0.12),
            child: Icon(
              _iconForTitle(reminder.title),
              color: color.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reminder.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: color.outline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dateStr,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('bill') || t.contains('payment')) {
      return Icons.receipt_long_rounded;
    }
    if (t.contains('delivery')) {
      return Icons.local_shipping_rounded;
    }
    if (t.contains('appointment') || t.contains('meeting')) {
      return Icons.event_available_rounded;
    }
    if (t.contains('travel') || t.contains('ticket')) {
      return Icons.flight_takeoff_rounded;
    }
    return Icons.notifications_active_rounded;
  }
}
