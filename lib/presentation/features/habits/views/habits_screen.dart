import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:chronos/core/constants/app_colors.dart';
import 'package:chronos/core/components/chronos_header.dart';
import 'package:chronos/core/components/chronos_card.dart';
import 'package:chronos/data/models/habit_model.dart';
import 'package:chronos/presentation/features/habits/view_models/habits_view_model.dart';
import 'package:chronos/presentation/features/habits/views/habit_detail_sheet.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe sự thay đổi từ ViewModel
    final viewModel = context.watch<HabitsViewModel>();
    final String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // 1. Header
              const ChronosHeader(
                title: "Thói quen",
                subtitle: "Duy trì kỷ luật mỗi ngày",
              ),

              // 2. Thẻ thống kê nhanh
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      "Hoàn thành",
                      "${viewModel.completedToday}/${viewModel.habits.length}",
                      Icons.bolt,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      "Chuỗi dài",
                      "${viewModel.longestStreak} ngày",
                      Icons.local_fire_department,
                      Colors.orangeAccent,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 3. Danh sách thói quen
              if (viewModel.habits.isEmpty)
                _buildEmptyState()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: viewModel.habits.length,
                  itemBuilder: (context, index) {
                    final habit = viewModel.habits[index];
                    return _buildHabitCard(context, habit, viewModel, todayStr);
                  },
                ),

              // 4. Nút tạo thói quen mới
              const SizedBox(height: 12),
              _buildAddPlaceholder(context),

              const SizedBox(height: 100), // Khoảng trống cho BottomNav
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS CHI TIẾT ---

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return ChronosCard(
      padding: 12,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context, HabitModel habit, HabitsViewModel vm, String today) {
    final bool isDoneToday = habit.lastChecked == today;
    final Color habitColor = Color(int.parse(habit.color.replaceFirst('#', '0xFF')));

    // Nhãn Thứ cố định từ T2 -> CN (Khớp với index 0 -> 6 trong history)
    final weekdayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final int currentWeekdayIndex = DateTime.now().weekday - 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: ChronosCard(
        padding: 20,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showHabitSheet(context, habit: habit),
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            IconData(habit.icon, fontFamily: 'MaterialIcons'),
                            color: habitColor,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.name,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              habit.goal.toUpperCase(),
                              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                // Streak Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 12),
                      const SizedBox(width: 4),
                      Text("${habit.streak}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 24),

            // LOGIC FIX: Hiển thị 7 dấu chấm dựa trên index mảng history
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                // habit.history[0] là Thứ 2, [6] là Chủ Nhật
                bool isMarked = habit.history[index];
                bool isDayInFuture = index > currentWeekdayIndex; // Làm mờ các ngày chưa tới

                return Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        color: isMarked ? habitColor : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isMarked ? habitColor : (isDayInFuture ? Colors.white.withOpacity(0.02) : Colors.white.withOpacity(0.1)),
                          width: 1.5,
                        ),
                        boxShadow: isMarked ? [BoxShadow(color: habitColor.withOpacity(0.4), blurRadius: 8)] : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      weekdayLabels[index],
                      style: TextStyle(
                        fontSize: 8,
                        color: index == currentWeekdayIndex ? AppColors.primary : Colors.grey,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                );
              }),
            ),

            const SizedBox(height: 24),

            // Nút Check-in
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => vm.toggleCheckIn(habit),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDoneToday ? AppColors.surfaceDark : habitColor,
                  foregroundColor: isDoneToday ? Colors.grey : AppColors.backgroundDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: isDoneToday ? 0 : 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isDoneToday ? Icons.check_circle : Icons.radio_button_unchecked, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      isDoneToday ? "ĐÃ HOÀN THÀNH" : "ĐIỂM DANH HÔM NAY",
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAddPlaceholder(BuildContext context) {
    return InkWell(
      onTap: () => _showHabitSheet(context),
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 2),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white.withOpacity(0.2)),
            const SizedBox(width: 8),
            Text(
              "TẠO THÓI QUEN MỚI",
              style: TextStyle(color: Colors.white.withOpacity(0.2), fontWeight: FontWeight.w900, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.track_changes, size: 64, color: Colors.white10),
          SizedBox(height: 16),
          Text("CHƯA CÓ THÓI QUEN NÀO", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  void _showHabitSheet(BuildContext context, {HabitModel? habit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HabitDetailSheet(habit: habit),
    );
  }
}