import 'dart:async';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

// Import hệ thống
import 'package:chronos/core/database/isar_service.dart';
import 'package:chronos/core/constants/app_colors.dart';
import 'package:chronos/core/constants/app_constants.dart';
import 'package:chronos/data/models/task_model.dart';
import 'package:chronos/data/models/habit_model.dart';
import 'package:chronos/data/models/transaction_model.dart';
import 'package:chronos/data/models/journal_model.dart';
import 'package:chronos/data/repositories/ai_repository_impl.dart';

class ProfileViewModel extends ChangeNotifier {
  final IsarService _isarService;
  final AiRepositoryImpl _aiRepo = AiRepositoryImpl();

  // --- DỮ LIỆU NGUỒN THỰC TẾ (Để Public để các Widget biểu đồ truy cập được) ---
  List<TaskModel> tasks = [];
  List<HabitModel> habits = [];
  List<TransactionModel> transactions = [];
  List<JournalModel> journals = [];

  bool isLoadingAi = false;
  String? aiInsight;

  // Streams để theo dõi thay đổi Database thời gian thực (Reactive)
  StreamSubscription? _taskWatcher;
  StreamSubscription? _habitWatcher;
  StreamSubscription? _transWatcher;
  StreamSubscription? _journalWatcher;

  ProfileViewModel(this._isarService) {
    _init();
  }

  void _init() {
    loadAllData();
    _startWatching();
  }

  // --- LOGIC LẮNG NGHE (Tự động vẽ lại biểu đồ khi có thay đổi ở các Tab khác) ---
  void _startWatching() {
    _taskWatcher = _isarService.isar.taskModels.watchLazy().listen((_) => loadAllData());
    _habitWatcher = _isarService.isar.habitModels.watchLazy().listen((_) => loadAllData());
    _transWatcher = _isarService.isar.transactionModels.watchLazy().listen((_) => loadAllData());
    _journalWatcher = _isarService.isar.journalModels.watchLazy().listen((_) => loadAllData());
  }

  @override
  void dispose() {
    _taskWatcher?.cancel();
    _habitWatcher?.cancel();
    _transWatcher?.cancel();
    _journalWatcher?.cancel();
    super.dispose();
  }

  Future<void> loadAllData() async {
    // 1. Lấy toàn bộ Tasks và Habits
    tasks = await _isarService.isar.taskModels.where().findAll();
    habits = await _isarService.isar.habitModels.where().findAll();

    // 2. Lấy Transactions (Lọc bỏ những thứ trong thùng rác)
    transactions = await _isarService.isar.transactionModels
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .findAll();

    // 3. Lấy Journals (Lọc bỏ rác và sắp xếp mới nhất lên đầu)
    journals = await _isarService.isar.journalModels
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .sortByDateDesc()
        .findAll();

    notifyListeners(); // Thông báo để 10 biểu đồ cập nhật UI
  }

  // ============================================================
  // LOGIC TÍNH TOÁN DỮ LIỆU CHO 10 BIỂU ĐỒ (DÙNG DATA THẬT)
  // ============================================================

  // 1. GROWTH CURVE (XP tích lũy 14 ngày qua)
  List<FlSpot> get cumulativeXpSpots {
    double totalXp = 0;
    final now = DateTime.now();
    return List.generate(14, (i) {
      final date = now.subtract(Duration(days: 13 - i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final journalDateStr = DateFormat('dd/MM/yyyy').format(date);

      double dayXp = 0;
      // Task xong = 10xp, Viết nhật ký = 5xp, Habit check = 5xp
      dayXp += tasks.where((t) => t.dueDate == dateStr && t.completed).length * 10.0;
      dayXp += journals.where((j) => j.date == journalDateStr).length * 5.0;
      dayXp += habits.where((h) => h.lastChecked == dateStr).length * 5.0;

      totalXp += dayXp;
      return FlSpot(i.toDouble(), totalXp);
    });
  }

  // 2. MOOD TREND (7 ngày gần nhất)
  List<Map<String, dynamic>> get moodTrendData {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      final dateStr = DateFormat('dd/MM/yyyy').format(date);
      try {
        final journal = journals.firstWhere((j) => j.date == dateStr);
        double score = AppConstants.getScoreByMoodValue(journal.moods.isNotEmpty ? journal.moods[0] : 'neutral').toDouble();
        return {'date': DateFormat('dd/MM').format(date), 'score': score};
      } catch (_) {
        return {'date': DateFormat('dd/MM').format(date), 'score': 2.0}; // Mặc định 'Ổn'
      }
    });
  }

  // 3. PRODUCTIVITY SCATTER (Tương quan Tâm trạng & Hiệu suất)
  List<ScatterSpot> get productivityScatterSpots {
    if (journals.isEmpty) return [ ScatterSpot(3, 5)];
    return journals.take(15).map((j) {
      double moodX = AppConstants.getScoreByMoodValue(j.moods.isNotEmpty ? j.moods[0] : 'neutral').toDouble();
      double prodY = (j.productivityScore ?? 5).toDouble();
      return ScatterSpot(moodX, prodY);
    }).toList();
  }

  // 4. SPENDING PIE (Phân bổ chi tiêu thực tế)
  List<Map<String, dynamic>> get spendingPieData {
    final expenses = transactions.where((t) => t.type == 'expense').toList();
    Map<String, double> grouped = {};
    for (var t in expenses) {
      grouped[t.category] = (grouped[t.category] ?? 0) + t.amount;
    }
    if (grouped.isEmpty) return [{'name': 'Trống', 'value': 1.0, 'color': Colors.grey}];

    final colors = [AppColors.primary, AppColors.orange, AppColors.blue, AppColors.pink, AppColors.purple];
    int colorIdx = 0;
    return grouped.entries.map((e) => {
      'name': e.key,
      'value': e.value,
      'color': colors[colorIdx++ % colors.length]
    }).toList();
  }

  double get totalExpenseSum => transactions
      .where((t) => t.type == 'expense')
      .fold(0.0, (sum, item) => sum + item.amount);

  // 5. LIFE BALANCE RADAR (Chỉ số 5 khía cạnh)
  Map<String, double> get lifeBalanceScores {
    double edu = (tasks.where((t) => t.category == 'Học tập' && t.completed).length * 20.0).clamp(10, 100);
    double fin = (transactions.length * 5.0 + 20).clamp(10, 100);
    double health = (habits.fold(0, (sum, h) => sum + h.streak) * 5.0).clamp(10, 100);
    double soul = (journals.length * 10.0).clamp(10, 100);
    return {
      'Học tập': edu == 0 ? 30 : edu,
      'Tài chính': fin == 0 ? 30 : fin,
      'Sức khỏe': health == 0 ? 30 : health,
      'Tâm hồn': soul == 0 ? 30 : soul,
      'Xã hội': 50.0 // Giả định trung bình
    };
  }

  // 6. FINANCIAL PULSE (Thu chi 4 tháng gần nhất)
  List<Map<String, dynamic>> get financialPulseData {
    final now = DateTime.now();
    return List.generate(4, (i) {
      final monthDate = DateTime(now.year, now.month - (3 - i), 1);
      final monthTrans = transactions.where((t) {
        final d = DateTime.tryParse(t.date);
        return d?.month == monthDate.month && d?.year == monthDate.year;
      });
      return {
        'month': 'T${monthDate.month}',
        'thu': monthTrans.where((t) => t.type == 'income').fold(0.0, (s, t) => s + t.amount) / 1000,
        'chi': monthTrans.where((t) => t.type == 'expense').fold(0.0, (s, t) => s + t.amount) / 1000,
      };
    });
  }

  // 7. EFFICIENCY BAR (Tỷ lệ hoàn thành theo danh mục)
  List<Map<String, dynamic>> get categoryEfficiencyData {
    Map<String, Map<String, int>> stats = {};
    for (var t in tasks) {
      stats.putIfAbsent(t.category, () => {'done': 0, 'rem': 0});
      if (t.completed) stats[t.category]!['done'] = stats[t.category]!['done']! + 1;
      else stats[t.category]!['rem'] = stats[t.category]!['rem']! + 1;
    }
    if (stats.isEmpty) return [{'name': 'Học tập', 'done': 0, 'remaining': 1}];
    return stats.entries.map((e) => {
      'name': e.key, 'done': e.value['done'], 'remaining': e.value['rem']
    }).toList();
  }

  // 8. PRIORITY RADIAL (Phân bổ mức độ ưu tiên)
  List<Map<String, dynamic>> get priorityDistribution {
    return [
      {'name': 'Cao', 'value': tasks.where((t) => t.priority == 'Cao').length.toDouble(), 'color': AppColors.red},
      {'name': 'Trung bình', 'value': tasks.where((t) => t.priority == 'Trung bình').length.toDouble(), 'color': AppColors.orange},
      {'name': 'Thấp', 'value': tasks.where((t) => t.priority == 'Thấp').length.toDouble(), 'color': AppColors.blue},
    ];
  }

  // 9. ENERGY PULSE (Năng lượng 7 ngày qua)
  List<FlSpot> get energyPulseSpots {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      final dateStr = DateFormat('dd/MM/yyyy').format(date);
      try {
        final j = journals.firstWhere((j) => j.date == dateStr);
        return FlSpot(i.toDouble(), (j.productivityScore ?? 5) * 10.0);
      } catch (_) {
        return FlSpot(i.toDouble(), 50.0); // Mặc định 50%
      }
    });
  }

  // 10. ACTIVITY HEATMAP (Mật độ hoạt động 28 ngày qua)
  List<int> get activityHeatmapData {
    final now = DateTime.now();
    return List.generate(28, (i) {
      final date = now.subtract(Duration(days: 27 - i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final journalDateStr = DateFormat('dd/MM/yyyy').format(date);

      int count = 0;
      count += tasks.where((t) => t.dueDate == dateStr && t.completed).length;
      count += journals.where((j) => j.date == journalDateStr).length;
      count += habits.where((h) => h.lastChecked == dateStr).length;
      return count.clamp(0, 3); // Cấp độ màu từ 0-3
    });
  }

  // --- HỆ THỐNG AI ADVISOR ---
  Future<void> getAiInsight() async {
    if (tasks.isEmpty && journals.isEmpty) {
      aiInsight = "Hãy bắt đầu sử dụng app để tôi có đủ dữ liệu đưa ra lời khuyên cho bạn!";
      notifyListeners();
      return;
    }
    isLoadingAi = true;
    notifyListeners();

    try {
      final summary = "Thống kê thực tế: Xong ${tasks.where((t)=>t.completed).length}/${tasks.length} nhiệm vụ. "
          "Đã viết ${journals.length} nhật ký. "
          "Giao dịch tài chính: ${transactions.length} mục.";
      aiInsight = await _aiRepo.fetchGrowthAdvice(summary);
    } catch (e) {
      aiInsight = "Chronos AI đang bận. Hãy thử lại sau ít phút nhé!";
    } finally {
      isLoadingAi = false;
      notifyListeners();
    }
  }

  // Xóa sạch dữ liệu (Reset hệ thống)
  Future<void> clearAllData() async {
    await _isarService.isar.writeTxn(() => _isarService.isar.clear());
    await loadAllData();
  }
}