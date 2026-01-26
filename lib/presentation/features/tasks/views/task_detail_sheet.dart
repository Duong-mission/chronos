import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:chronos/core/components/glass_input.dart';
import 'package:chronos/core/components/neon_button.dart';
import 'package:chronos/core/constants/app_colors.dart';
import 'package:chronos/data/models/task_model.dart';
import 'package:chronos/presentation/features/tasks/view_models/tasks_view_model.dart';

class TaskDetailSheet extends StatefulWidget {
  final TaskModel? task;
  const TaskDetailSheet({super.key, this.task});

  @override
  State<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<TaskDetailSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locController = TextEditingController();
  final _subtaskController = TextEditingController();

  // State biến thời gian & cấu hình
  String _startDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _startTime = "08:00";
  String _dueDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _dueTime = "17:00";
  String _priority = 'Trung bình';
  String _category = 'Học tập';
  String _reminder = '30';
  String _repeat = 'none';

  // Dữ liệu checklist
  List<SubTaskModel> _subtasks = [];

  // Trạng thái loading toàn cục (cho nút Main AI)
  bool _isLocalLoading = false;

  // [QUAN TRỌNG] Trạng thái loading cục bộ cho từng node (cho nút Bolt)
  // Lưu index của subtask đang được AI xử lý
  int? _activeDeepDiveIndex;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description ?? '';
      _locController.text = widget.task!.location ?? '';
      _startDate = widget.task!.startDate;
      _startTime = widget.task!.startTime;
      _dueDate = widget.task!.dueDate;
      _dueTime = widget.task!.dueTime;
      _priority = widget.task!.priority;
      _category = widget.task!.category;
      _reminder = widget.task!.reminder ?? '30';
      _repeat = widget.task!.repeat ?? 'none';
      _subtasks = List.from(widget.task!.subtasks ?? []);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIC AI 1: PHÂN RÃ TỔNG THỂ (STREAMING)
  // ============================================================
  Future<void> _handleMainAIPlan(TasksViewModel vm) async {
    if (_titleController.text.isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLocalLoading = true);

    // Context tổng thể
    String goalContext = "Mục tiêu: ${_titleController.text}. ${_descController.text}";

    try {
      // BƯỚC 1: Lấy khung sườn (Main Phases)
      final mainPhases = await vm.fetchMainPhases(goalContext);

      if (mainPhases.isEmpty) {
        setState(() => _isLocalLoading = false);
        return;
      }

      // Hiển thị khung sườn ngay lập tức
      setState(() {
        _subtasks.addAll(mainPhases);
        _isLocalLoading = false; // Tắt loading chính
      });

      // BƯỚC 2: Streaming chi tiết (Chạy ngầm)
      for (var phase in mainPhases) {
        if (!mounted) break;

        // Gọi AI lấy chi tiết, truyền context mục tiêu gốc
        final subSteps = await vm.fetchSubSteps(phase.title!, goalContext);

        if (subSteps.isNotEmpty) {
          // Gán level con (Level cha + 1)
          for (var sub in subSteps) {
            sub.level = phase.level + 1;
          }

          if (!mounted) return;

          setState(() {
            // Tìm vị trí mới nhất của cha
            final parentIndex = _subtasks.indexOf(phase);
            if (parentIndex != -1) {
              _subtasks.insertAll(parentIndex + 1, subSteps);
            }
          });

          // Delay nhẹ để tạo hiệu ứng mượt mà
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLocalLoading = false);
    }
  }

  // ============================================================
  // LOGIC AI 2: DEEP DIVE (NÚT TIA SÉT) - CÓ HIỆU ỨNG LOADING
  // ============================================================
  Future<void> _handleSubtaskAIPlan(TasksViewModel vm, int index) async {
    final parent = _subtasks[index];
    if (parent.title == null || parent.title!.isEmpty) return;

    // [START LOADING] Đánh dấu node này đang xử lý
    setState(() => _activeDeepDiveIndex = index);

    try {
      String goalContext = "Mục tiêu lớn: ${_titleController.text}";

      // Gọi AI
      final steps = await vm.fetchSubSteps(parent.title!, goalContext);

      if (steps.isNotEmpty) {
        setState(() {
          // Gán level sâu hơn
          for (var s in steps) {
            s.level = parent.level + 1;
          }
          // Chèn vào sau cha
          _subtasks.insertAll(index + 1, steps);
        });
      }
    } catch (e) {
      debugPrint("Deep dive error: $e");
    } finally {
      // [STOP LOADING] Tắt trạng thái xử lý
      if (mounted) {
        setState(() => _activeDeepDiveIndex = null);
      }
    }
  }

  // ============================================================
  // UI BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TasksViewModel>();
    final isLoading = vm.isPlanning || _isLocalLoading;

    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 24, right: 24, top: 24
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),

          _buildHeader(),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassInput(label: "Tên công việc *", hint: "Bạn muốn làm gì?", controller: _titleController),
                  const SizedBox(height: 16),
                  GlassInput(label: "Mô tả chi tiết", hint: "AI sẽ dựa vào đây để lập kế hoạch...", controller: _descController, maxLines: 2),
                  const SizedBox(height: 24),

                  // Header List & AI Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("KẾ HOẠCH THỰC HIỆN",
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
                      TextButton.icon(
                        onPressed: isLoading ? null : () => _handleMainAIPlan(vm),
                        style: TextButton.styleFrom(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                        ),
                        icon: isLoading
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                            : const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                        label: Text(isLoading ? " ĐANG SUY NGHĨ..." : " AI LẬP KẾ HOẠCH",
                            style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // LIST SUBTASKS
                  _buildSubtaskList(vm),

                  _buildAddManualField(),

                  const SizedBox(height: 24),
                  _buildTimeSelection(),
                  const SizedBox(height: 24),
                  _buildExtraSettings(vm),
                  const SizedBox(height: 40),

                  NeonButton(
                    text: widget.task == null ? "KHỞI TẠO LỘ TRÌNH" : "CẬP NHẬT LỘ TRÌNH",
                    onPressed: _saveTask,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.task == null ? "MỤC TIÊU MỚI" : "CHỈNH SỬA",
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5)),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.grey),
          style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.05)),
        ),
      ],
    );
  }

  Widget _buildSubtaskList(TasksViewModel vm) {
    if (_subtasks.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(border: Border.all(color: Colors.white10), borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text("Chưa có kế hoạch. Nhập tên và nhấn 'AI LẬP KẾ HOẠCH'", style: TextStyle(color: Colors.grey, fontSize: 12))),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05))
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _subtasks.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.white.withOpacity(0.03)),
        itemBuilder: (context, index) {
          final st = _subtasks[index];
          // Tính toán thụt lề
          final double indent = st.level * 24.0;
          // Kiểm tra xem node này có đang xoay loading không
          final bool isThisNodeLoading = _activeDeepDiveIndex == index;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              children: [
                // 1. Thụt lề
                SizedBox(width: indent),

                // 2. Icon chỉ thị cấp độ
                if (st.level > 0)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.grey),
                  ),

                // 3. Checkbox
                SizedBox(
                  width: 24, height: 24,
                  child: Checkbox(
                    value: st.completed,
                    onChanged: (v) => setState(() => st.completed = v!),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 8),

                // 4. Nội dung text
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: st.title)
                      ..selection = TextSelection.fromPosition(TextPosition(offset: st.title?.length ?? 0)),
                    onChanged: (val) => st.title = val,
                    style: TextStyle(
                        fontSize: 13,
                        color: st.completed ? Colors.grey : Colors.white,
                        decoration: st.completed ? TextDecoration.lineThrough : null,
                        fontWeight: FontWeight.w500
                    ),
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                  ),
                ),

                // 5. Controls

                // Nút Thụt ra
                _iconBtn(Icons.chevron_left, () {
                  if (st.level > 0) setState(() => st.level--);
                }),

                // Nút Thụt vào
                _iconBtn(Icons.chevron_right, () {
                  if (st.level < 5) setState(() => st.level++);
                }),

                // Nút Bolt AI (Deep Dive) - SỬA ĐỔI QUAN TRỌNG TẠI ĐÂY
                if (!st.completed)
                  isThisNodeLoading
                      ? const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)
                    ),
                  )
                      : _iconBtn(Icons.bolt, () => _handleSubtaskAIPlan(vm, index), color: AppColors.primary),

                // Nút Xóa
                _iconBtn(Icons.close, () => setState(() => _subtasks.removeAt(index)), color: Colors.redAccent.withOpacity(0.7)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {Color color = Colors.grey}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  // ... (Phần UI phụ trợ bên dưới giữ nguyên) ...

  Widget _buildAddManualField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _subtaskController,
            style: const TextStyle(fontSize: 13, color: Colors.white),
            decoration: InputDecoration(
              hintText: "Thêm bước thủ công...",
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
              filled: true,
              fillColor: Colors.white.withOpacity(0.03),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
            onSubmitted: (_) => _addSubtaskManually(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
            onPressed: _addSubtaskManually,
            icon: const Icon(Icons.add_circle, color: AppColors.primary),
            style: IconButton.styleFrom(backgroundColor: AppColors.primary.withOpacity(0.1))
        ),
      ],
    );
  }

  Widget _buildTimeSelection() {
    return Row(
      children: [
        _timeTile("BẮT ĐẦU", _startDate, _startTime, () => _pickDate(true), () => _pickTime(true), AppColors.primary),
        const SizedBox(width: 12),
        _timeTile("HẠN CHÓT", _dueDate, _dueTime, () => _pickDate(false), () => _pickTime(false), Colors.redAccent),
      ],
    );
  }

  Widget _buildExtraSettings(TasksViewModel vm) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _dropdown("MỨC ƯU TIÊN", _priority, ['Thấp', 'Trung bình', 'Cao'], (v) => setState(() => _priority = v!))),
            const SizedBox(width: 12),
            Expanded(child: _dropdown("DANH MỤC", _category, vm.categories.map((e) => e.name).toList(), (v) => setState(() => _category = v!))),
          ],
        ),
        const SizedBox(height: 16),
        GlassInput(label: "Địa điểm thực hiện", hint: "Thư viện, quán cafe...", controller: _locController),
      ],
    );
  }

  Widget _timeTile(String label, String date, String time, VoidCallback onD, VoidCallback onT, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(24), border: Border.all(color: color.withOpacity(0.1))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: color, letterSpacing: 1)),
            const SizedBox(height: 12),
            InkWell(onTap: onD, child: Text(date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900))),
            const Divider(height: 20, color: Colors.white10),
            InkWell(onTap: onT, child: Text(time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900))),
          ],
        ),
      ),
    );
  }

  Widget _dropdown(String label, String val, List<String> items, Function(String?) onC) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(16)),
          child: DropdownButton<String>(
            value: items.contains(val) ? val : items.first,
            isExpanded: true, underline: const SizedBox(),
            dropdownColor: AppColors.surfaceDark,
            style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onC,
          ),
        ),
      ],
    );
  }

  void _addSubtaskManually() {
    if (_subtaskController.text.isNotEmpty) {
      setState(() {
        _subtasks.add(SubTaskModel()
          ..id = DateTime.now().millisecondsSinceEpoch.toString()
          ..title = _subtaskController.text.trim()
          ..completed = false
          ..level = 0);
        _subtaskController.clear();
      });
    }
  }

  void _saveTask() {
    if (_titleController.text.isEmpty) return;
    final vm = context.read<TasksViewModel>();
    final t = widget.task ?? TaskModel();
    t.title = _titleController.text;
    t.description = _descController.text;
    t.location = _locController.text;
    t.startDate = _startDate; t.startTime = _startTime;
    t.dueDate = _dueDate; t.dueTime = _dueTime;
    t.priority = _priority; t.category = _category;
    t.subtasks = _subtasks;
    t.reminder = _reminder; t.repeat = _repeat;

    vm.saveTask(t);
    Navigator.pop(context);
  }

  Future<void> _pickDate(bool isStart) async {
    final p = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2024), lastDate: DateTime(2030));
    if (p != null) setState(() { if (isStart) _startDate = DateFormat('yyyy-MM-dd').format(p); else _dueDate = DateFormat('yyyy-MM-dd').format(p); });
  }

  Future<void> _pickTime(bool isStart) async {
    final p = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (p != null) setState(() {
      final s = "${p.hour.toString().padLeft(2, '0')}:${p.minute.toString().padLeft(2, '0')}";
      if (isStart) _startTime = s; else _dueTime = s;
    });
  }
}