import 'sms_category.dart';

class SmsMessage {
  final String id;
  final String sender;
  final String body;
  final DateTime timestamp;
  final SmsCategory category;
  final bool hasSuspiciousLink;
  final bool isRead;

  /// TRAI header (e.g. from VM-ICICIB -> "ICICIB")
  final String? traiHeader;

  /// True if this header exists in TRAI dataset
  final bool isRegisteredHeader;

  /// Principal Entity Name from TRAI sheet
  final String? principalEntityName;

  /// Scam risk score (0–100)
  final int riskScore;

  /// Reasons contributing to risk score
  final List<String> riskReasons;

  SmsMessage({
    required this.id,
    required this.sender,
    required this.body,
    required this.timestamp,
    required this.category,
    this.hasSuspiciousLink = false,
    this.isRead = true,
    this.traiHeader,
    this.isRegisteredHeader = false,
    this.principalEntityName,
    this.riskScore = 0,
    this.riskReasons = const [],
  });

  SmsMessage copyWith({
    String? id,
    String? sender,
    String? body,
    DateTime? timestamp,
    SmsCategory? category,
    bool? hasSuspiciousLink,
    bool? isRead,
    String? traiHeader,
    bool? isRegisteredHeader,
    String? principalEntityName,
    int? riskScore,
    List<String>? riskReasons,
  }) {
    return SmsMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      hasSuspiciousLink: hasSuspiciousLink ?? this.hasSuspiciousLink,
      isRead: isRead ?? this.isRead,
      traiHeader: traiHeader ?? this.traiHeader,
      isRegisteredHeader: isRegisteredHeader ?? this.isRegisteredHeader,
      principalEntityName: principalEntityName ?? this.principalEntityName,
      riskScore: riskScore ?? this.riskScore,
      riskReasons: riskReasons ?? this.riskReasons,
    );
  }
}
