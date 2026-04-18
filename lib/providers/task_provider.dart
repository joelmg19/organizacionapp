import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:producti_app/models/task.dart';
import 'package:producti_app/services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  TaskProvider() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _listenToTasks(user.uid);
      } else {
        _tasks = [];
        notifyListeners();
      }
    });
  }

  void _listenToTasks(String userId) {
    _db.collection('users').doc(userId).collection('tasks')
        .snapshots()
        .listen((snapshot) {
      _tasks = snapshot.docs.map((doc) => Task.fromJson(doc.data(), doc.id)).toList();
      _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      notifyListeners();
    });
  }

  List<Task> get todayTasks {
    final today = DateTime.now();
    return _tasks.where((t) => t.dueDate.year == today.year && t.dueDate.month == today.month && t.dueDate.day == today.day).toList();
  }

  List<Task> get tomorrowTasks {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return _tasks.where((t) => t.dueDate.year == tomorrow.year && t.dueDate.month == tomorrow.month && t.dueDate.day == tomorrow.day).toList();
  }

  List<Task> get upcomingTasks {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return _tasks.where((t) => t.dueDate.isAfter(tomorrow)).toList();
  }

  List<Task> filterTasks({String? searchQuery, TaskStatus? status, Priority? priority}) {
    return _tasks.where((task) {
      bool matchesSearch = searchQuery == null || task.title.toLowerCase().contains(searchQuery.toLowerCase());
      bool matchesStatus = status == null || task.status == status;
      bool matchesPriority = priority == null || task.priority == priority;
      return matchesSearch && matchesStatus && matchesPriority;
    }).toList();
  }

  Future<void> addTask(Task task) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).collection('tasks').doc(task.id).set(task.toJson());

    // PROGRAMAR NOTIFICACIÓN SI LA FECHA ES FUTURA
    if (task.dueDate.isAfter(DateTime.now())) {
      NotificationService.scheduleNotification(
        id: task.id.hashCode,
        title: "Tarea pendiente: ${task.title}",
        body: task.description ?? "Es hora de completar tu tarea.",
        scheduledDate: task.dueDate,
      );
    }
  }

  Future<void> updateTask(Task task) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).collection('tasks').doc(task.id).update(task.toJson());
  }

  Future<void> deleteTask(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).collection('tasks').doc(id).delete();
  }

  Future<void> toggleTaskComplete(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];
      final newStatus = !task.completed ? TaskStatus.completed : TaskStatus.todo;

      final user = _auth.currentUser;
      if (user != null) {
        await _db.collection('users').doc(user.uid).collection('tasks').doc(id).update({
          'completed': !task.completed,
          'status': newStatus.name,
        });
      }
    }
  }
}