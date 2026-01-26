import 'package:isar/isar.dart';

// File này sẽ được sinh ra sau khi chạy build_runner
part 'category_model.g.dart';

@collection
class CategoryModel {
  // ID tự động tăng của Isar
  Id id = Isar.autoIncrement;

  // Tên danh mục (Đánh dấu Unique để không bị trùng tên)
  @Index(unique: true, replace: true)
  late String name;

  // Icon mặc định (Sử dụng tên icon từ Material Symbols)
  String icon = 'folder';

  // Màu sắc đại diện (Lưu dưới dạng mã hex int)
  int? color;
}