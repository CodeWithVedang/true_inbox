import 'package:flutter/material.dart';

import '../../models/reminder.dart';

class RemindersCard extends StatelessWidget {
  final List<Reminder> upcomingReminders;
  final int upcomingWithin7DaysCount;

  const RemindersCard({
    super.key,
    required this.upcomingReminders,
    required this.upcomingWithin7DaysCount,
  });

  @override
  Widget build(BuildContext context) {
    if (upcomingReminders.isEmpty) {
      return const SizedBox.shrink();
    }

    final color = Theme.of(context).colorScheme;
    final toShow = upcomingReminders.take(3).toList();

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
              Icon(Icons.event_rounded, color: color.primary),
              const SizedBox(width: 8),
              Text(
                'Smart reminders',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Text(
                '$upcomingWithin7DaysCount in next 7 days',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: color.outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...toShow.map((r) => _ReminderRow(reminder: r)),
          if (upcomingReminders.length > 3) ...[
            const SizedBox(height: 6),
            Text(
              '+${upcomingReminders.length - 3} more upcoming reminders',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: color.outline),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  final Reminder reminder;

  const _ReminderRow({required this.reminder});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            _iconForTitle(reminder.title),
            size: 18,
            color: color.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  reminder.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: color.outline),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDate(reminder.dueDate),
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: color.primary),
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

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d/$m';
  }
}
