import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
import 'package:chronos/core/constants/app_colors.dart';
import 'package:chronos/core/components/chronos_card.dart';
import 'package:chronos/presentation/features/journal/view_models/journal_view_model.dart';
import 'package:chronos/data/models/journal_model.dart';

class JournalTrashScreen extends StatelessWidget {
  const JournalTrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<JournalViewModel>();
    final trash = vm.trashEntries;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "THÙNG RÁC KÝ ỨC",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. BANNER THÔNG BÁO CHÍNH SÁCH 30 NGÀY
          _buildPolicyBanner(),

          const SizedBox(height: 10),

          // 2. DANH SÁCH NHẬT KÝ ĐÃ XÓA
          Expanded(
            child: trash.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(),
              itemCount: trash.length,
              itemBuilder: (context, index) {
                return _buildTrashJournalCard(context, trash[index], vm);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_delete_outlined, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Ký ức của bạn sẽ được lưu giữ tại đây trong 30 ngày trước khi bị xóa vĩnh viễn.",
              style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrashJournalCard(BuildContext context, JournalModel entry, JournalViewModel vm) {
    // Tính toán số ngày còn lại
    int daysLeft = 30;
    if (entry.deletedAt != null) {
      daysLeft = 30 - DateTime.now().difference(entry.deletedAt!).inDays;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ChronosCard(
        padding: 16,
        child: Row(
          children: [
            // Khối hiển thị ngày gốc của bài viết
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    entry.date.split('/')[0],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary),
                  ),
                  Text(
                    "THG ${entry.date.split('/')[1]}",
                    style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: Colors.white24),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Nội dung tóm tắt
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "SẼ XÓA TRONG: $daysLeft NGÀY",
                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.orange, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),

            // Nút Thao tác
            Row(
              children: [
                _circularActionBtn(
                  icon: Icons.restore_page_outlined,
                  color: AppColors.primary,
                  onTap: () => vm.restoreEntry(entry.id),
                ),
                const SizedBox(width: 8),
                _circularActionBtn(
                  icon: Icons.delete_forever_outlined,
                  color: AppColors.red,
                  onTap: () => _confirmHardDelete(context, vm, entry),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _circularActionBtn({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Opacity(
        opacity: 0.1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_edu, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text(
              "KHÔNG CÓ KÝ ỨC BỊ XÓA",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmHardDelete(BuildContext context, JournalViewModel vm, JournalModel entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: const Text(
          "XÓA VĨNH VIỄN?",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.red, letterSpacing: 1),
        ),
        content: const Text(
          "Hành động này sẽ xóa sạch trang nhật ký này khỏi dòng thời gian của bạn và không thể khôi phục lại.",
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("HỦY", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              vm.hardDeleteEntry(entry.id);
              Navigator.pop(context);
            },
            child: const Text("XÓA NGAY", style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}