import 'package:isar/isar.dart';

// File này sẽ được sinh ra sau khi chạy build_runner
part 'calendar_event_model.g.dart';

@collection
class CalendarEventModel {
  // ID tự động tăng của Isar (kiểu int)
  Id id = Isar.autoIncrement;

  // ID dạng chuỗi để đồng bộ logic với React (Date.now().toString())
  @Index()
  String? eventId;

  late String title;

  // Đánh dấu Index cho date vì chúng ta lọc theo ngày rất nhiều
  @Index()
  late String date; // Định dạng: YYYY-MM-DD

  late String time; // Định dạng: HH:mm

  late String type; // Ví dụ: 'Học tập', 'Sức khỏe', 'Quan trọng', 'Cá nhân'

  late String color; // Lưu mã màu Hex (Ví dụ: #3b82f6)

  // Bạn có thể thêm trường này nếu muốn mở rộng sau này,
  // hiện tại để optional để giống React nhất
  String? description;
}