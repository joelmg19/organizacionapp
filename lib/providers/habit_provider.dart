import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:producti_app/models/habit.dart';

class HabitProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Habit> _habits = [];

  HabitProvider() {
    // Escuchar la sesión del usuario
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _listenToHabits(user.uid);
      } else {
        _habits = [];
        notifyListeners();
      }
    });
  }

  List<Habit> get habits => _habits;

  // Lógica de lectura en tiempo real
  void _listenToHabits(String userId) {
    _db.collection('users').doc(userId).collection('habits')
        .snapshots()
        .listen((snapshot) {
      _habits = snapshot.docs.map((doc) => Habit.fromJson(doc.data(), doc.id)).toList();
      notifyListeners();
    });
  }

  // --- Estadísticas en tiempo real ---
  int get completedToday {
    return _habits.where((habit) => habit.isCompletedToday()).length;
  }

  int get bestStreak {
    if (_habits.isEmpty) return 0;
    return _habits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b);
  }

  double get completionRate {
    if (_habits.isEmpty) return 0;
    return (completedToday / _habits.length) * 100;
  }

  // CÁLCULO REAL PARA EL GRÁFICO: Retorna la cuenta de hábitos completados en los últimos 7 días
  List<int> get weeklyActivity {
    final today = DateTime.now();
    List<int> counts = [];

    // Generamos la cuenta para los últimos 7 días (de hace 6 días hasta hoy)
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final count = _habits.where((h) {
        return h.completedDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
      }).length;
      counts.add(count);
    }
    return counts;
  }

  // --- Operaciones en Firebase ---
  Future<void> addHabit(Habit habit) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).collection('habits').doc(habit.id).set(habit.toJson());
  }

  Future<void> updateHabit(Habit habit) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).collection('habits').doc(habit.id).update(habit.toJson());
  }

  Future<void> deleteHabit(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).collection('habits').doc(id).delete();
  }

  Future<void> toggleHabitCompletion(String id) async {
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index != -1) {
      final habit = _habits[index];
      final today = DateTime.now();
      final isAlreadyCompleted = habit.isCompletedToday();

      List<DateTime> updatedDates = List.from(habit.completedDates);
      int newStreak = habit.currentStreak;

      if (isAlreadyCompleted) {
        // Quitar la marca de hoy
        updatedDates.removeWhere((date) =>
        date.year == today.year && date.month == today.month && date.day == today.day);
        newStreak = _calculateStreak(updatedDates);
      } else {
        // Marcar hoy como completado
        updatedDates.add(today);
        newStreak = _calculateStreak(updatedDates);
      }

      final updatedHabit = habit.copyWith(
        completedDates: updatedDates,
        currentStreak: newStreak,
        longestStreak: newStreak > habit.longestStreak ? newStreak : habit.longestStreak,
      );

      // Enviamos la actualización a la base de datos
      await updateHabit(updatedHabit);
    }
  }

  // --- Helpers ---
  int _calculateStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    dates.sort((a, b) => b.compareTo(a)); // Orden descendente
    int streak = 1;
    DateTime current = dates[0];

    for (int i = 1; i < dates.length; i++) {
      final diff = current.difference(dates[i]).inDays;
      if (diff == 1) {
        streak++;
        current = dates[i];
      } else {
        break;
      }
    }
    return streak;
  }

  Map<DateTime, List<Habit>> getMonthlyHabitMap(DateTime month) {
    final Map<DateTime, List<Habit>> habitMap = {};
    for (var habit in _habits) {
      for (var date in habit.completedDates) {
        if (date.year == month.year && date.month == month.month) {
          final dateKey = DateTime(date.year, date.month, date.day);
          habitMap.putIfAbsent(dateKey, () => []);
          habitMap[dateKey]!.add(habit);
        }
      }
    }
    return habitMap;
  }
}