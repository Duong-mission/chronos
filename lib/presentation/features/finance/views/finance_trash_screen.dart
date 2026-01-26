import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:chronos/core/constants/app_colors.dart';
import 'package:chronos/core/components/chronos_card.dart';
import 'package:chronos/presentation/features/finance/view_models/finance_view_model.dart';
import 'package:chronos/data/models/transaction_model.dart';

class FinanceTrashScreen extends StatelessWidget {
  const FinanceTrashScreen({super.key});

  String _formatVND(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe danh sách rác từ ViewModel
    final vm = context.watch<FinanceViewModel>();
    final trashItems = vm.trashTransactions;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "THÙNG RÁC TÀI CHÍNH",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Banner thông báo tự động dọn dẹp
          _buildAutoDeleteInfo(),

          const SizedBox(height: 10),

          // 2. Danh sách mục đã xóa
          Expanded(
            child: trashItems.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(),
              itemCount: trashItems.length,
              itemBuilder: (context, index) {
                return _buildTrashItem(context, trashItems[index], vm);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoDeleteInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Các giao dịch trong thùng rác sẽ tự động bị xóa vĩnh viễn sau 30 ngày.",
              style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrashItem(BuildContext context, TransactionModel t, FinanceViewModel vm) {
    final isIncome = t.type == 'income';
    final Color color = isIncome ? AppColors.primary : Colors.redAccent;

    // Tính số ngày còn lại trước khi bị xóa (30 - số ngày đã trôi qua)
    int daysLeft = 30;
    if (t.deletedAt != null) {
      daysLeft = 30 - DateTime.now().difference(t.deletedAt!).inDays;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ChronosCard(
        padding: 16,
        child: Row(
          children: [
            // Icon trạng thái mờ
            Opacity(
              opacity: 0.5,
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.history, size: 18, color: Colors.white70),
              ),
            ),
            const SizedBox(width: 16),

            // Thông tin giao dịch
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.content,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Sẽ xóa sau: $daysLeft ngày",
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color.withOpacity(0.6)),
                  ),
                ],
              ),
            ),

            // Nút Thao tác
            Row(
              children: [
                // Nút Khôi phục
                _actionIconButton(
                  icon: Icons.restore,
                  color: AppColors.primary,
                  onTap: () => vm.restoreTransaction(t.id),
                  tooltip: "Khôi phục",
                ),
                const SizedBox(width: 8),
                // Nút Xóa vĩnh viễn
                _actionIconButton(
                  icon: Icons.delete_forever,
                  color: Colors.redAccent,
                  onTap: () => _confirmHardDelete(context, vm, t),
                  tooltip: "Xóa vĩnh viễn",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionIconButton({required IconData icon, required Color color, required VoidCallback onTap, required String tooltip}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.1,
            child: Icon(Icons.delete_sweep_outlined, size: 80, color: Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            "THÙNG RÁC TRỐNG",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white10, letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  void _confirmHardDelete(BuildContext context, FinanceViewModel vm, TransactionModel t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: const Text(
          "XÓA VĨNH VIỄN?",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.redAccent),
        ),
        content: Text(
          "Hành động này sẽ gỡ bỏ '${t.content}' hoàn toàn khỏi bộ nhớ và không thể khôi phục lại.",
          style: const TextStyle(fontSize: 13, color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("HỦY", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              vm.hardDeleteTransaction(t.id);
              Navigator.pop(context);
            },
            child: const Text("XÓA NGAY", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}