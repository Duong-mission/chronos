import 'package:isar/isar.dart';

// File này sẽ được tự động sinh ra sau khi chạy build_runner
// Chạy lệnh: dart run build_runner build --delete-conflicting-outputs
part 'habit_model.g.dart';

@collection
class HabitModel {
  // ID tự động tăng của Isar
  Id id = Isar.autoIncrement;

  // Tên thói quen (Ví dụ: Uống nước, Đọc sách...)
  late String name;

  // Mục tiêu ngắn gọn (Ví dụ: 2000ml mỗi ngày)
  late String goal;

  // Chuỗi ngày thực hiện liên tiếp (Streak)
  int streak = 0;

  // Lịch sử thực hiện của 7 ngày TRONG TUẦN HIỆN TẠI
  // BẮT BUỘC: Index 0 là Thứ 2, Index 6 là Chủ Nhật
  // Điều này giúp dấu tích không bị nhảy vị trí khi sang ngày mới
  List<bool> history = [false, false, false, false, false, false, false];

  // Lưu mã codePoint của Icon (Kiểu int)
  late int icon;

  // Lưu mã màu Hex (Ví dụ: #19f073)
  late String color;

  // Ngày cuối cùng thực hiện check-in (Định dạng: YYYY-MM-DD)
  String? lastChecked;

  // --- PHẦN BỔ SUNG THIẾU ---

  // Lưu số thứ tự của tuần (Ví dụ: Tuần thứ 52 trong năm)
  // Dùng để kiểm tra: "Nếu tuần hiện tại khác tuần này -> Reset 7 dấu tích về false"
  int? lastCheckedWeek;

  // Lưu năm cuối cùng check-in
  // Để đảm bảo khi sang năm mới (Tuần 1), app không bị nhầm lẫn với tuần 1 năm cũ
  int? lastCheckedYear;

  // Constructor mặc định
  HabitModel();

  // Tiện ích tạo nhanh đối tượng (Giữ nguyên logic tạo của bạn)
  static HabitModel create({
    required String name,
    required String goal,
    required int icon,
    required String color,
  }) {
    return HabitModel()
      ..name = name
      ..goal = goal
      ..icon = icon
      ..color = color
      ..streak = 0
      ..history = [false, false, false, false, false, false, false];
  }
}