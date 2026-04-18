import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final bool isDeviceEvent;
  final String category; // <- RECUPERAMOS LA CATEGORÍA

  CalendarEvent({
    String? id,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    required this.color,
    this.isDeviceEvent = false,
    this.category = 'General', // Valor por defecto
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'color': color.value,
      'isDeviceEvent': isDeviceEvent,
      'category': category,
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json, String documentId) {
    return CalendarEvent(
      id: documentId,
      title: json['title'] ?? 'Sin título',
      description: json['description'] ?? '',
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: (json['endTime'] as Timestamp).toDate(),
      color: Color(json['color'] ?? 0xFF3B82F6),
      isDeviceEvent: json['isDeviceEvent'] ?? false,
      category: json['category'] ?? 'General',
    );
  }
}