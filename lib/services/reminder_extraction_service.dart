import 'package:intl/intl.dart';

import '../models/sms_message.dart';
import '../models/sms_category.dart';
import '../models/reminder.dart';

class ReminderExtractionService {
  /// Extracts reminders from messages (mainly transactional).
  List<Reminder> extractReminders(List<SmsMessage> messages) {
    final List<Reminder> reminders = [];
    final now = DateTime.now();

    for (final msg in messages) {
      // Focus on transactional + some OTP / promotional messages
      if (msg.category != SmsCategory.transactional &&
          msg.category != SmsCategory.otp &&
          msg.category != SmsCategory.promotional) {
        continue;
      }

      final text = msg.body.toLowerCase();

      final parsedDate = _extractDate(text, baseDate: msg.timestamp);
      if (parsedDate == null) continue;
      if (parsedDate.isBefore(now.subtract(const Duration(days: 1)))) {
        // Ignore very old due dates
        continue;
      }

      final type = _inferType(text);
      final title = _titleForType(type);
      final description = _buildDescription(type, msg.body);

      final reminder = Reminder(
        id: '${msg.id}::$type',
        title: title,
        description: description,
        dueDate: parsedDate,
        fromMessageId: msg.id,
      );

      reminders.add(reminder);
    }

    // Remove duplicates by id
    final Map<String, Reminder> unique = {
      for (final r in reminders) r.id: r,
    };

    return unique.values.toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  /// Tries to infer reminder type by keywords.
  String _inferType(String text) {
    if (_any(text, ['bill', 'due', 'payment'])) {
      return 'bill';
    }
    if (_any(text, ['delivery', 'arriving', 'shipped', 'expected'])) {
      return 'delivery';
    }
    if (_any(text, ['appointment', 'meeting', 'doctor', 'reservation'])) {
      return 'appointment';
    }
    if (_any(text, ['flight', 'train', 'bus', 'boarding', 'departure'])) {
      return 'travel';
    }
    return 'generic';
  }

  String _titleForType(String type) {
    switch (type) {
      case 'bill':
        return 'Bill / payment due';
      case 'delivery':
        return 'Delivery expected';
      case 'appointment':
        return 'Appointment / meeting';
      case 'travel':
        return 'Travel / ticket';
      default:
        return 'Reminder';
    }
  }

  String _buildDescription(String type, String originalBody) {
    // Keep it simple: first line / truncated text
    final firstLine = originalBody.split('\n').first.trim();
    if (firstLine.length > 120) {
      return '${firstLine.substring(0, 117)}...';
    }
    return firstLine;
  }

  bool _any(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }

  /// Extracts a date from the text using multiple simple patterns.
  DateTime? _extractDate(String text, {required DateTime baseDate}) {
    // Common formats: dd/mm/yyyy, dd-mm-yyyy, dd/mm, dd-mm
    final dateRegex = RegExp(
      r'\b(\d{1,2})[\/-](\d{1,2})(?:[\/-](\d{2,4}))?\b',
    );

    final match = dateRegex.firstMatch(text);
    if (match != null) {
      try {
        final day = int.parse(match.group(1)!);
        final month = int.parse(match.group(2)!);
        String? yearStr = match.group(3);

        int year;
        if (yearStr == null) {
          // If no year, assume current year or next year if date already passed
          year = baseDate.year;
          final tentative =
              DateTime(year, month, day, baseDate.hour, baseDate.minute);
          if (tentative.isBefore(baseDate)) {
            year = baseDate.year + 1;
          }
        } else {
          year = int.parse(yearStr);
          if (year < 100) {
            year += 2000;
          }
        }

        return DateTime(year, month, day, 9); // 9 AM default time
      } catch (_) {
        // fallback below
      }
    }

    // Relative date phrases
    if (text.contains('tomorrow')) {
      return DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day + 1,
        9,
      );
    }
    if (text.contains('day after tomorrow')) {
      return DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day + 2,
        9,
      );
    }

    // Try to catch "on 20th Jan" style (very basic)
    final shortMonthRegex = RegExp(
      r'on (\d{1,2})(st|nd|rd|th)?\s+(jan|feb|mar|apr|may|jun|jul|aug|sep|sept|oct|nov|dec)',
    );
    final m2 = shortMonthRegex.firstMatch(text);
    if (m2 != null) {
      try {
        final day = int.parse(m2.group(1)!);
        final monthStr = m2.group(3)!;
        final month = _monthFromShortName(monthStr);
        int year = baseDate.year;
        final tentative =
            DateTime(year, month, day, baseDate.hour, baseDate.minute);
        if (tentative.isBefore(baseDate)) {
          year = baseDate.year + 1;
        }
        return DateTime(year, month, day, 9);
      } catch (_) {
        // ignore
      }
    }

    return null;
  }

  int _monthFromShortName(String shortName) {
    final m = shortName.toLowerCase();
    switch (m) {
      case 'jan':
        return 1;
      case 'feb':
        return 2;
      case 'mar':
        return 3;
      case 'apr':
        return 4;
      case 'may':
        return 5;
      case 'jun':
        return 6;
      case 'jul':
        return 7;
      case 'aug':
        return 8;
      case 'sep':
      case 'sept':
        return 9;
      case 'oct':
        return 10;
      case 'nov':
        return 11;
      case 'dec':
        return 12;
      default:
        return DateTime.now().month;
    }
  }
}
