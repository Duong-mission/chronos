import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
import 'package:chronos/core/constants/app_colors.dart';
import 'package:chronos/core/constants/app_constants.dart';
import 'package:chronos/core/components/chronos_card.dart';
import 'package:chronos/presentation/features/journal/view_models/journal_view_model.dart';
import 'package:chronos/presentation/features/journal/views/journal_trash_screen.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<JournalViewModel>();

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: vm.viewMode == JournalViewMode.list
              ? _buildListView(context, vm)
              : _buildComposeView(context, vm),
        ),
      ),
      floatingActionButton: vm.viewMode == JournalViewMode.list
          ? Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () => vm.setViewMode(JournalViewMode.compose),
          backgroundColor: AppColors.primary,
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.edit_document, color: AppColors.backgroundDark, size: 28),
        ),
      )
          : null,
    );
  }

  // ============================================================
  // 1. GIAO DIỆN DANH SÁCH (TIMELINE)
  // ============================================================
  Widget _buildListView(BuildContext context, JournalViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: GỘP CHUNG CỤM NÚT THÔNG BÁO, TÌM KIẾM, THÙNG RÁC
          _buildEnhancedHeader(context, vm),

          const SizedBox(height: 24),
          _buildSummaryCard(vm),

          const SizedBox(height: 32),

          if (vm.entries.isEmpty)
            _buildEmptyState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vm.entries.length,
              itemBuilder: (context, index) {
                final entry = vm.entries[index];
                return _buildTimelineItem(context, entry, vm, index == vm.entries.length - 1);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancedHeader(BuildContext context, JournalViewModel vm) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nhật ký", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
              Text("Lưu giữ ký ức đa tầng", style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ),
        Row(
          children: [
            _headerIcon(Icons.search, () {}),
            const SizedBox(width: 8),
            _headerIcon(Icons.notifications_none, () {}, hasBadge: true),
            const SizedBox(width: 8),
            _headerIcon(
              Icons.delete_sweep_outlined,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JournalTrashScreen())),
              isPrimary: true,
              count: vm.trashEntries.length,
            ),
          ],
        ),
      ],
    );
  }

  Widget _headerIcon(IconData icon, VoidCallback onTap, {bool hasBadge = false, bool isPrimary = false, int count = 0}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: isPrimary ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isPrimary ? AppColors.primary.withOpacity(0.2) : Colors.white.withOpacity(0.05)),
            ),
            child: Icon(icon, color: isPrimary ? AppColors.primary : Colors.grey, size: 20),
          ),
          if (hasBadge || count > 0)
            Positioned(
              top: -2, right: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(count > 0 ? "$count" : "", style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white), textAlign: TextAlign.center),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, dynamic entry, JournalViewModel vm, bool isLast) {
    final primaryMoodValue = entry.moods.isNotEmpty ? entry.moods[0] : 'neutral';
    final moodConfig = AppConstants.moods.firstWhere((m) => m['value'] == primaryMoodValue, orElse: () => AppConstants.moods[7]);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: (moodConfig['color'] as Color).withOpacity(0.4), width: 2),
                  boxShadow: [BoxShadow(color: (moodConfig['color'] as Color).withOpacity(0.2), blurRadius: 10)],
                ),
                child: Icon(moodConfig['icon'], color: moodConfig['color'], size: 22),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [ (moodConfig['color'] as Color).withOpacity(0.5), Colors.transparent],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: ChronosCard(
                padding: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.date, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
                            const SizedBox(height: 2),
                            Text(entry.time, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900)),
                          ],
                        ),
                        Row(
                          children: [
                            _actionIconButton(Icons.edit_outlined, () => vm.setEditEntry(entry)),
                            const SizedBox(width: 8),
                            _actionIconButton(Icons.delete_outline, () => _confirmSoftDelete(context, vm, entry.id, entry.content), isDelete: true),
                          ],
                        ),
                      ],
                    ),
                    if (entry.content.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(entry.content, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500), maxLines: 3, overflow: TextOverflow.ellipsis),
                    ],
                    if (entry.activities.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 6, runSpacing: 6,
                        children: entry.activities.map<Widget>((a) => _buildActivityTag(a)).toList(),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 2. GIAO DIỆN SOẠN THẢO (COMPOSE VIEW)
  // ============================================================
  Widget _buildComposeView(BuildContext context, JournalViewModel vm) {
    final key = ValueKey(vm.editingEntry?.id ?? 'new');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComposeHeader(vm),
          const SizedBox(height: 32),

          const Text("CẢM XÚC HÔM NAY", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          _buildGridPicker(
            items: AppConstants.moods,
            selectedValues: vm.selectedMoods,
            onTap: (val) => vm.toggleMood(val),
          ),

          const SizedBox(height: 32),
          const Text("HOẠT ĐỘNG", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          // BỔ SUNG ICON CHO HOẠT ĐỘNG
          _buildGridPicker(
            items: AppConstants.journalActivitiesWithIcons, // Cần định nghĩa trong AppConstants
            selectedValues: vm.selectedActivities,
            onTap: (val) => vm.toggleActivity(val),
            isActivity: true,
          ),

          const SizedBox(height: 32),
          _buildProductivitySection(vm),

          const SizedBox(height: 32),
          const Text("TÂM SỰ", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          _buildWritingArea(vm, key),

          const SizedBox(height: 24),
          if (vm.aiReflection != null || vm.isAnalyzing) _buildAiReflectionBox(vm),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ============================================================
  // 3. CÁC HELPER WIDGETS
  // ============================================================

  Widget _buildGridPicker({
    required List<Map<String, dynamic>> items,
    required List<String> selectedValues,
    required Function(String) onTap,
    bool isActivity = false,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.85
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final String value = isActivity ? item['label'] : item['value'];
        final String label = item['label'];
        final IconData icon = item['icon'];
        bool isSelected = selectedValues.contains(value);
        final Color mColor = isActivity ? Colors.white : (item['color'] as Color);

        return GestureDetector(
          onTap: () => onTap(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? (isActivity ? Colors.white : mColor.withOpacity(0.15)) : AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? mColor : Colors.white.withOpacity(0.05), width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: isSelected ? (isActivity ? AppColors.backgroundDark : mColor) : Colors.white24, size: 26),
                const SizedBox(height: 6),
                Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: isSelected ? (isActivity ? AppColors.backgroundDark : Colors.white) : Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWritingArea(JournalViewModel vm, Key key) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        TextFormField(
          key: key,
          initialValue: vm.content,
          maxLines: 8,
          onChanged: vm.updateContent,
          style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.white),
          decoration: InputDecoration(
            hintText: "Ghi lại những suy nghĩ của bạn...",
            hintStyle: const TextStyle(color: Colors.white10),
            fillColor: AppColors.cardDark,
            filled: true,
            contentPadding: const EdgeInsets.all(24),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: BorderSide.none),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FloatingActionButton.small(
            onPressed: vm.handleReflect,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            elevation: 0,
            child: Icon(vm.isAnalyzing ? Icons.sync : Icons.auto_awesome, color: AppColors.primary, size: 20),
          ),
        )
      ],
    );
  }

  Widget _buildActivityTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 0.5)),
    );
  }

  Widget _actionIconButton(IconData icon, VoidCallback onTap, {bool isDelete = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: isDelete ? AppColors.red.withOpacity(0.5) : Colors.white24),
      ),
    );
  }

  Widget _buildComposeHeader(JournalViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(onPressed: () => vm.setViewMode(JournalViewMode.list), icon: const Icon(Icons.close)),
        Text(vm.editingEntry == null ? "VIẾT NHẬT KÝ" : "CẬP NHẬT KÝ ỨC", style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
        TextButton(
          onPressed: vm.canSave ? vm.saveEntry : null,
          child: Text("LƯU", style: TextStyle(color: vm.canSave ? AppColors.primary : Colors.white10, fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }

  // --- CÁC HÀM CÒN LẠI (SummaryCard, AiReflectionBox, Productivity, EmptyState giữ nguyên logic cũ) ---
  void _confirmSoftDelete(BuildContext context, JournalViewModel vm, int id, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("BỎ VÀO THÙNG RÁC?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.red)),
        content: const Text("Ký ức này sẽ được giữ trong thùng rác 30 ngày."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("HỦY", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          TextButton(onPressed: () { vm.softDeleteEntry(id); Navigator.pop(context); }, child: const Text("XÁC NHẬN XÓA", style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(JournalViewModel vm) {
    return ChronosCard(
      showNeon: true,
      padding: 24,
      gradient: const LinearGradient(colors: [Color(0xFF1B3D2B), Color(0xFF102218)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("DÒNG CHẢY CẢM XÚC", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 2)),
            const SizedBox(height: 6),
            Text(vm.entries.isEmpty ? "Ghi lại ký ức ngay..." : "Bạn đang thấu hiểu chính mình", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
          ]),
          const Icon(Icons.auto_stories, color: AppColors.primary, size: 32),
        ],
      ),
    );
  }

  Widget _buildProductivitySection(JournalViewModel vm) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text("ĐIỂM HIỆU SUẤT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
        Text("${vm.productivityScore}/10", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
      ]),
      Slider(value: vm.productivityScore.toDouble(), min: 0, max: 10, divisions: 10, activeColor: AppColors.primary, inactiveColor: Colors.white10, onChanged: (val) => vm.setProductivityScore(val.toInt())),
    ]);
  }

  Widget _buildAiReflectionBox(JournalViewModel vm) {
    return ChronosCard(color: const Color(0xFF1B3D2B), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.psychology, size: 16, color: AppColors.primary), SizedBox(width: 8), Text("PHẢN HỒI TỪ AI", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 1))]),
      const SizedBox(height: 12),
      if (vm.isAnalyzing) const LinearProgressIndicator(backgroundColor: Colors.transparent, color: AppColors.primary)
      else Text(vm.aiReflection!, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white70, height: 1.6)),
    ]));
  }

  Widget _buildEmptyState() {
    return const Center(child: Column(children: [SizedBox(height: 80), Opacity(opacity: 0.05, child: Icon(Icons.history_edu, size: 100, color: Colors.white)), SizedBox(height: 16), Text("CHƯA CÓ TRANG VIẾT NÀO", style: TextStyle(color: Colors.white10, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 11))]));
  }
}