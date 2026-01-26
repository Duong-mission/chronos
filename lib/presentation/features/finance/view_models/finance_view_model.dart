import 'dart:async';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
// import 'package:intl/intl.dart';
import 'package:chronos/core/database/isar_service.dart';
import 'package:chronos/data/models/transaction_model.dart';
import 'package:chronos/data/models/finance_settings_model.dart';
import 'package:chronos/data/repositories/ai_repository_impl.dart';

class FinanceViewModel extends ChangeNotifier {
  final IsarService _isarService;
  final AiRepositoryImpl _aiRepo = AiRepositoryImpl();

  // --- DỮ LIỆU NGUỒN ---
  List<TransactionModel> _allActiveTransactions = []; // Chỉ các mục chưa xóa
  List<TransactionModel> _trashTransactions = [];     // Các mục trong thùng rác
  FinanceSettingsModel _settings = FinanceSettingsModel();

  // --- TRẠNG THÁI UI ---
  int _selectedYear = DateTime.now().year;
  String? _aiAdvice;
  bool _isAiLoading = false;

  // --- GETTERS ---
  List<TransactionModel> get transactions => _allActiveTransactions;
  List<TransactionModel> get trashTransactions => _trashTransactions;
  double get budget => _settings.budget;
  List<FinanceCategory> get expenseCategories => _settings.expenseCategories ?? [];
  List<FinanceCategory> get incomeCategories => _settings.incomeCategories ?? [];
  String? get aiAdvice => _aiAdvice;
  bool get isAiLoading => _isAiLoading;
  int get selectedYear => _selectedYear;

  FinanceViewModel(this._isarService) {
    loadData();
  }

  // --- 1. TẢI DỮ LIỆU & TỰ ĐỘNG DỌN RÁC ---
  Future<void> loadData() async {
    try {
      // A. Tải cấu hình Settings
      var settings = await _isarService.isar.financeSettingsModels.get(0);
      if (settings == null) {
        settings = FinanceSettingsModel()..loadDefaults();
        await _isarService.isar.writeTxn(() => _isarService.isar.financeSettingsModels.put(settings!));
      }
      _settings = settings;

      // B. Tải giao dịch HOẠT ĐỘNG (isDeleted == false)
      _allActiveTransactions = await _isarService.isar.transactionModels
          .where()
          .filter()
          .isDeletedEqualTo(false)
          .sortByDateDesc()
          .findAll();

      // C. Tải giao dịch TRONG THÙNG RÁC (isDeleted == true)
      _trashTransactions = await _isarService.isar.transactionModels
          .where()
          .filter()
          .isDeletedEqualTo(true)
          .sortByDeletedAtDesc()
          .findAll();

      // D. TỰ ĐỘNG QUÉT RÁC CŨ (> 30 NGÀY)
      await _purgeOldTrash();

      notifyListeners();
    } catch (e) {
      debugPrint("FINANCE_LOAD_ERROR: $e");
    }
  }

  // --- 2. LOGIC THÙNG RÁC (MỚI BỔ SUNG) ---

  // Xóa tạm thời (Đưa vào thùng rác)
  Future<void> softDeleteTransaction(int id) async {
    final transaction = await _isarService.isar.transactionModels.get(id);
    if (transaction != null) {
      await _isarService.isar.writeTxn(() async {
        transaction.isDeleted = true;
        transaction.deletedAt = DateTime.now();
        await _isarService.isar.transactionModels.put(transaction);
      });
      await loadData();
    }
  }

  // Khôi phục từ thùng rác
  Future<void> restoreTransaction(int id) async {
    final transaction = await _isarService.isar.transactionModels.get(id);
    if (transaction != null) {
      await _isarService.isar.writeTxn(() async {
        transaction.isDeleted = false;
        transaction.deletedAt = null; // Xóa mốc thời gian xóa
        await _isarService.isar.transactionModels.put(transaction);
      });
      await loadData();
    }
  }

  // Xóa vĩnh viễn thủ công
  Future<void> hardDeleteTransaction(int id) async {
    await _isarService.isar.writeTxn(() async {
      await _isarService.isar.transactionModels.delete(id);
    });
    await loadData();
  }

  // Logic tự động xóa sau 30 ngày
  Future<void> _purgeOldTrash() async {
    final now = DateTime.now();
    final List<int> idsToDelete = [];

    for (var t in _trashTransactions) {
      if (t.deletedAt != null) {
        // Tính khoảng cách ngày
        final difference = now.difference(t.deletedAt!).inDays;
        if (difference >= 30) {
          idsToDelete.add(t.id);
        }
      }
    }

    if (idsToDelete.isNotEmpty) {
      debugPrint("AUTO_PURGE: Đang xóa vĩnh viễn ${idsToDelete.length} mục cũ...");
      await _isarService.isar.writeTxn(() async {
        await _isarService.isar.transactionModels.deleteAll(idsToDelete);
      });
      // Cập nhật lại danh sách rác sau khi xóa tự động
      _trashTransactions = await _isarService.isar.transactionModels
          .where()
          .filter()
          .isDeletedEqualTo(true)
          .findAll();
    }
  }

  // --- 3. LOGIC MÀN HÌNH CHÍNH (CHỈ DÙNG DỮ LIỆU ACTIVE) ---

  List<TransactionModel> get currentMonthTransactions {
    final now = DateTime.now();
    return _allActiveTransactions.where((t) {
      final date = DateTime.tryParse(t.date);
      return date?.month == now.month && date?.year == now.year;
    }).toList();
  }

  double get totalBalanceAllTime => _allActiveTransactions.fold(0.0, (sum, t) =>
  t.type == 'income' ? sum + t.amount : sum - t.amount);

  double get totalExpenseMonth => currentMonthTransactions
      .where((t) => t.type == 'expense')
      .fold(0.0, (sum, t) => sum + t.amount);

  double get budgetPercent => (_settings.budget > 0)
      ? (totalExpenseMonth / _settings.budget) * 100
      : 0.0;

  Map<String, double> get expenseDistributionMonth {
    Map<String, double> data = {};
    for (var t in currentMonthTransactions.where((t) => t.type == 'expense')) {
      data[t.category] = (data[t.category] ?? 0.0) + t.amount;
    }
    return data;
  }

  // --- 4. LOGIC KHO LƯU TRỮ (CHỈ DÙNG DỮ LIỆU ACTIVE) ---

  void setSelectedYear(int year) {
    if (_selectedYear != year) {
      _selectedYear = year;
      notifyListeners();
    }
  }

  double get yearlyBalance {
    final yearTrans = _allActiveTransactions.where((t) => DateTime.tryParse(t.date)?.year == _selectedYear);
    double income = yearTrans.where((t) => t.type == 'income').fold(0.0, (sum, t) => sum + t.amount);
    double expense = yearTrans.where((t) => t.type == 'expense').fold(0.0, (sum, t) => sum + t.amount);
    return income - expense;
  }

  Map<String, double> get yearlySummary {
    final yearTrans = _allActiveTransactions.where((t) => DateTime.tryParse(t.date)?.year == _selectedYear);
    return {
      'income': yearTrans.where((t) => t.type == 'income').fold(0.0, (sum, t) => sum + t.amount),
      'expense': yearTrans.where((t) => t.type == 'expense').fold(0.0, (sum, t) => sum + t.amount),
    };
  }

  List<Map<String, dynamic>> getMonthlyChartData() {
    final months = ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'T10', 'T11', 'T12'];
    return List.generate(12, (i) {
      final monthTrans = _allActiveTransactions.where((t) {
        final date = DateTime.tryParse(t.date);
        return date?.year == _selectedYear && date?.month == (i + 1);
      });
      return {
        'name': months[i],
        'thu': monthTrans.where((t) => t.type == 'income').fold(0.0, (s, t) => s + t.amount) / 1000,
        'chi': monthTrans.where((t) => t.type == 'expense').fold(0.0, (s, t) => s + t.amount) / 1000,
      };
    });
  }

  // --- 5. QUẢN LÝ DANH MỤC & THÊM MỚI ---

  Future<void> addTransaction(TransactionModel t) async {
    await _isarService.isar.writeTxn(() => _isarService.isar.transactionModels.put(t));
    await loadData();
  }

  Future<void> updateBudget(double newBudget) async {
    _settings.budget = newBudget;
    await _isarService.isar.writeTxn(() => _isarService.isar.financeSettingsModels.put(_settings));
    await loadData();
  }

  Future<void> addFinanceCategory(String name, int iconCode, String color, bool isExpense) async {
    final newCat = FinanceCategory.create(
        DateTime.now().millisecondsSinceEpoch.toString(), name.trim(), iconCode, color);
    if (isExpense) {
      _settings.expenseCategories = [...(_settings.expenseCategories ?? []), newCat];
    } else {
      _settings.incomeCategories = [...(_settings.incomeCategories ?? []), newCat];
    }
    await _isarService.isar.writeTxn(() => _isarService.isar.financeSettingsModels.put(_settings));
    await loadData();
  }

  Future<void> deleteFinanceCategory(String id, bool isExpense) async {
    if (isExpense) {
      _settings.expenseCategories = _settings.expenseCategories?.where((c) => c.id != id).toList();
    } else {
      _settings.incomeCategories = _settings.incomeCategories?.where((c) => c.id != id).toList();
    }
    await _isarService.isar.writeTxn(() => _isarService.isar.financeSettingsModels.put(_settings));
    await loadData();
  }

  // --- 6. AI ADVICE ---
  Future<void> getAiAdvice() async {
    if (_allActiveTransactions.isEmpty) return;
    _isAiLoading = true;
    notifyListeners();
    try {
      final recentData = _allActiveTransactions.take(15).toList();
      _aiAdvice = await _aiRepo.fetchFinancialAdvice(recentData, _settings.budget);
    } catch (e) {
      _aiAdvice = "AI không thể phân tích lúc này.";
    } finally {
      _isAiLoading = false;
      notifyListeners();
    }
  }
}