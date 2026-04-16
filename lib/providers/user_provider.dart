import 'package:flutter/material.dart';
import 'package:producti_app/models/user_stats.dart';
import 'package:producti_app/models/achievement.dart';
import 'package:producti_app/data/mock_data.dart';

enum MoodType { happy, focused, tired, stressed, neutral }
enum EnergyLevel { high, medium, low }

class UserProvider extends ChangeNotifier {
  UserStats _stats = MockData.mockUserStats;
  List<Achievement> _achievements = [];
  MoodType _currentMood = MoodType.focused;
  EnergyLevel _energyLevel = EnergyLevel.high;
  String _userName = 'Usuario';

  UserProvider() {
    _achievements = List.from(MockData.mockAchievements);
  }

  UserStats get stats => _stats;
  List<Achievement> get achievements => _achievements;
  MoodType get currentMood => _currentMood;
  EnergyLevel get energyLevel => _energyLevel;
  String get userName => _userName;

  List<Achievement> get unlockedAchievements {
    return _achievements.where((a) => a.unlocked).toList();
  }

  List<Achievement> get inProgressAchievements {
    return _achievements.where((a) => !a.unlocked && a.progress != null).toList();
  }

  void updateStats(UserStats stats) {
    _stats = stats;
    notifyListeners();
  }

  void addXP(int xp) {
    int newXP = _stats.xp + xp;
    int newLevel = _stats.level;
    int xpToNext = _stats.xpToNextLevel;

    // Check for level up
    while (newXP >= xpToNext) {
      newXP -= xpToNext;
      newLevel++;
      xpToNext = _calculateXPForNextLevel(newLevel);
    }

    _stats = _stats.copyWith(
      xp: newXP,
      level: newLevel,
      xpToNextLevel: xpToNext,
    );
    notifyListeners();
  }

  int _calculateXPForNextLevel(int level) {
    // Formula: base XP * level multiplier
    return (500 + (level * 250)).toInt();
  }

  void completeTask() {
    _stats = _stats.copyWith(
      tasksCompleted: _stats.tasksCompleted + 1,
    );
    addXP(10); // 10 XP per task
    _checkAchievements();
  }

  void updateStreak(int streak) {
    _stats = _stats.copyWith(currentStreak: streak);
    _checkAchievements();
    notifyListeners();
  }

  void updateProductivityScore(int score) {
    _stats = _stats.copyWith(productivityScore: score);
    notifyListeners();
  }

  void setMood(MoodType mood) {
    _currentMood = mood;
    notifyListeners();
  }

  void setEnergyLevel(EnergyLevel level) {
    _energyLevel = level;
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void _checkAchievements() {
    // Check and unlock achievements based on stats
    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      
      if (achievement.unlocked) continue;

      // Example achievement checks
      if (achievement.title == 'Primera Semana' && _stats.currentStreak >= 7) {
        _achievements[i] = achievement.copyWith(unlocked: true);
      }
      
      if (achievement.title == 'Maestro de Tareas' && _stats.tasksCompleted >= 50) {
        _achievements[i] = achievement.copyWith(unlocked: true);
      }
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Buenos días';
    } else if (hour < 18) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }
}
