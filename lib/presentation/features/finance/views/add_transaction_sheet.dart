import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:chronos/core/constants/app_colors.dart';
import 'package:chronos/core/components/glass_input.dart';
import 'package:chronos/core/components/neon_button.dart';
import 'package:chronos/data/models/transaction_model.dart';
import 'package:chronos/data/models/finance_settings_model.dart';
import 'package:chronos/presentation/features/finance/view_models/finance_view_model.dart';

class AddTransactionSheet extends StatefulWidget {
  final String initialType; // 'expense' hoặc 'income'
  final TransactionModel? transaction; // Thêm tham số để hỗ trợ sửa

  const AddTransactionSheet({
    super.key,
    required this.initialType,
    this.transaction,
  });

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _contentController = TextEditingController();

  late String _type;
  String? _selectedCategory;
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();

    // 1. Khởi tạo loại giao dịch
    _type = widget.transaction?.type ?? widget.initialType;

    // 2. Nếu có dữ liệu truyền vào (chế độ sửa), điền thông tin cũ vào form
    if (widget.transaction != null) {
      _amountController.text = widget.transaction!.amount.toInt().toString();
      _contentController.text = widget.transaction!.content;
      _selectedCategory = widget.transaction!.category;
      _selectedDate = widget.transaction!.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Hàm chọn ngày chuẩn
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_selectedDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FinanceViewModel>();
    final isExpense = _type == 'expense';

    // Lấy danh mục từ ViewModel dựa trên loại đang chọn
    final currentCategories = isExpense ? vm.expenseCategories : vm.incomeCategories;

    // Logic tự động chọn danh mục đầu tiên nếu danh mục hiện tại không hợp lệ
    if (_selectedCategory == null || !currentCategories.any((c) => c.name == _selectedCategory)) {
      if (currentCategories.isNotEmpty) {
        _selectedCategory = currentCategories.first.name;
      }
    }

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        left: 24, right: 24, top: 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thanh kéo (Handle bar)
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)),
            ),

            // Header & Nút chuyển đổi nhanh
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.transaction == null
                      ? (isExpense ? "GHI CHI TIÊU" : "THU NHẬP MỚI")
                      : "CẬP NHẬT GIAO DỊCH",
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1),
                ),
                // Chỉ cho phép đổi loại (Thu/Chi) nếu đang ở chế độ THÊM MỚI
                if (widget.transaction == null)
                  TextButton(
                    onPressed: () => setState(() {
                      _type = isExpense ? 'income' : 'expense';
                      _selectedCategory = null; // Reset để logic build tự chọn lại
                    }),
                    child: Text(
                      isExpense ? "SANG THU NHẬP" : "SANG CHI TIÊU",
                      style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  )
              ],
            ),

            const SizedBox(height: 24),

            // 1. Ô nhập số tiền
            GlassInput(
              label: "Số tiền (VND)",
              hint: "0",
              controller: _amountController,
              isNumber: true,
            ),

            const SizedBox(height: 16),

            // 2. Ô nhập nội dung
            GlassInput(
              label: "Nội dung",
              hint: "Ví dụ: Ăn trưa, Tiền lương...",
              controller: _contentController,
            ),

            const SizedBox(height: 16),

            // 3. Row cho Danh mục và Ngày
            Row(
              children: [
                // Dropdown chọn danh mục
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("DANH MỤC", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey)),
                      const SizedBox(height: 8),
                      _buildCategoryDropdown(currentCategories, isExpense),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Nút chọn ngày
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("NGÀY", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey)),
                      const SizedBox(height: 8),
                      _buildDatePickerBtn(),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 4. Nút bấm chính
            NeonButton(
              text: widget.transaction == null ? "XÁC NHẬN GIAO DỊCH" : "LƯU THAY ĐỔI",
              onPressed: () {
                if (_amountController.text.isEmpty || _contentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin!")),
                  );
                  return;
                }

                // Cập nhật hoặc tạo mới model
                final t = widget.transaction ?? TransactionModel();
                t.amount = double.tryParse(_amountController.text) ?? 0;
                t.content = _contentController.text.trim();
                t.category = _selectedCategory!;
                t.date = _selectedDate;
                t.type = _type;
                t.isDeleted = false; // Luôn đảm bảo không bị đánh dấu xóa khi lưu

                vm.addTransaction(t); // Put sẽ tự động update nếu object đã có ID (Isar logic)
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildCategoryDropdown(List<FinanceCategory> categories, bool isExpense) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButton<String>(
        value: _selectedCategory,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: AppColors.surfaceDark,
        items: categories.map((cat) => DropdownMenuItem(
          value: cat.name,
          child: Row(
            children: [
              Icon(
                  IconData(cat.icon!, fontFamily: 'MaterialIcons'),
                  size: 16,
                  color: isExpense ? Colors.redAccent : AppColors.primary
              ),
              const SizedBox(width: 8),
              Text(cat.name!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        )).toList(),
        onChanged: (val) => setState(() => _selectedCategory = val),
      ),
    );
  }

  Widget _buildDatePickerBtn() {
    return InkWell(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
            const SizedBox(width: 8),
            Text(_selectedDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}