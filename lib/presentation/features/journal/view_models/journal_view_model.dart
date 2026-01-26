import 'dart:async';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import 'package:chronos/core/database/isar_service.dart';
import 'package:chronos/data/models/journal_model.dart';
import 'package:chronos/data/repositories/ai_repository_impl.dart';

enum JournalViewMode { list, compose }

class JournalViewModel extends ChangeNotifier {
  final IsarService _isarService;
  final AiRepositoryImpl _aiRepo = AiRepositoryImpl();

  // --- DỮ LIỆU NGUỒN ---
  List<JournalModel> _entries = [];      // Danh sách Timeline (Active)
  List<JournalModel> _trashEntries = []; // Danh sách Thùng rác (Deleted)
  JournalViewMode _viewMode = JournalViewMode.list;

  // Biến theo dõi bài viết đang được chỉnh sửa (null nếu là viết mới)
  JournalModel? _editingEntry;

  // --- TRẠNG THÁI SOẠN THẢO ---
  List<String> _selectedMoods = [];
  List<String> _selectedActivities = [];
  String _content = "";
  int _productivityScore = 5;
  String _location = "";

  // --- TRẠNG THÁI AI ---
  bool _isAnalyzing = false;
  String? _aiReflection;

  // --- GETTERS ---
  List<JournalModel> get entries => _entries;
  List<JournalModel> get trashEntries => _trashEntries;
  JournalViewMode get viewMode => _viewMode;
  JournalModel? get editingEntry => _editingEntry;

  List<String> get selectedMoods => _selectedMoods;
  List<String> get selectedActivities => _selectedActivities;
  String get content => _content;
  int get productivityScore => _productivityScore;
  bool get isAnalyzing => _isAnalyzing;
  String? get aiReflection => _aiReflection;

  bool get canSave => _selectedMoods.isNotEmpty ||
      _selectedActivities.isNotEmpty ||
      _content.trim().isNotEmpty;

  JournalViewModel(this._isarService) {
    loadEntries();
  }

  // --- 1. TẢI DỮ LIỆU & TỰ ĐỘNG DỌN RÁC ---
  Future<void> loadEntries() async {
    try {
      // Tải danh sách Active (Chưa xóa)
      _entries = await _isarService.isar.journalModels
          .where()
          .filter()
          .isDeletedEqualTo(false)
          .sortByDateDesc()
          .thenByTimeDesc()
          .findAll();

      // Tải danh sách Thùng rác
      _trashEntries = await _isarService.isar.journalModels
          .where()
          .filter()
          .isDeletedEqualTo(true)
          .sortByDeletedAtDesc()
          .findAll();

      // Tự động xóa rác cũ > 30 ngày
      await _purgeOldTrash();

      notifyListeners();
    } catch (e) {
      debugPrint("JOURNAL_LOAD_ERROR: $e");
    }
  }

  // --- 2. LOGIC THAO TÁC: SỬA & XÓA TẠM ---

  // Kích hoạt chế độ Sửa: Nạp dữ liệu cũ vào Form
  void setEditEntry(JournalModel entry) {
    _editingEntry = entry;
    _selectedMoods = List.from(entry.moods);
    _selectedActivities = List.from(entry.activities);
    _content = entry.content;
    _productivityScore = entry.productivityScore ?? 5;
    _location = entry.location ?? "";
    _aiReflection = null;
    _viewMode = JournalViewMode.compose; // Chuyển sang màn hình viết
    notifyListeners();
  }

  // Xóa tạm thời (Đưa vào thùng rác)
  Future<void> softDeleteEntry(int id) async {
    final entry = await _isarService.isar.journalModels.get(id);
    if (entry != null) {
      await _isarService.isar.writeTxn(() async {
        entry.isDeleted = true;
        entry.deletedAt = DateTime.now();
        await _isarService.isar.journalModels.put(entry);
      });
      await loadEntries();
    }
  }

  // Khôi phục bài viết
  Future<void> restoreEntry(int id) async {
    final entry = await _isarService.isar.journalModels.get(id);
    if (entry != null) {
      await _isarService.isar.writeTxn(() async {
        entry.isDeleted = false;
        entry.deletedAt = null;
        await _isarService.isar.journalModels.put(entry);
      });
      await loadEntries();
    }
  }

  // Xóa vĩnh viễn thủ công
  Future<void> hardDeleteEntry(int id) async {
    await _isarService.isar.writeTxn(() async {
      await _isarService.isar.journalModels.delete(id);
    });
    await loadEntries();
  }

  // Quét rác tự động (Hết hạn sau 30 ngày)
  Future<void> _purgeOldTrash() async {
    final now = DateTime.now();
    final List<int> idsToDelete = [];

    for (var entry in _trashEntries) {
      if (entry.deletedAt != null) {
        final daysInTrash = now.difference(entry.deletedAt!).inDays;
        if (daysInTrash >= 30) {
          idsToDelete.add(entry.id);
        }
      }
    }

    if (idsToDelete.isNotEmpty) {
      await _isarService.isar.writeTxn(() async {
        await _isarService.isar.journalModels.deleteAll(idsToDelete);
      });
      _trashEntries = await _isarService.isar.journalModels
          .where()
          .filter()
          .isDeletedEqualTo(true)
          .findAll();
    }
  }

  // --- 3. LOGIC SOẠN THẢO & LƯU ---

  void setViewMode(JournalViewMode mode) {
    _viewMode = mode;
    if (mode == JournalViewMode.list) resetForm();
    notifyListeners();
  }

  void toggleMood(String moodValue) {
    _selectedMoods.contains(moodValue)
        ? _selectedMoods.remove(moodValue)
        : _selectedMoods.add(moodValue);
    notifyListeners();
  }

  void toggleActivity(String activityName) {
    _selectedActivities.contains(activityName)
        ? _selectedActivities.remove(activityName)
        : _selectedActivities.add(activityName);
    notifyListeners();
  }

  void updateContent(String val) {
    _content = val;
    notifyListeners();
  }

  void setProductivityScore(int score) {
    _productivityScore = score;
    notifyListeners();
  }

  // Lưu bài viết (Hỗ trợ cả Thêm mới và Cập nhật)
  Future<void> saveEntry() async {
    if (!canSave) return;

    // Nếu có _editingEntry thì lấy nó (giữ ID), nếu không thì tạo mới
    final entry = _editingEntry ?? JournalModel();

    entry.moods = List.from(_selectedMoods);
    entry.activities = List.from(_selectedActivities);
    entry.content = _content.trim();
    entry.productivityScore = _productivityScore;
    entry.location = _location;
    entry.isDeleted = false;

    // Chỉ cập nhật ngày giờ nếu là bài mới hoàn toàn
    if (_editingEntry == null) {
      entry.date = DateFormat('dd/MM/yyyy').format(DateTime.now());
      entry.time = DateFormat('HH:mm').format(DateTime.now());
    }

    await _isarService.isar.writeTxn(() async {
      await _isarService.isar.journalModels.put(entry);
    });

    resetForm();
    await loadEntries();
    _viewMode = JournalViewMode.list;
  }

  // --- 4. LOGIC AI REFLECTION (GIỮ NGUYÊN) ---

  Future<void> handleReflect() async {
    if (_content.isEmpty && _selectedMoods.isEmpty) return;

    _isAnalyzing = true;
    _aiReflection = null;
    notifyListeners();

    try {
      final currentData = {
        'nội_dung': _content,
        'cảm_xúc': _selectedMoods,
        'hoạt_động': _selectedActivities,
        'điểm_hiệu_suất': _productivityScore
      };
      _aiReflection = await _aiRepo.analyzeMoodTrend([currentData]);
    } catch (e) {
      _aiReflection = "AI đang gặp chút trục trặc, nhưng bạn đã làm rất tốt khi dành thời gian lắng nghe bản thân!";
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  void resetForm() {
    _editingEntry = null;
    _selectedMoods = [];
    _selectedActivities = [];
    _content = "";
    _productivityScore = 5;
    _location = "";
    _aiReflection = null;
    _isAnalyzing = false;
  }
}