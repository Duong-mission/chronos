import 'package:isar/isar.dart';

// File này sẽ được tự động sinh ra sau khi chạy build_runner
part 'transaction_model.g.dart';

@collection
class TransactionModel {
  // ID tự động tăng của Isar
  Id id = Isar.autoIncrement;

  // Số tiền giao dịch
  late double amount;

  // Nội dung ghi chú (Ví dụ: Ăn trưa, Lương tháng 12...)
  late String content;

  // Tên danh mục (Ví dụ: Ăn uống, Di chuyển...)
  late String category;

  // Ngày giao dịch (Định dạng: YYYY-MM-DD)
  // Đánh Index để thực hiện sắp xếp và lọc theo thời gian mượt mà
  @Index()
  late String date;

  // Loại giao dịch: 'expense' (Chi tiêu) hoặc 'income' (Thu nhập)
  late String type;

  // Lưu icon/màu sắc tại thời điểm giao dịch để hiển thị nhanh
  String? iconCode;
  String? colorHex;

  // --- LOGIC THÙNG RÁC (PHẦN MỚI BỔ SUNG) ---

  // Trạng thái xóa tạm thời.
  // Thêm Index vì chúng ta sẽ lọc (filter) theo trường này rất nhiều
  // (ví dụ: chỉ hiện các mục isDeleted == false ở màn hình chính)
  @Index()
  bool isDeleted = false;

  // Lưu mốc thời gian khi người dùng nhấn "Xóa".
  // Dùng để tính toán logic tự động xóa vĩnh viễn sau 30 ngày.
  DateTime? deletedAt;
}