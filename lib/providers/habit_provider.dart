import 'package:flutter/material.dart';
import 'package:producti_app/models/habit.dart';
import 'package:producti_app/data/mock_data.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];

  HabitProvider() {
    _habits = List.from(MockData.mockHabits);
  }

  List<Habit> get habits => _habits;

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

  void addHabit(Habit habit) {
    _habits.add(habit);
    notifyListeners();
  }

  void updateHabit(Habit habit) {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
      notifyListeners();
    }
  }

  void deleteHabit(String id) {
    _habits.removeWhere((habit) => habit.id == id);
    notifyListeners();
  }

  void toggleHabitCompletion(String id) {
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index != -1) {
      final habit = _habits[index];
      final today = DateTime.now();
      final isAlreadyCompleted = habit.isCompletedToday();

      List<DateTime> updatedDates = List.from(habit.completedDates);
      int newStreak = habit.currentStreak;

      if (isAlreadyCompleted) {
        // Remove today's completion
        updatedDates.removeWhere((date) =>
            date.year == today.year &&
            date.month == today.month &&
            date.day == today.day);
        newStreak = _calculateStreak(updatedDates);
      } else {
        // Add today's completion
        updatedDates.add(today);
        newStreak = _calculateStreak(updatedDates);
      }

      _habits[index] = habit.copyWith(
        completedDates: updatedDates,
        currentStreak: newStreak,
        longestStreak: newStreak > habit.longestStreak ? newStreak : habit.longestStreak,
      );
      notifyListeners();
    }
  }

  int _calculateStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;
    
    dates.sort((a, b) => b.compareTo(a)); // Sort descending
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
