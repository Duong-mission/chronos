import 'package:chronos/data/models/calendar_event_model.dart';
import 'package:chronos/data/models/finance_settings_model.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/task_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/habit_model.dart';
import '../../data/models/journal_model.dart';
import 'package:chronos/data/models/category_model.dart';

class IsarService {
  late Isar isar;

  // Khởi tạo Database
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [
        TaskModelSchema,
        TransactionModelSchema,
        CategoryModelSchema,
        HabitModelSchema,
        FinanceSettingsModelSchema,
        JournalModelSchema,
        CalendarEventModelSchema,

      ],
      directory: dir.path,
    );
  }

  // Ví dụ hàm lưu Task (Giống localStorage.setItem)
  Future<void> saveTask(TaskModel newTask) async {
    await isar.writeTxn(() async {
      await isar.taskModels.put(newTask);
    });
  }

  // Ví dụ hàm lấy tất cả Task (Giống localStorage.getItem)
  Future<List<TaskModel>> getAllTasks() async {
    return await isar.taskModels.where().findAll();
  }

  // Hàm xóa dữ liệu (Dùng cho nút Đăng xuất/Xóa sạch)
  Future<void> clearAll() async {
    await isar.writeTxn(() => isar.clear());
  }
}