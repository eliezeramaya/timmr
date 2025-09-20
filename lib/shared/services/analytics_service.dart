// shared/services/analytics_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:amplitude_flutter/events/identify.dart';


/// AnalyticsService (Amplitude v4)
/// - Wrapper simple y tolerante a fallos.
/// - Usa Identify para user properties.
/// - Si no hay API key, se desactiva silenciosamente.
class AnalyticsService {
  AnalyticsService._();

  static Amplitude? _amp;
  static bool _enabled = false;

  /// Inicializa Amplitude.
  /// Prioridad:
  ///  1) [apiKey] pasada por parámetro
  ///  2) --dart-define=AMPLITUDE_API_KEY
  static Future<void> init({String? apiKey}) async {
    final key = apiKey ??
        const String.fromEnvironment('AMPLITUDE_API_KEY', defaultValue: '');

    if (key.isEmpty) {
      _enabled = false;
      if (kDebugMode) {
        // print('[Analytics] Disabled: missing AMPLITUDE_API_KEY');
      }
      return;
    }

    try {
      _amp = Amplitude(Configuration(apiKey: key));
      await _amp!.isBuilt; // espera init
      _enabled = true;

      if (kDebugMode) {
        // print('[Analytics] Amplitude initialized');
      }
    } catch (e) {
      _enabled = false;
      if (kDebugMode) {
        // print('[Analytics] init error: $e');
      }
    }
  }

  /// Opt-in/out global
  static void setEnabled(bool enabled) {
    _enabled = enabled && _amp != null;
  }

  /// Define el userId (después de login/logout)
  static Future<void> setUserId(String? userId) async {
    if (!_enabled || _amp == null) return;
    try {
      await _amp!.setUserId(userId);
    } catch (_) {}
  }

  /// Establece propiedades del usuario con Identify.set()
  static Future<void> setUserProperties(Map<String, Object?> props) async {
    if (!_enabled || _amp == null || props.isEmpty) return;
    try {
      final id = Identify();
      props.forEach((k, v) {
        id.set(k, v);
      });
      await _amp!.identify(id);
    } catch (_) {}
  }

  /// Limpia todas las propiedades del usuario (Identify.clearAll())
  static Future<void> clearUserProperties() async {
    if (!_enabled || _amp == null) return;
    try {
      final id = Identify()..clearAll();
      await _amp!.identify(id);
    } catch (_) {}
  }

  /// Envía un evento
  static Future<void> logEvent(String name, [Map<String, Object?>? props]) async {
    if (!_enabled || _amp == null) return;
    try {
      await _amp!.track(BaseEvent(name, eventProperties: props));
    } catch (_) {}
  }

  /// Evento de “pantalla”
  static Future<void> logScreen(String screenName, [Map<String, Object?>? extra]) {
    return logEvent('screen_view', {
      'screen_name': screenName,
      if (extra != null) ...extra,
    });
  }

  /// Marca ingresos (simplificado como evento)
  static Future<void> logRevenue({
    required double amount,
    String? productId,
    int? quantity,
    String? currency, // "USD", "MXN", etc.
    Map<String, Object?>? extra,
  }) {
    return logEvent('revenue', {
      'amount': amount,
      if (currency != null) 'currency': currency,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (extra != null) ...extra,
    });
  }

  /// Envía el buffer pendiente
  static Future<void> flush() async {
    if (!_enabled || _amp == null) return;
    try {
      await _amp!.flush();
    } catch (_) {}
  }

  /// Resetea deviceId + userId
  static Future<void> reset() async {
    if (!_enabled || _amp == null) return;
    try {
      await _amp!.reset();
    } catch (_) {}
  }

  static bool get isEnabled => _enabled;
}
