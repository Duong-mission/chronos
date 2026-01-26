import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:chronos/core/database/isar_service.dart';
import 'package:chronos/data/models/task_model.dart';
import 'package:chronos/data/models/category_model.dart';
import 'package:chronos/data/repositories/ai_repository_impl.dart';

class TasksViewModel extends ChangeNotifier {
  final IsarService _isarService;
  final AiRepositoryImpl _aiRepo = AiRepositoryImpl();

  // Dữ liệu nguồn
  List<TaskModel> _allTasks = [];
  List<CategoryModel> _categories = [];

  // Trạng thái UI
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';
  bool _isPlanning = false;
  String? _loadingSubtaskId; // Theo dõi subtask nào đang được AI phân rã (nếu cần)

  // Getters
  List<CategoryModel> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  bool get isPlanning => _isPlanning;
  String? get loadingSubtaskId => _loadingSubtaskId;
  List<TaskModel> get allTasks => _allTasks;

  TasksViewModel(this._isarService) {
    _init();
  }

  Future<void> _init() async {
    await initCategories();
    await loadTasks();
  }

  // ============================================================
  // 1. LOGIC LỌC (FILTERING)
  // ============================================================

  List<TaskModel> get ongoingTasks {
    return _allTasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCat = _selectedCategory == 'Tất cả' || task.category == _selectedCategory;
      // Chỉ lấy task CHƯA XONG và KHÔNG TRONG THÙNG RÁC
      return !task.completed && !task.isTrashed && matchesSearch && matchesCat;
    }).toList();
  }

  List<TaskModel> get completedTasks {
    return _allTasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCat = _selectedCategory == 'Tất cả' || task.category == _selectedCategory;
      // Chỉ lấy task ĐÃ XONG và KHÔNG TRONG THÙNG RÁC
      return task.completed && !task.isTrashed && matchesSearch && matchesCat;
    }).toList();
  }

  // Lấy danh sách task trong thùng rác
  List<TaskModel> get trashedTasks {
    return _allTasks.where((task) => task.isTrashed).toList();
  }

  // ============================================================
  // 2. QUẢN LÝ CÔNG VIỆC (CRUD)
  // ============================================================

  Future<void> loadTasks() async {
    _allTasks = await _isarService.isar.taskModels.where().findAll();
    notifyListeners();
  }

  Future<void> saveTask(TaskModel task) async {
    await _isarService.isar.writeTxn(() async {
      await _isarService.isar.taskModels.put(task);
    });
    await loadTasks();
  }

  // Chuyển vào thùng rác (Soft Delete)
  Future<void> moveToTrash(TaskModel task) async {
    task.isTrashed = true;
    await saveTask(task);
  }

  // Khôi phục từ thùng rác
  Future<void> restoreTask(TaskModel task) async {
    task.isTrashed = false;
    await saveTask(task);
  }

  // Xóa vĩnh viễn
  Future<void> deletePermanently(int id) async {
    await _isarService.isar.writeTxn(() async {
      await _isarService.isar.taskModels.delete(id);
    });
    await loadTasks();
  }

  Future<void> toggleTask(TaskModel task) async {
    task.completed = !task.completed;
    await saveTask(task);
  }

  Future<void> toggleSubTask(TaskModel task, String subTaskId) async {
    if (task.subtasks == null) return;
    final index = task.subtasks!.indexWhere((st) => st.id == subTaskId);
    if (index != -1) {
      task.subtasks![index].completed = !task.subtasks![index].completed;
      // Isar cần gán lại list để nhận diện thay đổi bên trong embedded object
      task.subtasks = List.from(task.subtasks!);
      await saveTask(task);
    }
  }

  // ============================================================
  // 3. LOGIC AI (CẢI TIẾN STEP-BY-STEP & HYBRID)
  // ============================================================

  /// [MỚI] BƯỚC 1: Lấy các giai đoạn chính (Main Phases)
  /// Hàm này bật loading toàn màn hình (_isPlanning) vì đây là bước khởi tạo đầu tiên.
  Future<List<SubTaskModel>> fetchMainPhases(String goal) async {
    _isPlanning = true;
    notifyListeners();
    try {
      final result = await _aiRepo.getMainPhases(goal);
      _isPlanning = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isPlanning = false;
      notifyListeners();
      return [];
    }
  }

  /// [MỚI] BƯỚC 2: Lấy chi tiết con (Sub Steps) kèm Context
  /// Hàm này KHÔNG bật loading toàn màn hình để hỗ trợ Streaming ngầm (hiện dần dần).
  Future<List<SubTaskModel>> fetchSubSteps(String parentTitle, String contextGoal) async {
    return await _aiRepo.getSubStepsFor(parentTitle, contextGoal);
  }

  /// [CŨ/HYBRID] Logic phân rã One-shot
  /// Giữ lại hàm này để hỗ trợ các tính năng cũ hoặc nút Bolt (Deep Dive) nếu cần logic tổng quát.
  Future<List<SubTaskModel>> decomposeTask(String title) async {
    if (title.trim().isEmpty) return [];
    _isPlanning = true;
    notifyListeners();

    try {
      final steps = await _aiRepo.getDecomposedSubTasks(title);
      _isPlanning = false;
      notifyListeners();
      return steps;
    } catch (e) {
      _isPlanning = false;
      notifyListeners();
      return [];
    }
  }

  // ============================================================
  // 4. QUẢN LÝ DANH MỤC
  // ============================================================

  Future<void> initCategories() async {
    _categories = await _isarService.isar.categoryModels.where().findAll();
    if (_categories.isEmpty) {
      final defaultNames = ['Học tập', 'Sức khỏe', 'Cá nhân', 'Tài chính'];
      await _isarService.isar.writeTxn(() async {
        for (var name in defaultNames) {
          await _isarService.isar.categoryModels.put(CategoryModel()..name = name);
        }
      });
      _categories = await _isarService.isar.categoryModels.where().findAll();
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> addCategory(String name) async {
    if (name.trim().isEmpty) return;
    await _isarService.isar.writeTxn(() async {
      await _isarService.isar.categoryModels.put(CategoryModel()..name = name.trim());
    });
    await initCategories();
  }

  Future<void> deleteCategory(int id) async {
    await _isarService.isar.writeTxn(() async {
      await _isarService.isar.categoryModels.delete(id);
    });
    await initCategories();
  }
}