import 'package:flutter/foundation.dart';
import '../models/models.dart';

class AppNotificationsProvider extends ChangeNotifier {
  bool _whatsAppAlertsEnabled = true;
  final List<AppNotificationMessage> _messages = [];

  AppNotificationsProvider() {
    final now = DateTime.now();
    _messages.addAll([
      AppNotificationMessage(
        id: 'wa_1',
        message: '✅ Earnings verified for August',
        timestamp: now.subtract(const Duration(hours: 6)),
      ),
      AppNotificationMessage(
        id: 'wa_2',
        message: '🔔 Access requested by HDFC Bank',
        timestamp: now.subtract(const Duration(hours: 3, minutes: 18)),
      ),
      AppNotificationMessage(
        id: 'wa_3',
        message: '⚠️ New obligation due in 3 days',
        timestamp: now.subtract(const Duration(minutes: 42)),
      ),
    ]);
  }

  bool get whatsAppAlertsEnabled => _whatsAppAlertsEnabled;
  List<AppNotificationMessage> get messages => List.unmodifiable(_messages);

  void setWhatsAppAlerts(bool enabled) {
    if (_whatsAppAlertsEnabled == enabled) return;
    _whatsAppAlertsEnabled = enabled;
    notifyListeners();
  }

  void addAlert(String message) {
    if (!_whatsAppAlertsEnabled) return;
    _messages.add(
      AppNotificationMessage(
        id: 'wa_${DateTime.now().microsecondsSinceEpoch}',
        message: message,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
