import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter/foundation.dart';

class SentryService {
  static Future<void> init() async {
    final dsn = const String.fromEnvironment('SENTRY_DSN', defaultValue: '');
    if (dsn.isEmpty) return;
    await SentryFlutter.init((o) {
      o.dsn = dsn;
      o.tracesSampleRate = kDebugMode ? 0.0 : 0.2;
    });
  }
}
