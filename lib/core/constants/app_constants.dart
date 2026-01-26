import 'package:flutter/material.dart';

class AppConstants {
  // --- 1. DANH MỤC CÔNG VIỆC MẶC ĐỊNH (TASKS) ---
  static const List<Map<String, dynamic>> defaultTaskCategories = [
    {'name': 'Học tập', 'icon': Icons.school, 'color': Color(0xFF3B82F6)},
    {'name': 'Sức khỏe', 'icon': Icons.fitness_center, 'color': Color(0xFF19F073)},
    {'name': 'Cá nhân', 'icon': Icons.person, 'color': Color(0xFFF59E0B)},
    {'name': 'Tài chính', 'icon': Icons.attach_money, 'color': Color(0xFFEC4899)},
  ];

  // --- 2. DANH MỤC TÀI CHÍNH MẶC ĐỊNH (FINANCE) ---
  // Giữ nguyên ID để tránh lỗi logic Isar Settings
  static const List<Map<String, dynamic>> defaultFinanceExpenseCats = [
    {'id': 'fe1', 'name': 'Ăn uống', 'icon': Icons.restaurant, 'color': Color(0xFF19F073)},
    {'id': 'fe2', 'name': 'Đi lại', 'icon': Icons.directions_bus, 'color': Color(0xFF3B82F6)},
    {'id': 'fe3', 'name': 'Học tập', 'icon': Icons.school, 'color': Color(0xFF8B5CF6)},
    {'id': 'fe4', 'name': 'Nhà ở', 'icon': Icons.home, 'color': Color(0xFFF59E0B)},
    {'id': 'fe5', 'name': 'Giải trí', 'icon': Icons.videogame_asset, 'color': Color(0xFFEC4899)},
    {'id': 'fe6', 'name': 'Sức khỏe', 'icon': Icons.medical_services, 'color': Color(0xFFEF4444)},
    {'id': 'fe7', 'name': 'Khác', 'icon': Icons.more_horiz, 'color': Color(0xFF94A3B8)},
  ];

  static const List<Map<String, dynamic>> defaultFinanceIncomeCats = [
    {'id': 'fi1', 'name': 'Lương/Thưởng', 'icon': Icons.payments, 'color': Color(0xFF10B981)},
    {'id': 'fi2', 'name': 'Trợ cấp', 'icon': Icons.family_restroom, 'color': Color(0xFF06B6D4)},
    {'id': 'fi3', 'name': 'Làm thêm', 'icon': Icons.work, 'color': Color(0xFF8B5CF6)},
    {'id': 'fi4', 'name': 'Khác', 'icon': Icons.add_circle, 'color': Color(0xFF19F073)},
  ];

  // --- 3. KHO TÂM TRẠNG MỞ RỘNG (MOODS - DÙNG CHO JOURNAL & ANALYTICS) ---
  // Bổ sung Score để ProfileViewModel vẽ biểu đồ tự động
  static const List<Map<String, dynamic>> moods = [
    // Nhóm Tích cực (Score 4-5)
    {'label': 'Tuyệt', 'icon': Icons.sentiment_very_satisfied, 'value': 'great', 'color': Color(0xFF19F073), 'score': 5},
    {'label': 'Vui vẻ', 'icon': Icons.mood, 'value': 'happy', 'color': Color(0xFF19F073), 'score': 4},
    {'label': 'Yêu', 'icon': Icons.favorite, 'value': 'love', 'color': Color(0xFFEC4899), 'score': 5},
    {'label': 'Bình yên', 'icon': Icons.self_improvement, 'value': 'calm', 'color': Color(0xFF3B82F6), 'score': 4},
    {'label': 'Năng lượng', 'icon': Icons.bolt, 'value': 'energetic', 'color': Color(0xFFF59E0B), 'score': 5},
    {'label': 'Tự tin', 'icon': Icons.workspace_premium, 'value': 'confident', 'color': Color(0xFFF59E0B), 'score': 5},

    // Nhóm Trung tính (Score 2-3)
    {'label': 'Ổn', 'icon': Icons.sentiment_satisfied, 'value': 'ok', 'color': Color(0xFF94A3B8), 'score': 3},
    {'label': 'Bình thường', 'icon': Icons.sentiment_neutral, 'value': 'neutral', 'color': Color(0xFF94A3B8), 'score': 2},
    {'label': 'Mệt mỏi', 'icon': Icons.bedtime, 'value': 'tired', 'color': Color(0xFF8B5CF6), 'score': 2},
    {'label': 'Chán', 'icon': Icons.blur_on, 'value': 'bored', 'color': Color(0xFF64748B), 'score': 2},

    // Nhóm Tiêu cực (Score 0-1)
    {'label': 'Buồn', 'icon': Icons.sentiment_dissatisfied, 'value': 'sad', 'color': Color(0xFF3B82F6), 'score': 1},
    {'label': 'Lo lắng', 'icon': Icons.psychology_alt, 'value': 'anxious', 'color': Color(0xFFF59E0B), 'score': 1},
    {'label': 'Áp lực', 'icon': Icons.layers, 'value': 'stressed', 'color': Color(0xFFEF4444), 'score': 1},
    {'label': 'Giận dữ', 'icon': Icons.whatshot, 'value': 'angry', 'color': Color(0xFFEF4444), 'score': 1},
    {'label': 'Tệ', 'icon': Icons.sentiment_very_dissatisfied, 'value': 'terrible', 'color': Color(0xFF7F1D1D), 'score': 0},
    {'label': 'Ốm', 'icon': Icons.medical_services, 'value': 'sick', 'color': Color(0xFF10B981), 'score': 0},
  ];

  // --- 4. DANH SÁCH HOẠT ĐỘNG (JOURNAL ACTIVITIES) ---
  static const List<String> journalActivities = [
    'Học tập', 'Làm việc', 'Tập thể dục', 'Cà phê',
    'Hẹn hò', 'Đọc sách', 'Chơi game', 'Xem phim',
    'Đi dạo', 'Nghỉ ngơi', 'Mua sắm', 'Nấu ăn',
    'Sáng tạo', 'Gia đình', 'Bạn bè', 'Du lịch'
  ];

  // --- 5. THÓI QUEN (HABITS SPECIFIC) ---
  static const List<IconData> habitIcons = [
    Icons.water_drop,
    Icons.menu_book,
    Icons.fitness_center,
    Icons.self_improvement,
    Icons.psychology,
    Icons.directions_run,
    Icons.laptop_mac,
    Icons.language,
    Icons.palette,
    Icons.straighten,
    Icons.bedtime,
    Icons.check_circle_outline,
    Icons.local_drink,
    Icons.wb_sunny,
    Icons.savings,
  ];

  static const List<Color> habitColors = [
    Color(0xFF19F073),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFFEF4444),
    Color(0xFF06B6D4),
  ];

  // --- 6. KHO ICON CHUNG (DÙNG CHO TẤT CẢ PICKER) ---
  static const List<IconData> commonIcons = [
    Icons.school, Icons.fitness_center, Icons.person, Icons.attach_money,
    Icons.work, Icons.home, Icons.shopping_cart, Icons.sports_esports,
    Icons.palette, Icons.restaurant, Icons.medical_services,
    Icons.directions_bus, Icons.videogame_asset, Icons.payments,
    Icons.family_restroom, Icons.more_horiz, Icons.coffee,
    Icons.shopping_bag, Icons.fastfood, Icons.local_gas_station,
    Icons.subscriptions, Icons.theater_comedy, Icons.auto_awesome,
    Icons.brush, Icons.code, Icons.camera_alt, Icons.flight,
    Icons.language, Icons.library_music, Icons.pets, Icons.science
  ];

  static const List<Map<String, dynamic>> journalActivitiesWithIcons = [
    {'label': 'Học tập', 'icon': Icons.school},
    {'label': 'Làm việc', 'icon': Icons.work},
    {'label': 'Thể thao', 'icon': Icons.fitness_center},
    {'label': 'Cà phê', 'icon': Icons.coffee},
    {'label': 'Hẹn hò', 'icon': Icons.favorite},
    {'label': 'Đọc sách', 'icon': Icons.menu_book},
    {'label': 'Chơi game', 'icon': Icons.sports_esports},
    {'label': 'Xem phim', 'icon': Icons.movie},
    {'label': 'Đi dạo', 'icon': Icons.directions_walk},
    {'label': 'Nghỉ ngơi', 'icon': Icons.bedtime},
    {'label': 'Mua sắm', 'icon': Icons.shopping_bag},
    {'label': 'Nấu ăn', 'icon': Icons.restaurant},
    {'label': 'Sáng tạo', 'icon': Icons.brush},
    {'label': 'Gia đình', 'icon': Icons.group},
    {'label': 'Bạn bè', 'icon': Icons.people},
    {'label': 'Du lịch', 'icon': Icons.flight},
  ];

  // Tiện ích lấy Score từ Mood Value (Dùng cho Chart)
  static int getScoreByMoodValue(String value) {
    try {
      return moods.firstWhere((m) => m['value'] == value)['score'] as int;
    } catch (e) {
      return 3; // Mặc định là Ổn
    }
  }
}