import 'package:flutter/foundation.dart';

import '../models/sms_message.dart';
import '../models/sms_category.dart';
import '../models/reminder.dart';
import '../services/sms_service.dart';
import '../services/otp_abuse_service.dart';
import '../services/reminder_extraction_service.dart';
import '../services/financial_stress_service.dart';

enum SmsPermissionStatus { unknown, granted, denied }

class SmsProvider extends ChangeNotifier {
  final SmsService _service = SmsService();
  final OtpAbuseService _otpAbuseService = OtpAbuseService();
  final ReminderExtractionService _reminderService =
      ReminderExtractionService();
  final FinancialStressService _stressService = FinancialStressService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<SmsMessage> _allMessages = [];
  List<SmsMessage> get allMessages => _allMessages;

  SmsCategory _selectedCategory = SmsCategory.all;
  SmsCategory get selectedCategory => _selectedCategory;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  SmsPermissionStatus _permissionStatus = SmsPermissionStatus.unknown;
  SmsPermissionStatus get permissionStatus => _permissionStatus;

  bool _initialized = false;

  OtpAbuseReport _otpAbuseReport = OtpAbuseReport.empty;
  OtpAbuseReport get otpAbuseReport => _otpAbuseReport;

  List<Reminder> _reminders = [];
  List<Reminder> get reminders => _reminders;

  FinancialStressReport _stressReport = FinancialStressReport.empty;
  FinancialStressReport get stressReport => _stressReport;

  /// Only future reminders, sorted by due date
  List<Reminder> get upcomingReminders {
    final now = DateTime.now();
    return _reminders
        .where((r) => r.dueDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  /// Count of reminders within the next 7 days
  int get upcomingWithin7DaysCount {
    final now = DateTime.now();
    final limit = now.add(const Duration(days: 7));
    return upcomingReminders
        .where((r) => r.dueDate.isBefore(limit))
        .length;
  }

  /// Initialize: ask permission, load inbox, start listener
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _isLoading = true;
    notifyListeners();

    final granted = await _service.requestPermission();
    _permissionStatus =
        granted ? SmsPermissionStatus.granted : SmsPermissionStatus.denied;
    notifyListeners();

    if (granted) {
      await _loadMessagesInternal();
      _service.listenIncoming(_handleIncomingMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> retryPermission() async {
    _initialized = false;
    await init();
  }

  Future<void> _loadMessagesInternal() async {
    _allMessages = await _service.fetchSmsMessages();
    _recomputeDerived();
  }

  Future<void> loadMessages() async {
    if (_permissionStatus != SmsPermissionStatus.granted) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _loadMessagesInternal();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handleIncomingMessage(SmsMessage msg) {
    _allMessages.insert(0, msg);
    if (_allMessages.length > 400) {
      _allMessages = _allMessages.sublist(0, 400);
    }
    _recomputeDerived();
    notifyListeners();
  }

  void _recomputeDerived() {
    _otpAbuseReport = _otpAbuseService.analyze(_allMessages);
    _reminders = _reminderService.extractReminders(_allMessages);
    _stressReport = _stressService.analyze(_allMessages);
  }

  void setCategory(SmsCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<SmsMessage> get filteredMessages {
    Iterable<SmsMessage> msgs = _allMessages;

    if (_selectedCategory != SmsCategory.all) {
      msgs = msgs.where((m) => m.category == _selectedCategory);
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      msgs = msgs.where(
        (m) =>
            m.sender.toLowerCase().contains(q) ||
            m.body.toLowerCase().contains(q),
      );
    }

    return msgs.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  int get maliciousCount =>
      _allMessages.where((m) => m.category == SmsCategory.malicious).length;

  int get otpTodayCount =>
      _allMessages.where((m) =>
              m.category == SmsCategory.otp &&
              m.timestamp.day == DateTime.now().day &&
              m.timestamp.month == DateTime.now().month &&
              m.timestamp.year == DateTime.now().year)
          .length;

  /// Number of messages with high risk (>= 70)
  int get highRiskCount =>
      _allMessages.where((m) => m.riskScore >= 70).length;

  /// Average inbox risk score (0–100)
  int get inboxRiskScore {
    if (_allMessages.isEmpty) return 0;
    final total =
        _allMessages.fold<int>(0, (sum, m) => sum + m.riskScore);
    return (total / _allMessages.length).round();
  }
}
