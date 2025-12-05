import 'package:flutter/material.dart';

import '../../models/sms_message.dart';
import '../../models/sms_category.dart';
import '../screens/message_detail_screen.dart';

class MessageCard extends StatelessWidget {
  final SmsMessage message;

  const MessageCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final sender =
        message.sender.isEmpty ? 'Unknown sender' : message.sender;
    final snippet = message.body.trim().isEmpty
        ? '(empty message)'
        : message.body.trim();

    final timeText = _shortTimeSafe(message.timestamp);
    final riskColor = _riskColor(message.riskScore, colorScheme);

    final isMaliciousCategory =
        message.category == SmsCategory.malicious;
    final isHighRisk = message.riskScore >= 70;
    final hasSuspiciousLink = message.hasSuspiciousLink;

    return Card(
      elevation: 1.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MessageDetailScreen(message: message),
            ),
          );
        },
        child: Stack(
          children: [
            // Risk-colored strip on the left
            Positioned.fill(
              left: 0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: riskColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.only(
                    left: 4,
                    right: 4,
                    top: 4,
                    bottom: 4,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: riskColor.withOpacity(0.15),
                    child: Icon(
                      message.category == SmsCategory.otp
                          ? Icons.lock_rounded
                          : message.category == SmsCategory.malicious
                              ? Icons.warning_amber_rounded
                              : Icons.sms_rounded,
                      color: riskColor,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          sender,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeText,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        snippet,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 2,
                        children: [
                          _smallChip(
                            context,
                            label: message.category.label,
                            color:
                                message.category == SmsCategory.malicious
                                    ? colorScheme.error
                                    : message.category ==
                                            SmsCategory.otp
                                        ? colorScheme.primary
                                        : colorScheme.tertiary,
                          ),
                          _smallChip(
                            context,
                            label: _riskLabel(message.riskScore),
                            color: riskColor,
                          ),
                          if (isMaliciousCategory || isHighRisk)
                            _iconChip(
                              context,
                              icon: Icons.warning_amber_rounded,
                              label: 'Malicious / high risk',
                              color: colorScheme.error,
                            ),
                          if (hasSuspiciousLink)
                            _iconChip(
                              context,
                              icon: Icons.link_rounded,
                              label: 'Suspicious link',
                              color: colorScheme.error,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortTimeSafe(DateTime dt) {
    try {
      final now = DateTime.now();
      final sameDay = dt.year == now.year &&
          dt.month == now.month &&
          dt.day == now.day;

      if (sameDay) {
        final hh = dt.hour.toString().padLeft(2, '0');
        final mm = dt.minute.toString().padLeft(2, '0');
        return '$hh:$mm';
      }
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      return '$dd/$mm';
    } catch (_) {
      return '';
    }
  }

  Color _riskColor(int score, ColorScheme scheme) {
    if (score >= 70) return scheme.error;
    if (score >= 40) return scheme.tertiary;
    return scheme.primary;
  }

  String _riskLabel(int score) {
    if (score >= 70) return 'High risk';
    if (score >= 40) return 'Medium risk';
    return 'Low risk';
  }

  Widget _smallChip(
    BuildContext context, {
    required String label,
    required Color color,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: color,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _iconChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
