import 'package:flutter/material.dart';
import 'package:producti_app/models/task.dart';
import 'package:producti_app/models/habit.dart';
import 'package:producti_app/models/calendar_event.dart';
import 'package:producti_app/models/achievement.dart';
import 'package:producti_app/models/user_stats.dart';
import 'package:producti_app/theme/app_colors.dart';

class MockData {
  static final List<Task> mockTasks = [
    Task(
      title: 'Revisar propuesta de diseño',
      description: 'Analizar mockups del nuevo proyecto',
      priority: Priority.high,
      status: TaskStatus.inProgress,
      category: 'Trabajo',
      dueDate: DateTime(2026, 3, 28, 14, 0),
      estimatedTime: 60,
      completed: false,
    ),
    Task(
      title: 'Ejercicio matutino',
      priority: Priority.medium,
      status: TaskStatus.completed,
      category: 'Salud',
      dueDate: DateTime(2026, 3, 28, 7, 0),
      estimatedTime: 30,
      completed: true,
    ),
    Task(
      title: 'Llamar a cliente ABC',
      description: 'Seguimiento del proyecto mensual',
      priority: Priority.high,
      status: TaskStatus.todo,
      category: 'Trabajo',
      dueDate: DateTime(2026, 3, 28, 16, 30),
      estimatedTime: 45,
      completed: false,
    ),
    Task(
      title: 'Leer 20 páginas',
      priority: Priority.low,
      status: TaskStatus.todo,
      category: 'Personal',
      dueDate: DateTime(2026, 3, 28, 21, 0),
      estimatedTime: 30,
      completed: false,
    ),
    Task(
      title: 'Preparar presentación Q1',
      description: 'Slides para reunión ejecutiva',
      priority: Priority.high,
      status: TaskStatus.todo,
      category: 'Trabajo',
      dueDate: DateTime(2026, 3, 29, 10, 0),
      estimatedTime: 120,
      completed: false,
    ),
  ];

  static final List<Habit> mockHabits = [
    Habit(
      name: 'Meditación',
      icon: '🧠',
      color: AppColors.purple,
      frequency: Frequency.daily,
      currentStreak: 7,
      longestStreak: 15,
      completedDates: [
        DateTime(2026, 3, 28),
        DateTime(2026, 3, 27),
        DateTime(2026, 3, 26),
      ],
      goal: 7,
    ),
    Habit(
      name: 'Ejercicio',
      icon: '💪',
      color: AppColors.green,
      frequency: Frequency.daily,
      currentStreak: 5,
      longestStreak: 12,
      completedDates: [
        DateTime(2026, 3, 28),
        DateTime(2026, 3, 27),
        DateTime(2026, 3, 25),
      ],
      goal: 5,
    ),
    Habit(
      name: 'Leer',
      icon: '📖',
      color: AppColors.orange,
      frequency: Frequency.daily,
      currentStreak: 3,
      longestStreak: 8,
      completedDates: [
        DateTime(2026, 3, 27),
        DateTime(2026, 3, 26),
      ],
      goal: 7,
    ),
    Habit(
      name: 'Aprender código',
      icon: '💻',
      color: AppColors.blue,
      frequency: Frequency.weekly,
      currentStreak: 2,
      longestStreak: 4,
      completedDates: [DateTime(2026, 3, 26)],
      goal: 3,
    ),
  ];

  static final List<CalendarEvent> mockEvents = [
    CalendarEvent(
      title: 'Reunión de equipo',
      startTime: DateTime(2026, 3, 28, 9, 0),
      endTime: DateTime(2026, 3, 28, 10, 0),
      category: 'Trabajo',
      color: AppColors.blue,
    ),
    CalendarEvent(
      title: 'Gimnasio',
      startTime: DateTime(2026, 3, 28, 7, 0),
      endTime: DateTime(2026, 3, 28, 8, 0),
      category: 'Salud',
      color: AppColors.green,
    ),
    CalendarEvent(
      title: 'Almuerzo con María',
      startTime: DateTime(2026, 3, 28, 13, 0),
      endTime: DateTime(2026, 3, 28, 14, 0),
      category: 'Personal',
      color: AppColors.orange,
    ),
    CalendarEvent(
      title: 'Sesión de diseño',
      startTime: DateTime(2026, 3, 28, 15, 0),
      endTime: DateTime(2026, 3, 28, 17, 0),
      category: 'Trabajo',
      color: AppColors.blue,
    ),
  ];

  static final List<Achievement> mockAchievements = [
    Achievement(
      title: 'Primera Semana',
      description: 'Completa 7 días consecutivos',
      icon: '🏆',
      unlocked: true,
    ),
    Achievement(
      title: 'Maestro de Tareas',
      description: 'Completa 50 tareas',
      icon: '✅',
      unlocked: true,
      progress: 50,
      total: 50,
    ),
    Achievement(
      title: 'Madrugador',
      description: 'Completa 10 tareas antes de las 9am',
      icon: '🌅',
      unlocked: false,
      progress: 7,
      total: 10,
    ),
    Achievement(
      title: 'Enfocado',
      description: 'Usa modo enfoque por 10 horas',
      icon: '🎯',
      unlocked: false,
      progress: 6,
      total: 10,
    ),
    Achievement(
      title: 'Constancia',
      description: 'Mantén un hábito por 30 días',
      icon: '🔥',
      unlocked: false,
      progress: 15,
      total: 30,
    ),
    Achievement(
      title: 'Productivo',
      description: 'Alcanza 100% de productividad en un día',
      icon: '⚡',
      unlocked: true,
    ),
  ];

  static UserStats mockUserStats = UserStats(
    level: 12,
    xp: 2840,
    xpToNextLevel: 3500,
    tasksCompleted: 156,
    currentStreak: 7,
    productivityScore: 87,
  );

  static final List<Map<String, dynamic>> weeklyProductivityData = [
    {'day': 'Lun', 'score': 75},
    {'day': 'Mar', 'score': 82},
    {'day': 'Mié', 'score': 90},
    {'day': 'Jue', 'score': 78},
    {'day': 'Vie', 'score': 85},
    {'day': 'Sáb', 'score': 92},
    {'day': 'Dom', 'score': 70},
  ];

  static final List<Map<String, dynamic>> categoryDistribution = [
    {'name': 'Trabajo', 'value': 45, 'color': AppColors.blue},
    {'name': 'Personal', 'value': 25, 'color': AppColors.orange},
    {'name': 'Salud', 'value': 20, 'color': AppColors.green},
    {'name': 'Otros', 'value': 10, 'color': AppColors.purple},
  ];
}
