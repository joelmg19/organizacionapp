import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:producti_app/providers/habit_provider.dart';
import 'package:producti_app/providers/user_provider.dart'; // <- IMPORTACIÓN
import 'package:producti_app/models/habit.dart';
import 'package:producti_app/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:producti_app/screens/add_habit_screen.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final habits = habitProvider.habits;
    final activityData = habitProvider.weeklyActivity;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.purpleGradient),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mis Hábitos', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _buildStatBox('Mejor Racha', habitProvider.bestStreak.toString(), Icons.local_fire_department),
                        const SizedBox(width: 12),
                        _buildStatBox('Hoy', '${habitProvider.completedToday}/${habits.length}', Icons.check_circle),
                        const SizedBox(width: 12),
                        _buildStatBox('Tasa', '${habitProvider.completionRate.toStringAsFixed(0)}%', Icons.trending_up),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Actividad Semanal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SizedBox(height: 150, child: _buildWeeklyChart(activityData)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final habit = habits[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildHabitCard(context, habit, habitProvider),
                    );
                  },
                  childCount: habits.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddHabitScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(List<int> activity) {
    final now = DateTime.now();
    final dayNames = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final labels = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return dayNames[date.weekday - 1];
    });

    double maxScaleY = 5;
    if (activity.isNotEmpty) {
      final maxActivity = activity.reduce((a, b) => a > b ? a : b);
      if (maxActivity > 5) maxScaleY = maxActivity.toDouble() + 1;
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxScaleY,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < labels.length) return Text(labels[index], style: const TextStyle(fontSize: 12));
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: activity.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: AppColors.purple,
                width: 24,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context, Habit habit, HabitProvider provider) {
    final isCompleted = habit.isCompletedToday();
    final progress = habit.currentStreak / habit.goal;

    // Obtenemos el UserProvider para dar/quitar XP
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return InkWell(
      onTap: () {
        // LÓGICA ANTI-BUG: Si marca suma 20 XP, si desmarca resta 20 XP
        if (!isCompleted) {
          userProvider.addExperience(20);
        } else {
          userProvider.removeExperience(20);
        }
        provider.toggleHabitCompletion(habit.id);
      },
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: habit.color, width: 4)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: habit.color.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: isCompleted ? Border.all(color: AppColors.green, width: 3) : null,
                      ),
                      child: Center(child: Text(habit.icon, style: const TextStyle(fontSize: 24))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(habit.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              if (isCompleted)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                                  child: const Text('Completado', style: TextStyle(fontSize: 10, color: AppColors.green, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('${habit.frequency == Frequency.daily ? "Diario" : "Semanal"} • Racha: ${habit.currentStreak} días', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    if (isCompleted) const Icon(Icons.check_circle, color: AppColors.green, size: 28),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(habit.color),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${habit.currentStreak}/${habit.goal}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}