import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    notifyListeners();
  }

  Future<void> toggleSystemCalendarSync(bool value) async {
    _systemCalendarSync = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('systemCalendarSync', value);
    notifyListeners();
    // NOTA: En el próximo paso aquí dispararemos la sincronización real con Google/Sistema
  }

  Future<void> togglePinLock(bool value) async {
    _pinLock = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pinLock', value);
    notifyListeners();
  }
}