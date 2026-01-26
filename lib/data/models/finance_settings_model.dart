import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

// File này sẽ được sinh ra sau khi chạy build_runner
part 'finance_settings_model.g.dart';

@embedded
class FinanceCategory {
  // ID dạng chuỗi để đồng bộ với React (ví dụ: 'fe1', 'fi1')
  String? id;
  String? name;

  // ĐỔI THÀNH int để lưu codePoint của Icon (Sửa lỗi Invalid radix-10)
  int? icon;

  String? color;

  // Constructor mặc định bắt buộc cho Isar Embedded
  FinanceCategory();

  // Tiện ích tạo nhanh đối tượng với icon kiểu int
  static FinanceCategory create(String id, String name, int icon, String color) {
    return FinanceCategory()
      ..id = id
      ..name = name
      ..icon = icon
      ..color = color;
  }
}

@collection
class FinanceSettingsModel {
  // Luôn cố định ID = 0 để đảm bảo chỉ có duy nhất 1 bản ghi cấu hình (Singleton)
  Id id = 0;

  // Ngân sách hàng tháng
  double budget = 0;

  // Danh sách danh mục chi tiêu
  List<FinanceCategory>? expenseCategories;

  // Danh sách danh mục thu nhập
  List<FinanceCategory>? incomeCategories;

  // --- LOGIC KHỞI TẠO MẶC ĐỊNH (SỬ DỤNG CODEPOINT CỦA FLUTTER ICONS) ---

  void loadDefaults() {
    expenseCategories = [
      FinanceCategory.create('fe1', 'Ăn uống', Icons.restaurant.codePoint, '#19f073'),
      FinanceCategory.create('fe2', 'Đi lại', Icons.directions_bus.codePoint, '#3b82f6'),
      FinanceCategory.create('fe3', 'Học tập', Icons.school.codePoint, '#8b5cf6'),
      FinanceCategory.create('fe4', 'Nhà ở', Icons.home.codePoint, '#f59e0b'),
      FinanceCategory.create('fe5', 'Giải trí', Icons.videogame_asset.codePoint, '#ec4899'),
      FinanceCategory.create('fe6', 'Sức khỏe', Icons.medical_services.codePoint, '#ef4444'),
      FinanceCategory.create('fe7', 'Khác', Icons.more_horiz.codePoint, '#94a3b8'),
    ];

    incomeCategories = [
      FinanceCategory.create('fi1', 'Lương/Thưởng', Icons.payments.codePoint, '#10b981'),
      FinanceCategory.create('fi2', 'Trợ cấp', Icons.family_restroom.codePoint, '#06b6d4'),
      FinanceCategory.create('fi3', 'Làm thêm', Icons.work.codePoint, '#8b5cf6'),
      FinanceCategory.create('fi4', 'Khác', Icons.add_circle.codePoint, '#19f073'),
    ];
  }
}