import 'package:flutter/material.dart';

enum SmsCategory {
  all,
  genuine,
  otp,
  transactional,
  promotional,
  malicious,
}

extension SmsCategoryX on SmsCategory {
  String get label {
    switch (this) {
      case SmsCategory.all:
        return 'All';
      case SmsCategory.genuine:
        return 'Genuine';
      case SmsCategory.otp:
        return 'OTP';
      case SmsCategory.transactional:
        return 'Transactional';
      case SmsCategory.promotional:
        return 'Promotional';
      case SmsCategory.malicious:
        return 'Malicious';
    }
  }

  IconData get icon {
    switch (this) {
      case SmsCategory.all:
        return Icons.inbox_rounded;
      case SmsCategory.genuine:
        return Icons.chat_bubble_rounded;
      case SmsCategory.otp:
        return Icons.lock_clock_rounded;
      case SmsCategory.transactional:
        return Icons.account_balance_wallet_rounded;
      case SmsCategory.promotional:
        return Icons.local_offer_rounded;
      case SmsCategory.malicious:
        return Icons.warning_amber_rounded;
    }
  }

  Color get color {
    switch (this) {
      case SmsCategory.all:
        return Colors.grey;
      case SmsCategory.genuine:
        return Colors.blue;
      case SmsCategory.otp:
        return Colors.indigo;
      case SmsCategory.transactional:
        return Colors.orange;
      case SmsCategory.promotional:
        return Colors.purple;
      case SmsCategory.malicious:
        return Colors.red;
    }
  }
}
