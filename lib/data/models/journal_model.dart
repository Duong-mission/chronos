import 'package:isar/isar.dart';

// File này sẽ được tự động sinh ra sau khi chạy build_runner
part 'journal_model.g.dart';

@collection
class JournalModel {
  // ID tự động tăng của Isar (kiểu int)
  Id id = Isar.autoIncrement;

  // Ngày viết nhật ký (Định dạng: dd/MM/yyyy)
  // Thêm Index để truy vấn và sắp xếp Timeline cực nhanh
  @Index()
  late String date;

  // Giờ viết nhật ký (Định dạng: HH:mm)
  late String time;

  // Danh sách các cảm xúc (Lưu các value như: 'great', 'happy', 'tired'...)
  List<String> moods = [];

  // Danh sách các hoạt động (Ví dụ: 'Học tập', 'Thể thao', 'Cà phê'...)
  List<String> activities = [];

  // Nội dung tâm sự chính
  late String content;

  // Danh sách đường dẫn ảnh hoặc chuỗi Base64
  List<String>? images;

  // Vị trí khi viết nhật ký
  String? location;

  // Điểm hiệu suất trong ngày (0-10)
  int? productivityScore;

  // --- LOGIC THÙNG RÁC (PHẦN MỚI BỔ SUNG) ---

  // Trạng thái xóa tạm thời.
  // Thêm Index vì chúng ta lọc theo trường này liên tục (chỉ hiện isDeleted = false ở Timeline)
  @Index()
  bool isDeleted = false;

  // Lưu mốc thời gian khi người dùng nhấn "Xóa".
  // Dùng làm căn cứ để ViewModel tự động xóa vĩnh viễn sau 30 ngày.
  DateTime? deletedAt;

  // Constructor mặc định
  JournalModel();

  // Tiện ích tạo nhanh đối tượng (Giữ nguyên logic tạo nhanh của bạn)
  static JournalModel create({
    required String content,
    List<String> moods = const [],
    List<String> activities = const [],
    int? productivityScore,
    String? location,
  }) {
    final now = DateTime.now();
    return JournalModel()
      ..date = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}"
      ..time = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}"
      ..content = content
      ..moods = moods
      ..activities = activities
      ..productivityScore = productivityScore
      ..location = location
      ..isDeleted = false; // Mặc định không nằm trong thùng rác
  }
}