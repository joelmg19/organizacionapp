import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:producti_app/providers/task_provider.dart';
import 'package:producti_app/providers/event_provider.dart';
import 'package:producti_app/providers/user_provider.dart';
import 'package:producti_app/providers/theme_provider.dart';
import 'package:producti_app/providers/habit_provider.dart';
import 'package:producti_app/theme/app_colors.dart';
import 'package:producti_app/widgets/stat_card.dart';
import 'package:producti_app/widgets/task_card.dart';
import 'package:producti_app/widgets/event_timeline_item.dart';
import 'package:producti_app/screens/focus_mode_screen.dart';
import 'package:producti_app/screens/settings_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final habitProvider = Provider.of<HabitProvider>(context);

    final todayTasks = taskProvider.todayTasks;
    final completedToday = todayTasks.where((t) => t.completed).length;
    final upcomingEvents = eventProvider.upcomingEvents.take(3).toList();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: themeProvider.isDarkMode
              ? [const Color(0xFF1F2937), const Color(0xFF111827)]
              : [const Color(0xFFEFF6FF), Colors.white],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, userProvider, themeProvider),
              
              const SizedBox(height: 24),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mood Selector
                    _buildMoodSelector(userProvider),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Stats
                    _buildQuickStats(userProvider, todayTasks.length, habitProvider),
                    
                    const SizedBox(height: 24),
                    
                    // Focus Mode Suggestion
                    if (userProvider.energyLevel == EnergyLevel.high &&
                        userProvider.currentMood == MoodType.focused)
                      _buildFocusSuggestion(context),
                    
                    if (userProvider.energyLevel == EnergyLevel.high &&
                        userProvider.currentMood == MoodType.focused)
                      const SizedBox(height: 24),
                    
                    // Today's Tasks
                    _buildSectionHeader('Tareas de Hoy', () {
                      // Navigate to tasks screen
                    }),
                    
                    const SizedBox(height: 12),
                    
                    ...todayTasks.take(3).map((task) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TaskCard(task: task),
                    )),
                    
                    const SizedBox(height: 24),
                    
                    // Timeline del Día
                    _buildSectionHeader('Timeline del Día', () {
                      // Navigate to calendar
                    }),
                    
                    const SizedBox(height: 12),
                    
                    if (upcomingEvents.isEmpty)
                      const Text('No hay eventos próximos')
                    else
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: upcomingEvents.asMap().entries.map((entry) {
                              return EventTimelineItem(
                                event: entry.value,
                                isLast: entry.key == upcomingEvents.length - 1,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Habits Quick View
                    _buildSectionHeader('Hábitos de Hoy', () {
                      // Navigate to habits
                    }),
                    
                    const SizedBox(height: 12),
                    
                    _buildHabitsQuickView(habitProvider),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProvider userProvider, ThemeProvider themeProvider) {
    final stats = userProvider.stats;
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d \'de\' MMMM yyyy', 'es').format(now);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.blueGradient,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${userProvider.getGreeting()}, ${userProvider.userName}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => themeProvider.toggleTheme(),
                    icon: Icon(
                      themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                    icon: const Icon(Icons.settings, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Level Progress
          Card(
            color: Colors.white.withOpacity(0.1),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bolt, color: Colors.yellow, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Nivel ${stats.level}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${stats.xp} / ${stats.xpToNextLevel} XP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: stats.xp / stats.xpToNextLevel,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector(UserProvider userProvider) {
    final moods = [
      {'type': MoodType.happy, 'icon': '😊', 'label': 'Feliz'},
      {'type': MoodType.focused, 'icon': '🎯', 'label': 'Enfocado'},
      {'type': MoodType.tired, 'icon': '😴', 'label': 'Cansado'},
      {'type': MoodType.stressed, 'icon': '😰', 'label': 'Estresado'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Cómo te sientes hoy?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: moods.map((mood) {
            final isSelected = userProvider.currentMood == mood['type'];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => userProvider.setMood(mood['type'] as MoodType),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? AppColors.blue : Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      color: isSelected 
                          ? AppColors.blue.withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    child: Column(
                      children: [
                        Text(
                          mood['icon'] as String,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mood['label'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickStats(UserProvider userProvider, int todayTasksCount, HabitProvider habitProvider) {
    final stats = userProvider.stats;
    
    return Row(
      children: [
        Expanded(
          child: StatCard(
            gradient: AppColors.greenGradient,
            icon: Icons.local_fire_department,
            value: '${stats.currentStreak}',
            label: 'Días racha',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            gradient: AppColors.purpleGradient,
            icon: Icons.trending_up,
            value: '${stats.productivityScore}%',
            label: 'Productividad',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            gradient: AppColors.orangeGradient,
            icon: Icons.access_time,
            value: '$todayTasksCount',
            label: 'Tareas hoy',
          ),
        ),
      ],
    );
  }

  Widget _buildFocusSuggestion(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.indigoGradient,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.bolt, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Estás muy enfocado!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Activa el modo enfoque',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FocusModeScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.indigo,
            ),
            child: const Text('Activar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onTap,
          child: const Row(
            children: [
              Text('Ver todas'),
              Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHabitsQuickView(HabitProvider habitProvider) {
    final habits = habitProvider.habits.take(4).toList();
    
    return Row(
      children: habits.map((habit) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Card(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: habit.color, width: 3),
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(habit.icon, style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 8),
                    Text(
                      habit.name,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${habit.currentStreak} días',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
