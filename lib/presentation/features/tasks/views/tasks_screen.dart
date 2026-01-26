import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chronos/core/constants/app_colors.dart';
import 'package:chronos/core/components/chronos_header.dart';
import 'package:chronos/core/components/chronos_card.dart';
import 'package:chronos/core/components/priority_badge.dart';
import 'package:chronos/data/models/task_model.dart';
import 'package:chronos/presentation/features/tasks/view_models/tasks_view_model.dart';
import 'package:chronos/presentation/features/tasks/views/task_detail_sheet.dart';
import 'package:chronos/presentation/features/tasks/views/category_mgmt_sheet.dart';
import 'package:chronos/presentation/features/tasks/views/mind_map_view.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _showCompleted = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TasksViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // 1. HEADER CHUẨN (Đồng nhất hoàn toàn với các tab khác)
              const ChronosHeader(
                title: "Việc làm",
                subtitle: "Lộ trình chinh phục mục tiêu",
              ),

              // 2. THANH TÌM KIẾM & THÊM NHANH
              _buildSearchAndAddRow(context, viewModel),
              const SizedBox(height: 20),

              // 3. BỘ LỌC + THÙNG RÁC + CÀI ĐẶT (Giao diện quản lý tập trung)
              _buildManagementRow(context, viewModel),
              const SizedBox(height: 20),

              // 4. DANH SÁCH NHIỆM VỤ
              Expanded(
                child: viewModel.ongoingTasks.isEmpty && viewModel.completedTasks.isEmpty
                    ? _buildEmptyState()
                    : ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Task đang thực hiện
                    ...viewModel.ongoingTasks.map((task) => _buildTaskItem(context, task, viewModel)),

                    // Task đã hoàn thành (Collapsible)
                    if (viewModel.completedTasks.isNotEmpty) ...[
                      _buildCompletedToggle(viewModel.completedTasks.length),
                      if (_showCompleted)
                        ...viewModel.completedTasks.map((task) => _buildTaskItem(context, task, viewModel)),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildManagementRow(BuildContext context, TasksViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildCatChip(vm, "Tất cả"),
                ...vm.categories.map((cat) => _buildCatChip(vm, cat.name)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Nút Thùng rác (Có Badge báo hiệu)
        _buildIconBtn(
          icon: Icons.delete_sweep_outlined,
          color: vm.trashedTasks.isNotEmpty ? Colors.redAccent : Colors.grey,
          onTap: () => _showTrashModal(context, vm),
          hasBadge: vm.trashedTasks.isNotEmpty,
        ),

        const SizedBox(width: 8),

        // Nút Cài đặt danh mục
        _buildIconBtn(
          icon: Icons.settings_outlined,
          color: Colors.grey,
          onTap: () => _showCategoryMgmt(context),
        ),
      ],
    );
  }

  Widget _buildIconBtn({required IconData icon, required Color color, required VoidCallback onTap, bool hasBadge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Stack(
          children: [
            Icon(icon, color: color, size: 18),
            if (hasBadge)
              Positioned(
                right: 0, top: 0,
                child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskModel task, TasksViewModel vm) {
    // TÍNH TOÁN TIẾN ĐỘ
    double progress = 0;
    if (task.subtasks != null && task.subtasks!.isNotEmpty) {
      int done = task.subtasks!.where((s) => s.completed).length;
      progress = done / task.subtasks!.length;
    }

    return GestureDetector(
      // NHẤN GIỮ ĐỂ XEM SƠ ĐỒ TƯ DUY (MIND MAP)
      onLongPress: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MindMapView(task: task))),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ChronosCard(
          padding: 0, // Để thanh tiến trình sát mép dưới
          showNeon: task.priority == 'Cao' && !task.completed,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: task.completed,
                      onChanged: (_) => vm.toggleTask(task),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: task.completed ? TextDecoration.lineThrough : null,
                              color: task.completed ? Colors.grey : Colors.white,
                            ),
                          ),

                          // Hiển thị 2 subtask tiêu biểu với thụt lề cấp độ
                          if (task.subtasks != null && task.subtasks!.isNotEmpty)
                            _buildSubtaskPreview(task),

                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              PriorityBadge(priority: task.priority),
                              _buildTaskMeta(Icons.schedule, task.startTime),
                              if (progress > 0) _buildTaskMeta(Icons.donut_large, "${(progress * 100).toInt()}%"),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 18, color: Colors.white24),
                      onPressed: () => _showTaskOptions(context, task, vm),
                    ),
                  ],
                ),
              ),
              // THANH TIẾN TRÌNH NEON SÁT MÉP DƯỚI
              if (!task.completed && progress > 0)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.02),
                    color: AppColors.primary.withOpacity(0.3),
                    minHeight: 3,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtaskPreview(TaskModel task) {
    final display = task.subtasks!.take(2).toList();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: display.map((st) => Padding(
          padding: EdgeInsets.only(left: st.level * 12.0, bottom: 4),
          child: Row(
            children: [
              Icon(Icons.subdirectory_arrow_right, size: 10, color: Colors.white10),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  st.title ?? '',
                  style: const TextStyle(fontSize: 10, color: Colors.white38),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // --- THÙNG RÁC MODAL (REAL-TIME UPDATING) ---

  void _showTrashModal(BuildContext context, TasksViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Consumer<TasksViewModel>( // Cực kỳ quan trọng để cập nhật UI trong Modal
        builder: (context, tasksVM, child) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
            ),
            child: Column(
              children: [
                Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
                const Text("THÙNG RÁC", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
                const SizedBox(height: 24),
                Expanded(
                  child: tasksVM.trashedTasks.isEmpty
                      ? const Center(child: Text("Thùng rác trống", style: TextStyle(color: Colors.white10)))
                      : ListView.builder(
                    itemCount: tasksVM.trashedTasks.length,
                    itemBuilder: (context, i) {
                      final t = tasksVM.trashedTasks[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
                        child: Row(
                          children: [
                            Expanded(child: Text(t.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                            IconButton(
                              icon: const Icon(Icons.settings_backup_restore, color: AppColors.primary, size: 20),
                              onPressed: () => tasksVM.restoreTask(t),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 20),
                              onPressed: () => _confirmPermanentDelete(context, tasksVM, t),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (tasksVM.trashedTasks.isNotEmpty)
                  TextButton(
                    onPressed: () => _confirmClearAll(context, tasksVM),
                    child: const Text("DỌN SẠCH THÙNG RÁC", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- LOGIC GIỮ NGUYÊN & TỐI ƯU ---

  Widget _buildSearchAndAddRow(BuildContext context, TasksViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: vm.setSearchQuery,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: "Tìm mục tiêu...",
              prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
              fillColor: AppColors.surfaceDark,
              filled: true,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _showTaskDetail(context),
          child: Container(
            height: 50, width: 50,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16), boxShadow: AppColors.neonShadow),
            child: const Icon(Icons.add, color: AppColors.backgroundDark, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildCatChip(TasksViewModel vm, String name) {
    final isSelected = vm.selectedCategory == name;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(name),
        selected: isSelected,
        onSelected: (_) => vm.setCategory(name),
        backgroundColor: AppColors.surfaceDark,
        selectedColor: AppColors.primary,
        showCheckmark: false,
        labelStyle: TextStyle(color: isSelected ? AppColors.backgroundDark : Colors.grey, fontSize: 11, fontWeight: FontWeight.w900),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide.none),
      ),
    );
  }

  Widget _buildTaskMeta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey)),
      ],
    );
  }

  Widget _buildCompletedToggle(int count) {
    return ListTile(
      title: Text("ĐÃ HOÀN THÀNH ($count)", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
      trailing: Icon(_showCompleted ? Icons.expand_less : Icons.expand_more, size: 18),
      onTap: () => setState(() => _showCompleted = !_showCompleted),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.auto_awesome_motion_outlined, size: 64, color: Colors.white10),
        SizedBox(height: 16),
        Text("Danh sách trống", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold)),
      ],
    ));
  }

  void _showTaskOptions(BuildContext context, TaskModel task, TasksViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: const Icon(Icons.edit_note, color: AppColors.primary), title: const Text("Chỉnh sửa"), onTap: () { Navigator.pop(context); _showTaskDetail(context, task: task); }),
          ListTile(leading: const Icon(Icons.delete_sweep, color: Colors.redAccent), title: const Text("Xóa tạm"), onTap: () { vm.moveToTrash(task); Navigator.pop(context); }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _confirmPermanentDelete(BuildContext context, TasksViewModel vm, TaskModel task) {
    showDialog(context: context, builder: (context) => AlertDialog(backgroundColor: AppColors.surfaceDark, title: const Text("Xóa vĩnh viễn?"), content: const Text("Không thể hoàn tác hành động này."), actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text("HỦY")),
      TextButton(onPressed: () { vm.deletePermanently(task.id); Navigator.pop(context); }, child: const Text("XÓA", style: TextStyle(color: Colors.redAccent))),
    ]));
  }

  void _confirmClearAll(BuildContext context, TasksViewModel vm) {
    showDialog(context: context, builder: (context) => AlertDialog(backgroundColor: AppColors.surfaceDark, title: const Text("Dọn sạch thùng rác?"), actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text("HỦY")),
      TextButton(onPressed: () { for (var t in vm.trashedTasks) { vm.deletePermanently(t.id); } Navigator.pop(context); }, child: const Text("DỌN SẠCH", style: TextStyle(color: Colors.redAccent))),
    ]));
  }

  void _showTaskDetail(BuildContext context, {TaskModel? task}) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => TaskDetailSheet(task: task));
  }

  void _showCategoryMgmt(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const CategoryMgmtSheet());
  }
}