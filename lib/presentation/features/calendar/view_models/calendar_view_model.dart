import 'dart:async'; // Thêm import này để dùng StreamSubscription
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import 'package:chronos/core/database/isar_service.dart';
import 'package:chronos/data/models/task_model.dart';
import 'package:chronos/data/models/calendar_event_model.dart';

enum CalendarViewMode { day, threeDays, week, month }

class CalendarViewModel extends ChangeNotifier {
  final IsarService _isarService;

  // Quản lý các "đường dây" lắng nghe Database
  StreamSubscription? _taskSubscription;
  StreamSubscription? _eventSubscription;

  CalendarViewMode _viewMode = CalendarViewMode.threeDays;
  DateTime _selectedDate = DateTime.now();
  List<CalendarEventModel> _events = [];
  List<TaskModel> _tasks = [];

  CalendarViewModel(this._isarService) {
    loadData();
    _startWatching(); // Bắt đầu theo dõi sự thay đổi của DB
  }

  // --- LOGIC QUAN TRỌNG: TỰ ĐỘNG CẬP NHẬT ---
  void _startWatching() {
    // Lắng nghe bảng Task: Hễ có ai thêm/xóa/sửa Task là hàm loadData() tự chạy
    _taskSubscription = _isarService.isar.taskModels.watchLazy().listen((_) {
      print("CALENDAR_LOG: Phát hiện thay đổi ở bảng Task, đang cập nhật lịch...");
      loadData();
    });

    // Lắng nghe bảng Event
    _eventSubscription = _isarService.isar.calendarEventModels.watchLazy().listen((_) {
      print("CALENDAR_LOG: Phát hiện thay đổi ở bảng Event, đang cập nhật lịch...");
      loadData();
    });
  }

  @override
  void dispose() {
    // Hủy lắng nghe khi không dùng nữa để tránh rò rỉ bộ nhớ
    _taskSubscription?.cancel();
    _eventSubscription?.cancel();
    super.dispose();
  }

  // --- CÁC LOGIC CŨ GIỮ NGUYÊN ---

  CalendarViewMode get viewMode => _viewMode;
  DateTime get selectedDate => _selectedDate;
  String get selectedDateStr => DateFormat('yyyy-MM-dd').format(_selectedDate);

  void setViewMode(CalendarViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void navigate(int direction) {
    if (_viewMode == CalendarViewMode.month) {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + direction, 1);
    } else {
      int step = (_viewMode == CalendarViewMode.day) ? 1 : (_viewMode == CalendarViewMode.threeDays ? 3 : 7);
      _selectedDate = _selectedDate.add(Duration(days: step * direction));
    }
    notifyListeners();
  }

  List<DateTime> get currentRangeDays {
    List<DateTime> days = [];
    if (_viewMode == CalendarViewMode.day) {
      days.add(_selectedDate);
    } else if (_viewMode == CalendarViewMode.threeDays) {
      for (int i = 0; i < 3; i++) days.add(_selectedDate.add(Duration(days: i)));
    } else if (_viewMode == CalendarViewMode.week) {
      int weekday = _selectedDate.weekday;
      DateTime startOfWeek = _selectedDate.subtract(Duration(days: weekday - 1));
      for (int i = 0; i < 7; i++) days.add(startOfWeek.add(Duration(days: i)));
    }
    return days;
  }

  List<DateTime?> get monthGridDays {
    final firstDay = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDay = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    List<DateTime?> grid = [];
    int padding = firstDay.weekday - 1;
    for (int i = 0; i < padding; i++) grid.add(null);
    for (int i = 1; i <= lastDay.day; i++) grid.add(DateTime(_selectedDate.year, _selectedDate.month, i));
    return grid;
  }

  Future<void> loadData() async {
    _events = await _isarService.isar.calendarEventModels.where().findAll();
    _tasks = await _isarService.isar.taskModels.where().findAll();
    notifyListeners(); // Vẽ lại giao diện Lịch
  }

  List<dynamic> getItemsForDate(String dateStr) {
    final dayEvents = _events.where((e) => e.date == dateStr).toList();
    final dayTasks = _tasks.where((t) => t.startDate == dateStr || t.dueDate == dateStr).toList();
    return [...dayEvents, ...dayTasks];
  }

  Future<void> addEvent(CalendarEventModel event) async {
    await _isarService.isar.writeTxn(() => _isarService.isar.calendarEventModels.put(event));
    // Không cần gọi loadData() ở đây nữa vì watchLazy() sẽ tự gọi giúp mình
  }
}