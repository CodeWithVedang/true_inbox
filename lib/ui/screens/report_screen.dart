import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/sms_provider.dart';
import '../../services/report_service.dart';

class ReportScreen extends StatefulWidget {
  static const routeName = '/report';

  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late final String _reportText;

  @override
  void initState() {
    super.initState();
    final smsProvider = context.read<SmsProvider>();
    final reportService = ReportService();

    _reportText = reportService.buildReport(
      messages: smsProvider.allMessages,
      inboxRiskScore: smsProvider.inboxRiskScore,
      highRiskCount: smsProvider.highRiskCount,
      maliciousCount: smsProvider.maliciousCount,
      otpReport: smsProvider.otpAbuseReport,
      stressReport: smsProvider.stressReport,
      upcomingReminders: smsProvider.upcomingReminders,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export report'),
        actions: [
          IconButton(
            tooltip: 'Copy text',
            icon: const Icon(Icons.copy_rounded),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: _reportText));
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report copied to clipboard'),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: color.surfaceContainerHighest,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              _reportText,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
  