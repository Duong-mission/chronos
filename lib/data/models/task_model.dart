import 'package:isar/isar.dart';

// Sau khi sửa file này, bạn PHẢI chạy lệnh:
// flutter pub run build_runner build --delete-conflicting-outputs
part 'task_model.g.dart';

@embedded
class SubTaskModel {
  String? id;
  String? title;
  bool completed = false;

  // BỔ SUNG: Cấp độ để vẽ Mind Map (0: Cha, 1: Con, 2: Cháu...)
  // Trong Isar không thể dùng List lồng nhau, nên ta dùng list phẳng
  // kết hợp với "level" để biết vị trí của nó trong sơ đồ tư duy.
  int level = 0;
}

@collection
class TaskModel {
  // ID tự động tăng của Isar
  Id id = Isar.autoIncrement;

  // ID dạng chuỗi đồng bộ với React
  @Index()
  String? taskId;

  late String title;
  String? description;

  // Thời gian thực hiện
  late String startDate;
  late String startTime;

  // Hạn chót
  late String dueDate;
  late String dueTime;

  late String category;
  late String priority; // 'Thấp' | 'Trung bình' | 'Cao'

  // Trạng thái hoàn thành chính
  bool completed = false;

  // BỔ SUNG: Trạng thái thùng rác (để lọc task trong View)
  bool isTrashed = false;

  String? color;

  // Danh sách việc phụ (Checklist)
  // Lưu ý: List này chứa cả cha lẫn con dưới dạng list phẳng.
  // Logic hiển thị Mind Map sẽ dựa vào thứ tự và trường 'level' ở trên.
  List<SubTaskModel>? subtasks;

  String? reminder; // Thời gian nhắc nhở (phút)
  String? repeat;   // 'none' | 'daily' | 'weekly' | 'monthly'
  String? location;
}