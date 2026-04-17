import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:producti_app/providers/task_provider.dart';
import 'package:producti_app/models/task.dart';
import 'package:producti_app/widgets/task_card.dart';
import 'package:producti_app/theme/app_colors.dart';
import 'package:producti_app/screens/add_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _searchQuery = '';
  TaskStatus? _activeFilter;

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final filteredTasks = taskProvider.filterTasks(
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      status: _activeFilter,
    );

    final tasksToday = filteredTasks.where((t) {
      final now = DateTime.now();
      return t.dueDate.year == now.year &&
             t.dueDate.month == now.month &&
             t.dueDate.day == now.day;
    }).toList();

    final tasksTomorrow = filteredTasks.where((t) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      return t.dueDate.year == tomorrow.year &&
             t.dueDate.month == tomorrow.month &&
             t.dueDate.day == tomorrow.day;
    }).toList();

    final tasksUpcoming = filteredTasks.where((t) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      return t.dueDate.isAfter(tomorrow);
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mis Tareas',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Bar
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar tareas...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Todas', null),
                        const SizedBox(width: 8),
                        _buildFilterChip('Por hacer', TaskStatus.todo),
                        const SizedBox(width: 8),
                        _buildFilterChip('En progreso', TaskStatus.inProgress),
                        const SizedBox(width: 8),
                        _buildFilterChip('Completadas', TaskStatus.completed),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Tasks List
            Expanded(
              child: filteredTasks.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        if (tasksToday.isNotEmpty) ...[
                          _buildSectionHeader(
                            'Hoy',
                            tasksToday.length,
                            AppColors.blue,
                          ),
                          const SizedBox(height: 12),
                          ...tasksToday.map((task) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TaskCard(task: task),
                          )),
                          const SizedBox(height: 24),
                        ],
                        
                        if (tasksTomorrow.isNotEmpty) ...[
                          _buildSectionHeader(
                            'Mañana',
                            tasksTomorrow.length,
                            AppColors.purple,
                          ),
                          const SizedBox(height: 12),
                          ...tasksTomorrow.map((task) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TaskCard(task: task),
                          )),
                          const SizedBox(height: 24),
                        ],
                        
                        if (tasksUpcoming.isNotEmpty) ...[
                          _buildSectionHeader(
                            'Próximamente',
                            tasksUpcoming.length,
                            Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          ...tasksUpcoming.map((task) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TaskCard(task: task),
                          )),
                        ],
                        
                        const SizedBox(height: 80),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Abre la nueva pantalla para crear tareas reales
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label, TaskStatus? status) {
    final isActive = _activeFilter == status;
    
    return FilterChip(
      label: Text(label),
      selected: isActive,
      onSelected: (selected) {
        setState(() {
          _activeFilter = selected ? status : null;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.blue.withOpacity(0.2),
      checkmarkColor: AppColors.blue,
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Icon(Icons.calendar_today, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No hay tareas para hoy',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? '¡Genial! Todas tus tareas están completas'
                : 'No se encontraron tareas con ese nombre',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
