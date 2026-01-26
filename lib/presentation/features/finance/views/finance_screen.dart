import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:chronos/core/constants/app_colors.dart';
import 'package:chronos/core/components/chronos_header.dart';
import 'package:chronos/core/components/chronos_card.dart';
import 'package:chronos/data/models/transaction_model.dart';
import 'package:chronos/presentation/features/finance/view_models/finance_view_model.dart';
import 'package:chronos/presentation/features/finance/views/add_transaction_sheet.dart';
import 'package:chronos/presentation/features/finance/views/finance_category_mgmt_sheet.dart';
import 'package:chronos/presentation/features/finance/views/finance_analytics_screen.dart';
import 'package:chronos/presentation/features/finance/views/finance_trash_screen.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  String _formatVND(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FinanceViewModel>();
    final currentMonthStr = DateFormat('MMMM, yyyy', 'vi_VN').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ChronosHeader(
                title: "Tài chính",
                subtitle: "Giám sát dòng tiền thông minh",
              ),

              // 1. WALLET CARD (SỐ DƯ & NGÂN SÁCH)
              _buildWalletCard(context, vm),

              const SizedBox(height: 32),

              // 2. BIỂU ĐỒ XẾP HẠNG CHI TIÊU (GIẢI QUYẾT VẤN ĐỀ NHIỀU DANH MỤC)
              _buildSpendingRanking(context, vm, currentMonthStr),

              const SizedBox(height: 32),

              // 3. HEADER LỊCH SỬ + CÁC NÚT CHỨC NĂNG (THÙNG RÁC, LƯU TRỮ)
              _buildHistoryHeader(context, vm),

              const SizedBox(height: 16),

              // 4. DANH SÁCH GIAO DỊCH THÁNG HIỆN TẠI (CÓ SỬA/XÓA)
              _buildCurrentMonthList(context, vm),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // --- 1. THẺ VÍ CHÍNH ---
  Widget _buildWalletCard(BuildContext context, FinanceViewModel vm) {
    bool isOverLimit = vm.budgetPercent > 90;

    return ChronosCard(
      showNeon: true,
      gradient: const LinearGradient(
        colors: [Color(0xFF1B3D2B), Color(0xFF102218)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("SỐ DƯ KHẢ DỤNG", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 2.5)),
          const SizedBox(height: 4),
          Text(_formatVND(vm.totalBalanceAllTime), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _showBudgetModal(context, vm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("HẠN MỨC THÁNG", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey)),
                    Text(vm.budget > 0 ? _formatVND(vm.budget) : 'Chưa thiết lập', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
                  ],
                ),
              ),
              Text("${vm.budgetPercent.toStringAsFixed(0)}%", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isOverLimit ? Colors.redAccent : AppColors.primary)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (vm.budgetPercent / 100).clamp(0, 1),
              backgroundColor: Colors.white.withOpacity(0.05),
              color: isOverLimit ? Colors.redAccent : AppColors.primary,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: _actionBtn("CHI TIÊU", Icons.remove_circle, Colors.redAccent, () => _showAddSheet(context, 'expense'))),
              const SizedBox(width: 12),
              Expanded(child: _actionBtn("THU NHẬP", Icons.add_circle, AppColors.primary, () => _showAddSheet(context, 'income'))),
            ],
          )
        ],
      ),
    );
  }

  // --- 2. BIỂU ĐỒ XẾP HẠNG (RANKING PROGRESS BARS) ---
  // Giải quyết vấn đề biểu đồ tròn bị rối khi có nhiều danh mục
  Widget _buildSpendingRanking(BuildContext context, FinanceViewModel vm, String monthStr) {
    final rawData = vm.expenseDistributionMonth.entries.toList();
    rawData.sort((a, b) => b.value.compareTo(a.value)); // Sắp xếp chi tiêu cao nhất lên đầu

    return ChronosCard(
      padding: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("PHÂN BỔ CHI TIÊU", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
              Text(monthStr.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 24),
          if (rawData.isEmpty)
            const Center(child: Opacity(opacity: 0.2, child: Text("CHƯA CÓ DỮ LIỆU", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900))))
          else
            ...rawData.take(5).map((e) {
              final cat = vm.expenseCategories.firstWhere((c) => c.name == e.key, orElse: () => vm.expenseCategories.first);
              final color = Color(int.parse(cat.color!.replaceFirst('#', '0xFF')));
              final percent = e.value / vm.totalExpenseMonth;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Icon(IconData(cat.icon!, fontFamily: 'MaterialIcons'), size: 14, color: color),
                          const SizedBox(width: 8),
                          Text(e.key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ]),
                        Text(_formatVND(e.value), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 6,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        color: color,
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  // --- 3. HEADER LỊCH SỬ + CÁC NÚT ĐIỀU HƯỚNG ---
  Widget _buildHistoryHeader(BuildContext context, FinanceViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary)),
          const SizedBox(width: 8),
          const Text("LỊCH SỬ THÁNG NÀY", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.primary)),
        ]),
        Row(children: [
          // NÚT THÙNG RÁC
          _headerIconBtn(Icons.delete_sweep_outlined, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceTrashScreen()));
          }),
          const SizedBox(width: 8),
          // NÚT KHO LƯU TRỮ
          _headerIconBtn(Icons.inventory_2_outlined, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceAnalyticsScreen()));
          }),
          const SizedBox(width: 8),
          _headerIconBtn(Icons.settings_outlined, () {
            showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const FinanceCategoryMgmtSheet());
          }),
        ])
      ],
    );
  }

  // --- 4. DANH SÁCH GIAO DỊCH CÓ SỬA/XÓA ---
  Widget _buildCurrentMonthList(BuildContext context, FinanceViewModel vm) {
    final trans = vm.currentMonthTransactions;
    if (trans.isEmpty) return const SizedBox();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trans.length,
      itemBuilder: (context, index) {
        final t = trans[index];
        final isIncome = t.type == 'income';
        final allCats = [...vm.expenseCategories, ...vm.incomeCategories];
        final cat = allCats.firstWhere((c) => c.name == t.category, orElse: () => allCats.first);
        final color = isIncome ? AppColors.primary : Colors.redAccent;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.03))),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                child: Icon(IconData(cat.icon!, fontFamily: 'MaterialIcons'), size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.content, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    Text("${t.category.toUpperCase()} • ${DateFormat('dd/MM').format(DateTime.parse(t.date))}", style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Text(
                "${isIncome ? '+' : '-'}${_formatVND(t.amount).split(',')[0]}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isIncome ? AppColors.primary : Colors.white),
              ),
              // MENU THAO TÁC: SỬA & XÓA
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_vert, color: Colors.white24, size: 18),
                color: AppColors.surfaceDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onSelected: (value) {
                  if (value == 'edit') {
                    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => AddTransactionSheet(initialType: t.type, transaction: t));
                  } else if (value == 'delete') {
                    _showDeleteConfirm(context, vm, t);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text("Sửa")])),
                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: Colors.redAccent), SizedBox(width: 8), Text("Xóa", style: TextStyle(color: Colors.redAccent))])),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- HELPERS ---

  void _showDeleteConfirm(BuildContext context, FinanceViewModel vm, TransactionModel t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: const Text("XÓA GIAO DỊCH?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.redAccent)),
        content: Text("Giao dịch '${t.content}' sẽ được chuyển vào thùng rác."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("HỦY", style: TextStyle(color: Colors.grey))),
          TextButton(
              onPressed: () {
                vm.softDeleteTransaction(t.id);
                Navigator.pop(context);
              },
              child: const Text("XÓA", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900))
          ),
        ],
      ),
    );
  }

  Widget _headerIconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05)), boxShadow: AppColors.neonShadow),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }

  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    bool isPrimary = color == AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(color: isPrimary ? color : Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), boxShadow: isPrimary ? AppColors.neonShadow : null),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isPrimary ? AppColors.backgroundDark : color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isPrimary ? AppColors.backgroundDark : Colors.white)),
          ],
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context, String type) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => AddTransactionSheet(initialType: type));
  }

  void _showBudgetModal(BuildContext context, FinanceViewModel vm) {
    final controller = TextEditingController(text: vm.budget.toInt().toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: const Text("NGÂN SÁCH THÁNG", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.primary, fontSize: 26, fontWeight: FontWeight.w900),
          decoration: const InputDecoration(border: InputBorder.none, hintText: "0"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("HỦY", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              vm.updateBudget(double.tryParse(controller.text) ?? 0);
              Navigator.pop(context);
            },
            child: const Text("XÁC NHẬN", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}