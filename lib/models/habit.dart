import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

enum Frequency { daily, weekly }

class Habit {
  final String id;
  final String name;
  final String icon; // emoji
  final Color color;
  final Frequency frequency;
  final int currentStreak;
  final int longestStreak;
  final List<DateTime> completedDates;
  final int goal; // times per week/month

  Habit({
    String? id,
    required this.name,
    required this.icon,
    required this.color,
    required this.frequency,
    required this.currentStreak,
    required this.longestStreak,
    required this.completedDates,
    required this.goal,
  }) : id = id ?? const Uuid().v4();

  Habit copyWith({
    String? name,
    String? icon,
    Color? color,
    Frequency? frequency,
    int? currentStreak,
    int? longestStreak,
    List<DateTime>? completedDates,
    int? goal,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      completedDates: completedDates ?? this.completedDates,
      goal: goal ?? this.goal,
    );
  }

  bool isCompletedToday() {
    final today = DateTime.now();
    return completedDates.any((date) =>
    date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color.value,
      'frequency': frequency.name,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      // Firebase acepta listas de Strings para fechas sin problema
      'completedDates': completedDates.map((d) => d.toIso8601String()).toList(),
      'goal': goal,
    };
  }

  // Añadimos el documentId aquí
  factory Habit.fromJson(Map<String, dynamic> json, String documentId) {
    return Habit(
      id: documentId,
      name: json['name'] ?? '',
      icon: json['icon'] ?? '🎯',
      color: Color(json['color'] ?? 0xFF3B82F6),
      frequency: Frequency.values.firstWhere(
              (e) => e.name == json['frequency'],
          orElse: () => Frequency.daily
      ),
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      completedDates: (json['completedDates'] as List?)
          ?.map((d) => DateTime.parse(d as String))
          .toList() ?? [],
      goal: json['goal'] ?? 7,
    );
  }
}