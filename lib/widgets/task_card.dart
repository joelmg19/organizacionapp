import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:producti_app/models/task.dart';
import 'package:producti_app/providers/task_provider.dart';
import 'package:producti_app/providers/user_provider.dart';
import 'package:producti_app/theme/app_colors.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high: return AppColors.red;
      case Priority.medium: return AppColors.orange;
      case Priority.low: return AppColors.green;
    }
  }

  String _getPriorityLabel(Priority priority) {
    switch (priority) {
      case Priority.high: return 'Alta';
      case Priority.medium: return 'Media';
      case Priority.low: return 'Baja';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: task.completed ? 1 : 2,
      child: Opacity(
        opacity: task.completed ? 0.6 : 1.0,
        child: InkWell(
          onTap: () {
            final taskProvider = Provider.of<TaskProvider>(context, listen: false);
            final userProvider = Provider.of<UserProvider>(context, listen: false);

            // LÓGICA ANTI-BUG: Si marca, suma. Si desmarca, resta.
            if (!task.completed) {
              userProvider.addExperience(50);
            } else {
              userProvider.removeExperience(50);
            }

            taskProvider.toggleTaskComplete(task.id);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: _getPriorityColor(task.priority), width: 4),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      task.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: task.completed ? AppColors.green : Colors.grey.shade400,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: task.completed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        if (task.description != null && task.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description!,
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
                              child: Text(task.category, style: const TextStyle(fontSize: 12)),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(DateFormat('HH:mm').format(task.dueDate), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              ],
                            ),
                            if (task.estimatedTime != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.timer, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text('${task.estimatedTime} min', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                ],
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(border: Border.all(color: _getPriorityColor(task.priority)), borderRadius: BorderRadius.circular(6)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.flag, size: 12, color: _getPriorityColor(task.priority)),
                                  const SizedBox(width: 4),
                                  Text(_getPriorityLabel(task.priority), style: TextStyle(fontSize: 12, color: _getPriorityColor(task.priority), fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}