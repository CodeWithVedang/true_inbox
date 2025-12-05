import 'dart:async';

import 'package:another_telephony/telephony.dart' as telephony;

import '../models/sms_message.dart';
import 'classification_service.dart';

class SmsService {
  final telephony.Telephony _telephony = telephony.Telephony.instance;
  final ClassificationService _classifier = ClassificationService();

  bool _isListening = false;

  /// Limit messages to avoid huge processing and lag
  static const int _maxMessages = 300;

  /// Ask for phone + SMS permissions.
  Future<bool> requestPermission() async {
    final granted =
        await _telephony.requestPhoneAndSmsPermissions ?? false;
    return granted;
  }

  /// Fetch inbox messages from the device.
  /// Assumes permission is already granted.
  Future<List<SmsMessage>> fetchSmsMessages() async {
    try {
      final List<telephony.SmsMessage> rawMessages =
          await _telephony.getInboxSms(
        columns: [
          telephony.SmsColumn.ADDRESS,
          telephony.SmsColumn.BODY,
          telephony.SmsColumn.DATE,
          telephony.SmsColumn.ID,
        ],
        sortOrder: [
          telephony.OrderBy(
            telephony.SmsColumn.DATE,
            sort: telephony.Sort.DESC,
          ),
        ],
      );

      final limited = rawMessages.take(_maxMessages).toList();

      final List<SmsMessage> result = [];

      for (final sms in limited) {
        final sender = sms.address ?? 'Unknown';
        final body = sms.body ?? '';
        if (body.trim().isEmpty) continue;

        final dateMillis =
            sms.date ?? DateTime.now().millisecondsSinceEpoch;
        final timestamp =
            DateTime.fromMillisecondsSinceEpoch(dateMillis);

        final classified = _classifier.classifyRaw(
          id: (sms.id ?? timestamp.millisecondsSinceEpoch).toString(),
          sender: sender,
          body: body,
          timestamp: timestamp,
        );
        result.add(classified);
      }

      return result;
    } catch (_) {
      return [];
    }
  }

  /// Listen to new incoming SMS while app is in foreground.
  /// Assumes permission is already granted.
  Future<void> listenIncoming(
    void Function(SmsMessage) onNewMessage,
  ) async {
    if (_isListening) return;
    _isListening = true;

    try {
      _telephony.listenIncomingSms(
        listenInBackground: false,
        onNewMessage: (telephony.SmsMessage sms) {
          final sender = sms.address ?? 'Unknown';
          final body = sms.body ?? '';
          if (body.trim().isEmpty) return;

          final dateMillis =
              sms.date ?? DateTime.now().millisecondsSinceEpoch;
          final timestamp =
              DateTime.fromMillisecondsSinceEpoch(dateMillis);

          final classified = _classifier.classifyRaw(
            id: (sms.id ?? timestamp.millisecondsSinceEpoch).toString(),
            sender: sender,
            body: body,
            timestamp: timestamp,
          );

          onNewMessage(classified);
        },
      );
    } catch (_) {
      _isListening = false;
    }
  }
}
