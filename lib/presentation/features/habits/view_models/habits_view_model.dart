import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import 'package:chronos/core/database/isar_service.dart';
import 'package:chronos/data/models/habit_model.dart';

class HabitsViewModel extends ChangeNotifier {
  final IsarService _isarService;
  List<HabitModel> _habits = [];

  HabitsViewModel(this._isarService) {
    loadHabits();
  }

  // --- GETTERS ---
  List<HabitModel> get habits => _habits;
  String get _todayStr => DateFormat('yyyy-MM-dd').format(DateTime.now());

  int get completedToday => _habits.where((h) => h.lastChecked == _todayStr).length;

  int get longestStreak {
    if (_habits.isEmpty) return 0;
    return _habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);
  }

  // --- TẢI VÀ ĐỒNG BỘ DỮ LIỆU ---
  Future<void> loadHabits() async {
    try {
      final rawHabits = await _isarService.isar.habitModels.where().findAll();

      List<HabitModel> syncedHabits = [];
      for (var h in rawHabits) {
        // Mỗi khi load, kiểm tra xem thói quen này có cần reset tuần mới không
        final syncedH = await _syncHabitLogic(h);
        syncedHabits.add(syncedH);
      }

      _habits = syncedHabits;
      notifyListeners();
    } catch (e) {
      debugPrint("HABITS_LOAD_ERROR: $e");
    }
  }

  // LOGIC ĐỒNG BỘ: Reset lịch sử khi sang tuần mới, tính streak khi bỏ lỡ
  Future<HabitModel> _syncHabitLogic(HabitModel habit) async {
    final now = DateTime.now();
    final currentWeek = _getWeekNumber(now);
    final currentYear = now.year;

    bool needUpdate = false;

    // 1. Kiểm tra tuần mới/năm mới để reset 7 dấu tích (History)
    if (habit.lastCheckedWeek != null) {
      // Nếu năm hiện tại lớn hơn năm cũ, hoặc cùng năm nhưng tuần hiện tại lớn hơn
      if (currentYear > habit.lastCheckedYear! ||
          (currentYear == habit.lastCheckedYear && currentWeek > habit.lastCheckedWeek!)) {

        // Reset toàn bộ history về false cho tuần mới
        habit.history = [false, false, false, false, false, false, false];
        // Không reset lastCheckedWeek ngay tại đây mà đợi đến khi user nhấn tích mới update
        needUpdate = true;
      }
    }

    // 2. Kiểm tra Streak (Nếu bỏ lỡ ngày hôm qua)
    if (habit.lastChecked != null) {
      final lastDate = DateTime.parse(habit.lastChecked!);
      // Tính khoảng cách ngày (chỉ tính phần Date, không tính Time)
      final todayDateOnly = DateTime(now.year, now.month, now.day);
      final lastDateOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final diff = todayDateOnly.difference(lastDateOnly).inDays;

      // Nếu nghỉ quá 1 ngày (diff > 1) và hôm nay chưa tích -> Streak về 0
      if (diff > 1 && habit.lastChecked != _todayStr) {
        habit.streak = 0;
        needUpdate = true;
      }
    }

    if (needUpdate) {
      await _isarService.isar.writeTxn(() async {
        await _isarService.isar.habitModels.put(habit);
      });
    }

    return habit;
  }

  // --- LOGIC ĐIỂM DANH (TOGGLE CHECK-IN) ---
  Future<void> toggleCheckIn(HabitModel habit) async {
    final now = DateTime.now();
    //now.weekday trả về: 1 (Thứ 2) -> 7 (Chủ nhật)
    //Index mảng history: 0 (Thứ 2) -> 6 (Chủ nhật)
    final int weekdayIndex = now.weekday - 1;
    final bool isDoneToday = habit.lastChecked == _todayStr;

    await _isarService.isar.writeTxn(() async {
      if (isDoneToday) {
        // HỦY TÍCH HÔM NAY
        habit.lastChecked = null;
        habit.history[weekdayIndex] = false;
        if (habit.streak > 0) habit.streak--;
      } else {
        // TÍCH MỚI HÔM NAY
        habit.lastChecked = _todayStr;
        habit.lastCheckedWeek = _getWeekNumber(now);
        habit.lastCheckedYear = now.year;
        habit.history[weekdayIndex] = true;
        habit.streak++;
      }

      // Isar cần gán lại List mới để nhận diện thay đổi bên trong mảng bool
      habit.history = List.from(habit.history);
      await _isarService.isar.habitModels.put(habit);
    });

    // Load lại để đảm bảo UI và logic đồng bộ
    await loadHabits();
  }

  // Helper lấy số tuần trong năm (ISO 8601)
  int _getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int w = ((dayOfYear - date.weekday + 10) / 7).floor();
    if (w < 1) return 52;
    if (w > 52) return 1;
    return w;
  }

  // --- QUẢN LÝ THÓI QUEN (CRUD) ---
  Future<void> saveHabit(HabitModel habit) async {
    await _isarService.isar.writeTxn(() async {
      if (habit.history.length < 7) {
        habit.history = [false, false, false, false, false, false, false];
      }
      await _isarService.isar.habitModels.put(habit);
    });
    await loadHabits();
  }

  Future<void> deleteHabit(int id) async {
    await _isarService.isar.writeTxn(() async {
      await _isarService.isar.habitModels.delete(id);
    });
    await loadHabits();
  }
}