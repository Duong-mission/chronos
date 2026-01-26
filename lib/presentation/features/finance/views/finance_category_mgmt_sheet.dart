import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chronos/core/constants/app_colors.dart';
import 'package:chronos/core/constants/app_constants.dart';
import 'package:chronos/core/components/glass_input.dart';
import '../view_models/finance_view_model.dart';

class FinanceCategoryMgmtSheet extends StatefulWidget {
  const FinanceCategoryMgmtSheet({super.key});

  @override
  State<FinanceCategoryMgmtSheet> createState() => _FinanceCategoryMgmtSheetState();
}

class _FinanceCategoryMgmtSheetState extends State<FinanceCategoryMgmtSheet> {
  bool _isExpenseTab = true;
  final _nameController = TextEditingController();
  IconData _selectedIcon = Icons.restaurant;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FinanceViewModel>();
    final currentCats = _isExpenseTab ? vm.expenseCategories : vm.incomeCategories;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        left: 24, right: 24, top: 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("CẤU HÌNH DANH MỤC", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
          const SizedBox(height: 20),

          // 1. Tab Switcher (Chi tiêu / Thu nhập)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.backgroundDark, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                _buildTabBtn("CHI TIÊU", _isExpenseTab, () => setState(() => _isExpenseTab = true)),
                _buildTabBtn("THU NHẬP", !_isExpenseTab, () => setState(() => _isExpenseTab = false)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. Form thêm mới
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: GlassInput(label: "Tên danh mục", hint: "Ví dụ: Mua sắm...", controller: _nameController)),
              const SizedBox(width: 12),
              // Nút chọn Icon
              GestureDetector(
                onTap: () => _showIconPicker(),
                child: Container(
                  height: 56, width: 56,
                  decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                  child: Icon(_selectedIcon, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              // Nút Thêm
              Container(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty) {
                      vm.addFinanceCategory(
                          _nameController.text,
                          _selectedIcon.codePoint, // Lưu codePoint icon
                          _isExpenseTab ? "#ef4444" : "#19f073",
                          _isExpenseTab
                      );
                      _nameController.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Icon(Icons.add, color: Colors.black),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 3. Danh sách hiện tại
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: currentCats.length,
              itemBuilder: (context, index) {
                final cat = currentCats[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(IconData(cat.icon!, fontFamily: 'MaterialIcons'), color: _isExpenseTab ? Colors.redAccent : AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Text(cat.name!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.white24, size: 20),
                        onPressed: () => vm.deleteFinanceCategory(cat.id!, _isExpenseTab),
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

  Widget _buildTabBtn(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? (label == "CHI TIÊU" ? Colors.redAccent : AppColors.primary) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isSelected ? Colors.black : Colors.grey)),
          ),
        ),
      ),
    );
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      builder: (_) => GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 20, crossAxisSpacing: 20),
        itemCount: AppConstants.commonIcons.length,
        itemBuilder: (context, i) => GestureDetector(
          onTap: () {
            setState(() => _selectedIcon = AppConstants.commonIcons[i]);
            Navigator.pop(context);
          },
          child: Icon(AppConstants.commonIcons[i], color: Colors.white),
        ),
      ),
    );
  }
}