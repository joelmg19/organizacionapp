import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Material Design Strategy)
  static const Color blue = Color(0xFF3B82F6);        // Productividad
  static const Color green = Color(0xFF10B981);       // Progreso
  static const Color orange = Color(0xFFF59E0B);      // Alertas
  static const Color red = Color(0xFFEF4444);         // Urgente
  static const Color purple = Color(0xFF8B5CF6);      // Hábitos
  static const Color indigo = Color(0xFF6366F1);      // Enfoque
  
  // Gradient Colors
  static const List<Color> blueGradient = [Color(0xFF3B82F6), Color(0xFF2563EB)];
  static const List<Color> greenGradient = [Color(0xFF10B981), Color(0xFF059669)];
  static const List<Color> orangeGradient = [Color(0xFFF59E0B), Color(0xFFD97706)];
  static const List<Color> purpleGradient = [Color(0xFF8B5CF6), Color(0xFF7C3AED)];
  static const List<Color> indigoGradient = [Color(0xFF6366F1), Color(0xFF4F46E5)];
  
  // Neutral Colors
  static const Color textDark = Color(0xFF1F2937);
  static const Color textLight = Color(0xFFF9FAFB);
  static const Color textGray = Color(0xFF6B7280);
  
  // Background Colors
  static const Color lightBackground = Color(0xFFF9FAFB);
  static const Color darkBackground = Color(0xFF111827);
  static const Color darkCard = Color(0xFF1F2937);
  
  // Priority Colors
  static const Color priorityHigh = red;
  static const Color priorityMedium = orange;
  static const Color priorityLow = green;
  
  // Status Colors
  static const Color success = green;
  static const Color warning = orange;
  static const Color error = red;
  static const Color info = blue;
  
  // Glassmorphism
  static Color glassLight = Colors.white.withOpacity(0.1);
  static Color glassDark = Colors.black.withOpacity(0.2);
}
