import 'package:flutter/material.dart';
import 'package:producti_app/models/task.dart';
import 'package:producti_app/data/mock_data.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];

  TaskProvider() {
    _tasks = List.from(MockData.mockTasks);
  }

  List<Task> get tasks => _tasks;

  List<Task> get todayTasks {
    final today = DateTime.now();
    return _tasks.where((task) {
      return task.dueDate.year == today.year &&
             task.dueDate.month == today.month &&
             task.dueDate.day == today.day;
    }).toList();
  }

  List<Task> get tomorrowTasks {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return _tasks.where((task) {
      return task.dueDate.year == tomorrow.year &&
             task.dueDate.month == tomorrow.month &&
             task.dueDate.day == tomorrow.day;
    }).toList();
  }

  List<Task> get upcomingTasks {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return _tasks.where((task) => task.dueDate.isAfter(tomorrow)).toList();
  }

  List<Task> get completedTasks {
    return _tasks.where((task) => task.completed).toList();
  }

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void updateTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  void toggleTaskComplete(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(
        completed: !task.completed,
        status: !task.completed ? TaskStatus.completed : TaskStatus.todo,
      );
      notifyListeners();
    }
  }

  List<Task> filterTasks({
    String? searchQuery,
    TaskStatus? status,
    Priority? priority,
  }) {
    return _tasks.where((task) {
      bool matchesSearch = searchQuery == null || 
          task.title.toLowerCase().contains(searchQuery.toLowerCase());
      bool matchesStatus = status == null || task.status == status;
      bool matchesPriority = priority == null || task.priority == priority;
      
      return matchesSearch && matchesStatus && matchesPriority;
    }).toList();
  }
}
