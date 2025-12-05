import '../models/sms_message.dart';
import '../models/sms_category.dart';

class FinancialStressReport {
  final int score; // 0–100
  final int emiCountLast30d;
  final int overdueCount;
  final int penaltyCount;
  final int loanOfferCount;
  final String explanation;
  final bool isHighStress;

  const FinancialStressReport({
    required this.score,
    required this.emiCountLast30d,
    required this.overdueCount,
    required this.penaltyCount,
    required this.loanOfferCount,
    required this.explanation,
    required this.isHighStress,
  });

  static const empty = FinancialStressReport(
    score: 0,
    emiCountLast30d: 0,
    overdueCount: 0,
    penaltyCount: 0,
    loanOfferCount: 0,
    explanation: 'No financial stress signals detected from SMS.',
    isHighStress: false,
  );
}

/// Analyzes SMS to estimate financial stress based on EMIs, overdue bills, penalties,
/// and aggressive loan/credit offers.
class FinancialStressService {
  FinancialStressReport analyze(List<SmsMessage> messages) {
    if (messages.isEmpty) return FinancialStressReport.empty;

    final now = DateTime.now();
    final last30dCutoff = now.subtract(const Duration(days: 30));

    int emiCount = 0;
    int overdueCount = 0;
    int penaltyCount = 0;
    int loanOfferCount = 0;

    for (final m in messages) {
      if (m.timestamp.isBefore(last30dCutoff)) continue;

      final text = m.body.toLowerCase();

      // Only consider transactional & promotional messages for finance
      if (m.category != SmsCategory.transactional &&
          m.category != SmsCategory.promotional) {
        continue;
      }

      if (_any(text, ['emi', 'equated monthly instal', 'auto debit'])) {
        emiCount++;
      }
      if (_any(text, [
        'overdue',
        'past due',
        'due date has passed',
        'payment due immediately',
      ])) {
        overdueCount++;
      }
      if (_any(text, ['penalty', 'late fee', 'bounce charge'])) {
        penaltyCount++;
      }
      if (_any(text, [
        'instant loan',
        'personal loan',
        'pre-approved loan',
        'no cibil',
        'no credit check',
        'increase your credit limit',
      ])) {
        loanOfferCount++;
      }
    }

    // Compute a stress score (heuristic)
    int score = 0;
    final reasons = <String>[];

    if (emiCount > 0) {
      score += (emiCount * 5).clamp(5, 25);
      reasons.add('You have $emiCount EMI or scheduled payment messages in the last 30 days.');
    }

    if (overdueCount > 0) {
      score += (overdueCount * 15).clamp(10, 40);
      reasons.add('$overdueCount message(s) indicate overdue or past-due payments.');
    }

    if (penaltyCount > 0) {
      score += (penaltyCount * 12).clamp(10, 30);
      reasons.add('$penaltyCount message(s) mention penalties or late fees.');
    }

    if (loanOfferCount > 0) {
      score += (loanOfferCount * 4).clamp(4, 16);
      reasons.add(
          'Received $loanOfferCount loan/credit promotional message(s) in the last 30 days.');
    }

    if (reasons.isEmpty) {
      reasons.add('No EMI, overdue, penalty or loan-offer patterns detected.');
    }

    if (score > 100) score = 100;
    if (score < 0) score = 0;

    // Define high stress threshold
    final isHigh = score >= 60;

    final explanation = reasons.join(' ');

    return FinancialStressReport(
      score: score,
      emiCountLast30d: emiCount,
      overdueCount: overdueCount,
      penaltyCount: penaltyCount,
      loanOfferCount: loanOfferCount,
      explanation: explanation,
      isHighStress: isHigh,
    );
  }

  bool _any(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }
}
