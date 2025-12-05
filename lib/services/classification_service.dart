import '../models/sms_category.dart';
import '../models/sms_message.dart';
import 'trai_header_service.dart';
import 'scam_risk_service.dart';

class ClassificationService {
  final ScamRiskService _riskService = ScamRiskService();

  SmsMessage classifyRaw({
    required String id,
    required String sender,
    required String body,
    required DateTime timestamp,
  }) {
    final text = body.toLowerCase();

    final bool isOtp = RegExp(r'\b(\d{4,8})\b').hasMatch(text) &&
        (text.contains('otp') || text.contains('one time password'));

    final bool isTransactional = _any(text, [
      'debited',
      'credited',
      'rs.',
      'transaction',
      'txn',
      'order',
      'delivered',
      'invoice',
      'payment',
    ]);

    final bool isPromo = _any(text, [
      'offer',
      'sale',
      'discount',
      'cashback',
      'limited time',
      'buy now',
      'deal',
    ]);

    final bool looksPhishy = _any(text, [
      'update your kyc',
      'blocked',
      'suspended',
      'click the link',
      'verify immediately',
      'your account will be closed',
      'urgent action required',
    ]);

    final bool hasLink = RegExp(r'https?://\S+').hasMatch(text) ||
        RegExp(r'www\.\S+').hasMatch(text);

    SmsCategory category = SmsCategory.genuine;

    if (looksPhishy && hasLink) {
      category = SmsCategory.malicious;
    } else if (isOtp) {
      category = SmsCategory.otp;
    } else if (isTransactional) {
      category = SmsCategory.transactional;
    } else if (isPromo) {
      category = SmsCategory.promotional;
    } else {
      category = SmsCategory.genuine;
    }

    // === TRAI header handling ===
    final String? header = _extractHeaderFromSender(sender);
    final String? principalEntity =
        TraiHeaderService.instance.lookupPrincipalEntity(header);
    final bool isRegistered = principalEntity != null;

    // === Scam risk scoring ===
    final risk = _riskService.computeRisk(
      category: category,
      hasLink: hasLink,
      looksPhishy: looksPhishy,
      isRegisteredHeader: isRegistered,
      body: body,
    );

    return SmsMessage(
      id: id,
      sender: sender,
      body: body,
      timestamp: timestamp,
      category: category,
      hasSuspiciousLink: category == SmsCategory.malicious && hasLink,
      traiHeader: header,
      isRegisteredHeader: isRegistered,
      principalEntityName: principalEntity,
      riskScore: risk.score,
      riskReasons: risk.reasons,
    );
  }

  bool _any(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }

  /// Try to extract TRAI-style header from sender like "VM-ICICIB"
  String? _extractHeaderFromSender(String sender) {
    if (sender.isEmpty) return null;
    String cleaned = sender.trim().toUpperCase();

    if (cleaned.startsWith('+')) {
      // mobile number, not header
      return null;
    }

    if (cleaned.contains('-')) {
      final parts = cleaned.split('-');
      final last = parts.last.trim();
      if (last.length >= 3 && last.length <= 11) {
        return last;
      }
    }

    if (cleaned.length >= 3 && cleaned.length <= 11) {
      final isNumeric = RegExp(r'^\d+$').hasMatch(cleaned);
      if (!isNumeric || cleaned.length <= 6) {
        return cleaned;
      }
    }

    return null;
  }
}
