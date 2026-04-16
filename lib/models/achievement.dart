import 'package:uuid/uuid.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon; // emoji or icon name
  final bool unlocked;
  final int? progress;
  final int? total;

  Achievement({
    String? id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    this.progress,
    this.total,
  }) : id = id ?? const Uuid().v4();

  Achievement copyWith({
    String? title,
    String? description,
    String? icon,
    bool? unlocked,
    int? progress,
    int? total,
  }) {
    return Achievement(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      unlocked: unlocked ?? this.unlocked,
      progress: progress ?? this.progress,
      total: total ?? this.total,
    );
  }

  double? get progressPercentage {
    if (progress == null || total == null || total == 0) return null;
    return (progress! / total!) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'unlocked': unlocked,
      'progress': progress,
      'total': total,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      unlocked: json['unlocked'],
      progress: json['progress'],
      total: json['total'],
    );
  }
}
