import 'package:intl/intl.dart';

import '../models/sms_message.dart';
import '../models/sms_category.dart';
import 'otp_abuse_service.dart';
import 'financial_stress_service.dart';
import '../models/reminder.dart';

class ReportService {
  String buildReport({
    required List<SmsMessage> messages,
    required int inboxRiskScore,
    required int highRiskCount,
    required int maliciousCount,
    required OtpAbuseReport otpReport,
    required FinancialStressReport stressReport,
    required List<Reminder> upcomingReminders,
  }) {
    final buffer = StringBuffer();
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(now);

    final total = messages.length;

    buffer.writeln('TrueInbox – Security & Inbox Report');
    buffer.writeln('Generated on: $dateStr');
    buffer.writeln('======================================');
    buffer.writeln();
    buffer.writeln('1. Summary');
    buffer.writeln('--------------------------------------');
    buffer.writeln('Total SMS analysed           : $total');
    buffer.writeln('Inbox risk score             : $inboxRiskScore / 100');
    buffer.writeln('High-risk SMS (score ≥ 70)   : $highRiskCount');
    buffer.writeln('Malicious / phishing SMS     : $maliciousCount');
    buffer.writeln(
        'Financial stress score       : ${stressReport.score} / 100 (${stressReport.isHighStress ? 'HIGH' : 'OK'})');
    buffer.writeln(
        'Unusual OTP activity         : ${otpReport.isSuspicious ? 'YES' : 'NO'}');
    buffer.writeln(
        'Upcoming reminders (future)  : ${upcomingReminders.length}');
    buffer.writeln();

    buffer.writeln('2. Risk overview');
    buffer.writeln('--------------------------------------');
    buffer.writeln('High-risk messages examples (top 5):');
    final topRisk = List<SmsMessage>.from(messages)
      ..sort((a, b) => b.riskScore.compareTo(a.riskScore));
    final top5 = topRisk.where((m) => m.riskScore >= 60).take(5).toList();
    if (top5.isEmpty) {
      buffer.writeln('  - No high-risk messages detected.');
    } else {
      for (final m in top5) {
        buffer.writeln(
            '  - [${m.riskScore}/100] ${_shortDateTime(m.timestamp)} | ${m.sender}');
        buffer.writeln('    "${_firstLine(m.body)}"');
      }
    }
    buffer.writeln();

    buffer.writeln('3. Financial signals (last 30 days)');
    buffer.writeln('--------------------------------------');
    buffer.writeln('Financial stress explanation:');
    buffer.writeln('  ${stressReport.explanation}');
    buffer.writeln();
    buffer.writeln(
        'EMI / bill related messages : ${stressReport.emiCountLast30d}');
    buffer.writeln('Overdue payment messages     : ${stressReport.overdueCount}');
    buffer.writeln('Penalty / late fee messages  : ${stressReport.penaltyCount}');
    buffer.writeln('Loan / credit offers         : ${stressReport.loanOfferCount}');
    buffer.writeln();

    buffer.writeln('4. OTP behaviour');
    buffer.writeln('--------------------------------------');
    buffer.writeln('Unusual OTP activity: '
        '${otpReport.isSuspicious ? 'YES – investigate your accounts' : 'No obvious anomaly'}');
    buffer.writeln('  OTP last 1 hour          : ${otpReport.otpLastHour}');
    buffer.writeln('  OTP last 24 hours        : ${otpReport.otpLast24h}');
    buffer.writeln(
        '  Max OTPs in 5-minute span: ${otpReport.burstMaxIn5Min}');
    buffer.writeln('Details:');
    buffer.writeln('  ${otpReport.explanation}');
    buffer.writeln();

    buffer.writeln('5. Upcoming reminders from SMS');
    buffer.writeln('--------------------------------------');
    if (upcomingReminders.isEmpty) {
      buffer.writeln('No future bill / delivery / appointment reminders found.');
    } else {
      final sortedReminders = List<Reminder>.from(upcomingReminders)
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      for (final r in sortedReminders.take(10)) {
        buffer.writeln(
            '- ${_shortDate(r.dueDate)} | ${r.title} – ${_firstLine(r.description)}');
      }
      if (upcomingReminders.length > 10) {
        buffer.writeln(
            '... and ${upcomingReminders.length - 10} more reminders.');
      }
    }
    buffer.writeln();

    buffer.writeln('6. Category distribution snapshot');
    buffer.writeln('--------------------------------------');
    final counts = _categoryCounts(messages);
    if (total == 0) {
      buffer.writeln('No messages to compute distribution.');
    } else {
      for (final entry in counts.entries) {
        final pct = ((entry.value / total) * 100).round();
        buffer.writeln(
            '- ${entry.key.label.padRight(15)} : ${entry.value.toString().padLeft(4)}  (${pct.toString().padLeft(3)}%)');
      }
    }
    buffer.writeln();

    buffer.writeln('End of report.');
    buffer.writeln('======================================');

    return buffer.toString();
  }

  Map<SmsCategory, int> _categoryCounts(List<SmsMessage> messages) {
    final map = <SmsCategory, int>{
      for (final c in SmsCategory.values) c: 0,
    };
    for (final m in messages) {
      map[m.category] = (map[m.category] ?? 0) + 1;
    }
    return map;
  }

  String _shortDateTime(DateTime dt) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  String _shortDate(DateTime dt) {
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  String _firstLine(String body) {
    final first = body.split('\n').first.trim();
    if (first.length > 80) {
      return '${first.substring(0, 77)}...';
    }
    return first;
  }
}
