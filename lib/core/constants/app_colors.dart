import 'package:flutter/material.dart';

class AppColors {
  // Trích xuất từ tailwind.config colors
  static const Color primary = Color(0xFF19F073);
  static const Color primaryDark = Color(0xFF12C45E);
  static const Color backgroundDark = Color(0xFF102218);
  static const Color surfaceDark = Color(0xFF182D23);
  static const Color cardDark = Color(0xFF1C2E24);

  // Các màu bổ sung từ constants.tsx
  static const Color blue = Color(0xFF3B82F6);
  static const Color orange = Color(0xFFF59E0B);
  static const Color pink = Color(0xFFEC4899);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color red = Color(0xFFEF4444);
  static const Color slate = Color(0xFF94A3B8);

  // Hiệu ứng Neon (Trích xuất từ boxShadow trong index.html)
  static List<BoxShadow> neonShadow = [
    BoxShadow(
      color: primary.withOpacity(0.4),
      blurRadius: 15,
      offset: const Offset(0, 0),
    ),
  ];

  static List<BoxShadow> neonStrongShadow = [
    BoxShadow(
      color: primary.withOpacity(0.6),
      blurRadius: 25,
      offset: const Offset(0, 0),
    ),
  ];
}