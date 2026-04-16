import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

class CalendarEvent {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String category;
  final Color color;

  CalendarEvent({
    String? id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.color,
  }) : id = id ?? const Uuid().v4();

  CalendarEvent copyWith({
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? category,
    Color? color,
  }) {
    return CalendarEvent(
      id: id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      color: color ?? this.color,
    );
  }

  Duration get duration => endTime.difference(startTime);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'category': category,
      'color': color.value,
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'],
      title: json['title'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      category: json['category'],
      color: Color(json['color']),
    );
  }
}
