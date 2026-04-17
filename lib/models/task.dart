import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum Priority { high, medium, low }
enum TaskStatus { todo, inProgress, completed }

class Task {
  final String id;
  final String title;
  final String? description;
  final Priority priority;
  final TaskStatus status;
  final String category;
  final DateTime dueDate;
  final int? estimatedTime; // en minutos
  final bool completed;

  Task({
    String? id,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    required this.category,
    required this.dueDate,
    this.estimatedTime,
    required this.completed,
  }) : id = id ?? const Uuid().v4();

  Task copyWith({
    String? title,
    String? description,
    Priority? priority,
    TaskStatus? status,
    String? category,
    DateTime? dueDate,
    int? estimatedTime,
    bool? completed,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'status': status.name,
      'category': category,
      'dueDate': Timestamp.fromDate(dueDate),
      'estimatedTime': estimatedTime,
      'completed': completed,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json, String documentId) {
    return Task(
      id: documentId,
      title: json['title'] ?? '',
      description: json['description'],
      priority: Priority.values.firstWhere((e) => e.name == json['priority'], orElse: () => Priority.medium),
      status: TaskStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => TaskStatus.todo),
      category: json['category'] ?? 'General',
      dueDate: (json['dueDate'] as Timestamp).toDate(),
      estimatedTime: json['estimatedTime'],
      completed: json['completed'] ?? false,
    );
  }
}