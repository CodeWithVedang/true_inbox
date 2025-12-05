import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Loads TRAI header → Principal Entity mappings from JSON
class TraiHeaderService {
  TraiHeaderService._internal();
  static final TraiHeaderService instance = TraiHeaderService._internal();

  Map<String, String> _headerToEntity = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  Future<void> loadHeaders() async {
    if (_loaded) return;

    try {
      final jsonStr =
          await rootBundle.loadString('assets/data/trai_headers.json');
      final Map<String, dynamic> data = json.decode(jsonStr);

      _headerToEntity = data.map(
        (key, value) => MapEntry(
          key.toString().trim().toUpperCase(),
          value.toString(),
        ),
      );

      _loaded = true;
    } catch (_) {
      _headerToEntity = {};
      _loaded = false;
    }
  }

  /// Returns Principal Entity Name if header exists, else null
  String? lookupPrincipalEntity(String? header) {
    if (!_loaded || header == null) return null;
    final key = header.trim().toUpperCase();
    return _headerToEntity[key];
  }
}
  