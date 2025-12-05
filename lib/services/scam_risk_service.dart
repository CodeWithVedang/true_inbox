import '../models/sms_category.dart';

class ScamRiskResult {
  final int score; // 0–100
  final List<String> reasons;

  const ScamRiskResult({
    required this.score,
    required this.reasons,
  });
}

/// Simple heuristic-based risk scoring engine.
/// Later you can replace this with an ML model.
class ScamRiskService {
  ScamRiskResult computeRisk({
    required SmsCategory category,
    required bool hasLink,
    required bool looksPhishy,
    required bool isRegisteredHeader,
    required String body,
  }) {
    int score = 0;
    final List<String> reasons = [];

    final lower = body.toLowerCase();

    // Base score from category
    switch (category) {
      case SmsCategory.malicious:
        score += 70;
        reasons.add('Message matches malicious / phishing patterns.');
        break;
      case SmsCategory.promotional:
        score += 30;
        reasons.add('Promotional / marketing message.');
        break;
      case SmsCategory.transactional:
        score += 10;
        reasons.add('Transactional / informational message.');
        break;
      case SmsCategory.otp:
        score += 15;
        reasons.add('Contains OTP or verification code.');
        break;
      case SmsCategory.genuine:
      case SmsCategory.all:
        score += 5;
        reasons.add('Likely personal / genuine message.');
        break;
    }

    // Links
    if (hasLink) {
      score += 10;
      reasons.add('Contains a clickable link.');
    }

    // Phishy wording
    if (looksPhishy) {
      score += 20;
      reasons.add('Contains urgent / phishing-style language (KYC, blocked, verify now, etc.).');
    }

    // Sensitive keywords
    if (_any(lower, ['kyc', 'aadhar', 'aadhaar', 'pan', 'netbanking', 'upi pin'])) {
      score += 10;
      reasons.add('Mentions sensitive identity / banking information.');
    }

    if (_any(lower, ['loan approved', 'instant loan', 'win', 'lottery', 'prize'])) {
      score += 10;
      reasons.add('Contains typical scam/loan/lottery keywords.');
    }

    // TRAI header trust
    if (!isRegisteredHeader && (hasLink || looksPhishy)) {
      score += 10;
      reasons.add('Sender not found in TRAI registered headers list.');
    } else if (isRegisteredHeader && category != SmsCategory.malicious) {
      score -= 10;
      reasons.add('Sender is TRAI-registered; slightly reduced risk.');
    }

    // Clamp to [0, 100]
    if (score < 0) score = 0;
    if (score > 100) score = 100;

    if (reasons.isEmpty) {
      reasons.add('No obvious risk indicators detected.');
    }

    return ScamRiskResult(score: score, reasons: reasons);
  }

  bool _any(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }
}
