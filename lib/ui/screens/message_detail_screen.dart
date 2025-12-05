import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/sms_message.dart';
import '../../models/sms_category.dart';

class MessageDetailScreen extends StatelessWidget {
  static const routeName = '/message-detail';

  final SmsMessage message;

  const MessageDetailScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final otpCode = _extractOtp(message.body);
    final hasOtp =
        message.category == SmsCategory.otp || otpCode != null;
    final hasLink =
        message.hasSuspiciousLink || _containsAnyUrl(message.body);
    final isUnregistered = !message.isRegisteredHeader;

    final isHighRisk = message.riskScore >= 70 ||
        message.category == SmsCategory.malicious ||
        message.hasSuspiciousLink;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Message details'),
        centerTitle: false,
      ),
      bottomNavigationBar: isHighRisk
          ? _RiskActionBar(
              message: message,
            )
          : null,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // Header card: sender + chips
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.surface,
                borderRadius: BorderRadius.circular(18),
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
                  // Sender row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            color.primary.withOpacity(0.12),
                        child: Icon(
                          Icons.sms_rounded,
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
                              message.sender.isEmpty
                                  ? 'Unknown sender'
                                  : message.sender,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _longDateTimeSafe(
                                  message.timestamp),
                              style:
                                  textTheme.bodySmall?.copyWith(
                                color: color.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _chip(
                        icon: message.category.icon,
                        label: message.category.label,
                        color: message.category.color,
                      ),
                      _riskChip(message.riskScore, color),
                      if (hasOtp)
                        _chip(
                          icon: Icons.lock_clock_rounded,
                          label: 'OTP',
                          color: color.primary,
                        ),
                      if (hasLink)
                        _chip(
                          icon: Icons.link_rounded,
                          label: message.hasSuspiciousLink
                              ? 'Suspicious link'
                              : 'Link detected',
                          color: message.hasSuspiciousLink
                              ? color.error
                              : color.tertiary,
                        ),
                      if (isUnregistered)
                        _chip(
                          icon: Icons.verified_user_outlined,
                          label: 'Unregistered header',
                          color: color.error,
                        ),
                      InkWell(
                        borderRadius:
                            BorderRadius.circular(999),
                        onTap: () =>
                            _showRiskExplanation(context, message),
                        child: _chip(
                          icon: Icons.info_outline_rounded,
                          label: 'Why this score?',
                          color: color.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Message body
            Text(
              'Message',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                message.body.trim(),
                style: textTheme.bodyMedium,
              ),
            ),

            // OTP block with real copy
            if (hasOtp && otpCode != null) ...[
              const SizedBox(height: 16),
              Text(
                'Detected OTP',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: color.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_rounded,
                        color: color.primary),
                    const SizedBox(width: 10),
                    Text(
                      otpCode,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded),
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: otpCode),
                        );
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text('OTP copied'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _riskChip(int score, ColorScheme scheme) {
    String label;
    if (score >= 70) {
      label = 'High risk';
    } else if (score >= 40) {
      label = 'Medium risk';
    } else {
      label = 'Low risk';
    }
    final color = _riskColor(score, scheme);
    return _chip(
      icon: Icons.shield_rounded,
      label: '$label ($score)',
      color: color,
    );
  }

  Color _riskColor(int score, ColorScheme scheme) {
    if (score >= 70) return scheme.error;
    if (score >= 40) return scheme.tertiary;
    return scheme.primary;
  }

  String _longDateTimeSafe(DateTime dt) {
    try {
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      final yyyy = dt.year;
      final hh = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$dd/$mm/$yyyy • $hh:$min';
    } catch (_) {
      return '';
    }
  }

  void _showRiskExplanation(BuildContext context, SmsMessage msg) {
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final reasons = <String>[];

    if (msg.category == SmsCategory.malicious) {
      reasons.add('Categorised as malicious based on strong scam patterns.');
    }
    if (!msg.isRegisteredHeader) {
      reasons.add(
          'Sender does not match registered TRAI header list (possible spoofing).');
    }
    if (msg.hasSuspiciousLink) {
      reasons.add(
          'Contains suspicious-looking link (shortener / random domain pattern).');
    } else if (_containsAnyUrl(msg.body)) {
      reasons.add('Contains at least one URL in the body.');
    }
    if (msg.category == SmsCategory.promotional) {
      reasons.add('Detected as promotional/marketing content.');
    }
    if (reasons.isEmpty) {
      reasons.add(
          'Score is low; message looks similar to known safe transactional or personal SMS.');
    }

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding:
              const EdgeInsets.fromLTRB(16, 12, 16, 16 + 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Why this risk score?',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This message was scored ${msg.riskScore}/100 based on:',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              ...reasons.map(
                (r) => Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 2),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 16, color: color.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          r,
                          style: textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Note: This is a heuristic score based only on SMS content and sender patterns. '
                'It is meant to assist you, not replace your judgement.',
                style: textTheme.bodySmall?.copyWith(
                  color: color.outline,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------- Helpers for OTP & URL detection ----------

String? _extractOtp(String body) {
  final lower = body.toLowerCase();
  final hasOtpKeyword = [
    'otp',
    'one time password',
    'verification code',
    'use this code',
    'login code',
  ].any(lower.contains);

  if (!hasOtpKeyword) return null;

  final reg = RegExp(r'\b(\d{4,8})\b');
  final match = reg.firstMatch(body);
  if (match != null) {
    return match.group(1);
  }
  return null;
}

bool _containsAnyUrl(String body) {
  final urlReg = RegExp(
    r'(https?:\/\/\S+|www\.\S+)',
    caseSensitive: false,
  );
  return urlReg.hasMatch(body);
}

// ---------- Bottom action bar (informational only) ----------

class _RiskActionBar extends StatelessWidget {
  final SmsMessage message;

  const _RiskActionBar({required this.message});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.surface,
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, -2),
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark as safe'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Use your judgement to decide if this looks safe. This prototype does not change server data.',
                      ),
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.delete_forever_rounded),
                style: FilledButton.styleFrom(
                  backgroundColor: color.error,
                ),
                label: const Text('Delete SMS'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Deleting SMS requires platform-level implementation and is not enabled in this build.',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
