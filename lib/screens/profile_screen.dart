import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:producti_app/providers/user_provider.dart';
import 'package:producti_app/providers/task_provider.dart';
import 'package:producti_app/providers/habit_provider.dart';
import 'package:producti_app/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final habitProvider = Provider.of<HabitProvider>(context);

    final stats = userProvider.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- CABECERA DEL PERFIL ---
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.blue,
              child: Text(
                userProvider.userName.isNotEmpty ? userProvider.userName[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Text(userProvider.userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(userProvider.user?.email ?? '', style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 32),

            // --- TARJETAS DE ESTADÍSTICAS REALES ---
            Row(
              children: [
                _buildStatCard('Nivel', '${stats.level}', Icons.star, AppColors.orange),
                const SizedBox(width: 16),
                _buildStatCard('Tareas', '${stats.tasksCompleted}', Icons.check_circle, AppColors.green),
                const SizedBox(width: 16),
                _buildStatCard('Racha', '${stats.currentStreak}', Icons.local_fire_department, AppColors.red),
              ],
            ),

            const SizedBox(height: 32),

            // --- GRÁFICO: ACTIVIDAD SEMANAL REAL ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Actividad Semanal (Hábitos)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildWeeklyChart(habitProvider.weeklyActivity),
            ),

            const SizedBox(height: 32),

            // --- GRÁFICO: DISTRIBUCIÓN DE TAREAS ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Distribución de Tareas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildCategoryChart(taskProvider),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(List<int> weeklyData) {
    final dayNames = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final labels = List.generate(7, (i) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      return dayNames[date.weekday - 1];
    });

    double maxY = 5;
    if (weeklyData.isNotEmpty) {
      final maxVal = weeklyData.reduce((a, b) => a > b ? a : b);
      if (maxVal > 5) maxY = maxVal.toDouble() + 2;
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < labels.length) {
                  return Text(labels[index], style: const TextStyle(fontSize: 12));
                }
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
        barGroups: weeklyData.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: AppColors.blue,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryChart(TaskProvider taskProvider) {
    // 1. Calculamos cuántas tareas hay por categoría
    final tasks = taskProvider.tasks;
    if (tasks.isEmpty) {
      return const Center(child: Text('Aún no hay tareas para analizar', style: TextStyle(color: Colors.grey)));
    }

    Map<String, int> categoryCount = {};
    for (var task in tasks) {
      categoryCount[task.category] = (categoryCount[task.category] ?? 0) + 1;
    }

    // 2. Asignamos colores fijos a las categorías para el gráfico
    final colors = [AppColors.blue, AppColors.orange, AppColors.green, AppColors.purple, AppColors.red];
    int colorIndex = 0;

    List<PieChartSectionData> sections = [];
    categoryCount.forEach((category, count) {
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: count.toDouble(),
          title: '$count',
          radius: 50,
          titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
      colorIndex++;
    });

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: sections,
            ),
          ),
        ),
        // Leyenda
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categoryCount.keys.toList().asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(width: 12, height: 12, color: colors[entry.key % colors.length]),
                    const SizedBox(width: 8),
                    Expanded(child: Text(entry.value, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}