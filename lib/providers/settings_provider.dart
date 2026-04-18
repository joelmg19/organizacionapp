import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:producti_app/services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _pushNotifications = true;
  bool _dailyReminders = true;
  bool _systemCalendarSync = false;
  bool _pinLock = false;

  bool get pushNotifications => _pushNotifications;
  bool get dailyReminders => _dailyReminders;
  bool get systemCalendarSync => _systemCalendarSync;
  bool get pinLock => _pinLock;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _pushNotifications = prefs.getBool('pushNotifications') ?? true;
    _dailyReminders = prefs.getBool('dailyReminders') ?? true;
    _systemCalendarSync = prefs.getBool('systemCalendarSync') ?? false;
    _pinLock = prefs.getBool('pinLock') ?? false;
    notifyListeners();
  }

  Future<void> togglePushNotifications(bool value) async {
    _pushNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pushNotifications', value);
    notifyListeners();
  }

  Future<void> toggleDailyReminders(bool value) async {
    _dailyReminders = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dailyReminders', value);

    // LÓGICA DE RECORDATORIOS
    if (value) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      NotificationService.scheduleNotification(
        id: 999, // ID fijo para el recordatorio diario
        title: "¡Buenos días!",
        body: "Revisa tus tareas y hábitos programados para hoy.",
        scheduledDate: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0), // 9:00 AM
      );
    }

    notifyListeners();
  }

  Future<void> toggleSystemCalendarSync(bool value) async {
    _systemCalendarSync = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('systemCalendarSync', value);
    notifyListeners();
  }

  Future<void> togglePinLock(bool value) async {
    _pinLock = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pinLock', value);
    notifyListeners();
  }
}