import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chronos/core/constants/app_colors.dart';
import 'package:chronos/core/components/chronos_card.dart';
import 'package:chronos/data/models/task_model.dart';
// import 'package:chronos/data/models/calendar_event_model.dart';
import '../view_models/calendar_view_model.dart';

class CalendarMonthGrid extends StatelessWidget {
  final CalendarViewModel vm;

  const CalendarMonthGrid({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final days = vm.monthGridDays;
    final weekdayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Column(
      children: [
        // 1. Header Thứ (T2 -> CN)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdayLabels
                .map((label) => Text(
              label,
              style: const TextStyle(
                color: Colors.white24,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ))
                .toList(),
          ),
        ),

        // 2. Lưới ngày trong tháng
        Expanded(
          flex: 3,
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final date = days[index];
              if (date == null) return const SizedBox();

              final dateStr = DateFormat('yyyy-MM-dd').format(date);
              final items = vm.getItemsForDate(dateStr);

              bool isSelected = vm.selectedDateStr == dateStr;
              bool isToday = dateStr == DateFormat('yyyy-MM-dd').format(DateTime.now());

              // Logic Heatmap giống React: Càng nhiều việc ô càng sáng
              double intensity = (items.length * 0.2).clamp(0.0, 0.8);

              return GestureDetector(
                onTap: () => vm.setSelectedDate(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.primary.withOpacity(intensity * 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.05),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                      )
                    ] : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: isToday
                              ? AppColors.primary
                              : (isSelected ? Colors.white : Colors.white38),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Chấm nhỏ báo hiệu có sự kiện (nếu không được chọn)
                      if (items.isNotEmpty && !isSelected)
                        Positioned(
                          bottom: 6,
                          child: Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // 3. Danh sách chi tiết ngày được chọn (Phần dưới lưới)
        Expanded(
          flex: 2,
          child: _buildSelectedDayList(context),
        ),
      ],
    );
  }

  Widget _buildSelectedDayList(BuildContext context) {
    final items = vm.getItemsForDate(vm.selectedDateStr);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "NGÀY ${vm.selectedDate.day} THÁNG ${vm.selectedDate.month}",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white38,
                  letterSpacing: 2,
                ),
              ),
              Text(
                "${items.length} MỤC",
                style: const TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: items.isEmpty
                ? const Center(
              child: Text(
                "Trống",
                style: TextStyle(color: Colors.white10, fontWeight: FontWeight.bold),
              ),
            )
                : ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                bool isTask = item is TaskModel;

                // Lấy màu sắc
                Color itemColor;
                if (isTask) {
                  itemColor = item.priority == 'Cao' ? Colors.redAccent : AppColors.primary;
                } else {
                  itemColor = Color(int.parse(item.color.replaceFirst('#', '0xFF')));
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ChronosCard(
                    padding: 16,
                    borderRadius: 24,
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: itemColor,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [BoxShadow(color: itemColor, blurRadius: 8)],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            isTask ? "📋 ${item.title}" : item.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isTask && item.completed ? Colors.white24 : Colors.white,
                              decoration: isTask && item.completed ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        Text(
                          isTask ? item.startTime : item.time,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white24,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}