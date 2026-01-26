import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Sử dụng package import để đồng bộ dữ liệu
import 'package:chronos/core/constants/app_colors.dart';
import 'package:chronos/core/components/glass_input.dart';
import 'package:chronos/presentation/features/tasks/view_models/tasks_view_model.dart';

class CategoryMgmtSheet extends StatefulWidget {
  const CategoryMgmtSheet({super.key});

  @override
  State<CategoryMgmtSheet> createState() => _CategoryMgmtSheetState();
}

class _CategoryMgmtSheetState extends State<CategoryMgmtSheet> {
  final TextEditingController _catController = TextEditingController();

  @override
  void dispose() {
    _catController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // SỬ DỤNG watch: Khi ViewModel gọi notifyListeners(), Widget này sẽ vẽ lại ngay lập tức
    final viewModel = context.watch<TasksViewModel>();

    return Container(
      // Xử lý đẩy giao diện lên khi bàn phím xuất hiện
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        left: 24,
        right: 24,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thanh kéo giả (Handle bar) giống các App hiện đại
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Tiêu đề Modal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "QUẢN LÝ DANH MỤC",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.grey, size: 20),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Ô nhập danh mục mới (Row thêm mới)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: GlassInput(
                  label: "Tên danh mục mới",
                  hint: "Ví dụ: Giải trí, Việc nhà...",
                  controller: _catController,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 56,
                margin: const EdgeInsets.only(bottom: 2),
                child: ElevatedButton(
                  onPressed: () {
                    if (_catController.text.trim().isNotEmpty) {
                      viewModel.addCategory(_catController.text);
                      _catController.clear();
                      // Ẩn bàn phím sau khi thêm thành công
                      FocusScope.of(context).unfocus();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Icon(Icons.add, color: AppColors.backgroundDark),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Tiêu đề danh sách
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "DANH SÁCH HIỆN TẠI",
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey,
                  letterSpacing: 1.2
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Danh sách danh mục (Sử dụng Flexible để tránh lỗi tràn màn hình)
          Flexible(
            child: viewModel.categories.isEmpty
                ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text("Chưa có danh mục nào", style: TextStyle(color: Colors.white24)),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: viewModel.categories.length,
              itemBuilder: (context, index) {
                final cat = viewModel.categories[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.folder_open, size: 18, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(
                            cat.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () => _showDeleteConfirm(context, viewModel, cat),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Hàm hiển thị xác nhận xóa (UX tốt hơn)
  void _showDeleteConfirm(BuildContext context, TasksViewModel vm, dynamic cat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Xóa danh mục?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text("Các công việc thuộc danh mục '${cat.name}' sẽ không bị xóa nhưng sẽ mất phân loại."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("HỦY", style: TextStyle(color: Colors.grey))
          ),
          TextButton(
            onPressed: () {
              vm.deleteCategory(cat.id);
              Navigator.pop(context);
            },
            child: const Text("XÓA", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}