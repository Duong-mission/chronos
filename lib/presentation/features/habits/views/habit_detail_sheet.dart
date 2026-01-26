import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Sử dụng package import để đồng bộ dữ liệu toàn app
import 'package:chronos/core/constants/app_colors.dart';
import 'package:chronos/core/constants/app_constants.dart';
import 'package:chronos/core/components/glass_input.dart';
import 'package:chronos/core/components/neon_button.dart';
import 'package:chronos/data/models/habit_model.dart';
import 'package:chronos/presentation/features/habits/view_models/habits_view_model.dart';

class HabitDetailSheet extends StatefulWidget {
  final HabitModel? habit;
  const HabitDetailSheet({super.key, this.habit});

  @override
  State<HabitDetailSheet> createState() => _HabitDetailSheetState();
}

class _HabitDetailSheetState extends State<HabitDetailSheet> {
  final _nameController = TextEditingController();
  final _goalController = TextEditingController();

  // State cho Icon và Màu sắc
  late int _selectedIcon;
  late String _selectedColor;

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị ban đầu (nếu sửa thì lấy từ habit, nếu mới thì lấy mặc định)
    _nameController.text = widget.habit?.name ?? '';
    _goalController.text = widget.habit?.goal ?? '';
    _selectedIcon = widget.habit?.icon ?? Icons.water_drop.codePoint;
    _selectedColor = widget.habit?.color ?? '#19f073';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<HabitsViewModel>();

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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh kéo giả
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.habit == null ? "THÓI QUEN MỚI" : "SỬA THÓI QUEN",
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 1),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 1. Nhập tên thói quen
            GlassInput(
              label: "Tên thói quen",
              hint: "Ví dụ: Đọc sách, Tập gym...",
              controller: _nameController,
            ),

            const SizedBox(height: 16),

            // 2. Nhập mục tiêu
            GlassInput(
              label: "Mục tiêu ngắn gọn",
              hint: "Ví dụ: 30 phút mỗi ngày",
              controller: _goalController,
            ),

            const SizedBox(height: 24),

            // 3. BỘ CHỌN BIỂU TƯỢNG (ICON PICKER)
            const Text(
                "BIỂU TƯỢNG",
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 55,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: AppConstants.habitIcons.length,
                itemBuilder: (context, i) {
                  final iconData = AppConstants.habitIcons[i];
                  bool isSelected = _selectedIcon == iconData.codePoint;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = iconData.codePoint),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 55,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected ? AppColors.neonShadow : null,
                      ),
                      child: Icon(
                        iconData,
                        color: isSelected ? AppColors.backgroundDark : Colors.grey,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // 4. BỘ CHỌN MÀU SẮC (COLOR PICKER)
            const Text(
                "MÀU SẮC",
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: AppConstants.habitColors.map((color) {
                // Chuyển Color sang Hex String để lưu trữ
                String hex = '#${color.value.toRadixString(16).substring(2)}';
                bool isSelected = _selectedColor == hex;

                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10)] : null,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // 5. NÚT LƯU
            NeonButton(
                text: "LƯU THÓI QUEN",
                onPressed: () {
                  if (_nameController.text.isEmpty) return;

                  final h = widget.habit ?? HabitModel();
                  h.name = _nameController.text.trim();
                  h.goal = _goalController.text.trim();
                  h.icon = _selectedIcon;
                  h.color = _selectedColor;

                  vm.saveHabit(h);
                  Navigator.pop(context);
                }
            ),

            // 6. NÚT XÓA (Chỉ hiện khi đang sửa)
            if (widget.habit != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextButton(
                    onPressed: () => _showDeleteConfirm(context, vm),
                    child: const Text(
                        "XÓA THÓI QUEN",
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, HabitsViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Xóa thói quen?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text("Toàn bộ lịch sử và chuỗi ngày (streak) của thói quen này sẽ bị mất vĩnh viễn."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("HỦY", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              vm.deleteHabit(widget.habit!.id);
              Navigator.pop(context); // Đóng dialog
              Navigator.pop(context); // Đóng bottom sheet
            },
            child: const Text("XÓA", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}