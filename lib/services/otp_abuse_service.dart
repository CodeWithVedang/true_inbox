import '../models/sms_message.dart';
import '../models/sms_category.dart';

class OtpAbuseReport {
  final bool isSuspicious;
  final int otpLast24h;
  final int otpLastHour;
  final int burstMaxIn5Min;
  final String explanation;

  const OtpAbuseReport({
    required this.isSuspicious,
    required this.otpLast24h,
    required this.otpLastHour,
    required this.burstMaxIn5Min,
    required this.explanation,
  });

  static const empty = OtpAbuseReport(
    isSuspicious: false,
    otpLast24h: 0,
    otpLastHour: 0,
    burstMaxIn5Min: 0,
    explanation: 'No OTP anomaly detected.',
  );
}

/// Analyses OTP patterns to detect unusual activity that may indicate
/// identity misuse (e.g., many OTP requests in short time).
class OtpAbuseService {
  OtpAbuseReport analyze(List<SmsMessage> messages) {
    final now = DateTime.now();
    final otpMessages = messages
        .where((m) => m.category == SmsCategory.otp)
        .toList();

    if (otpMessages.isEmpty) {
      return OtpAbuseReport.empty;
    }

    final last24hCutoff = now.subtract(const Duration(hours: 24));
    final last1hCutoff = now.subtract(const Duration(hours: 1));

    final otpLast24h = otpMessages
        .where((m) => m.timestamp.isAfter(last24hCutoff))
        .length;

    final otpLastHour = otpMessages
        .where((m) => m.timestamp.isAfter(last1hCutoff))
        .length;

    // Sort by time to detect bursts
    otpMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    int maxIn5Min = 0;
    int left = 0;

    for (int right = 0; right < otpMessages.length; right++) {
      final rightTime = otpMessages[right].timestamp;
      while (left < right &&
          rightTime
                  .difference(otpMessages[left].timestamp)
                  .inMinutes >
              5) {
        left++;
      }
      final windowCount = right - left + 1;
      if (windowCount > maxIn5Min) {
        maxIn5Min = windowCount;
      }
    }

    bool suspicious = false;
    final reasons = <String>[];

    // Simple thresholds – you can tune these later.
    if (otpLast24h >= 10) {
      suspicious = true;
      reasons.add(
          'More than 10 OTP messages received in the last 24 hours.');
    }
    if (otpLastHour >= 5) {
      suspicious = true;
      reasons.add(
          'More than 5 OTP messages received in the last hour.');
    }
    if (maxIn5Min >= 3) {
      suspicious = true;
      reasons.add(
          'At least 3 OTP messages received within a 5-minute window.');
    }

    if (!suspicious) {
      reasons.add('OTP activity is within a normal range.');
    }

    final explanation = reasons.join(' ');

    return OtpAbuseReport(
      isSuspicious: suspicious,
      otpLast24h: otpLast24h,
      otpLastHour: otpLastHour,
      burstMaxIn5Min: maxIn5Min,
      explanation: explanation,
    );
  }
}
