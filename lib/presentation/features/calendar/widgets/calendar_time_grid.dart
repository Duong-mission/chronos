import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chronos/core/constants/app_colors.dart';
import 'package:chronos/data/models/task_model.dart';

import 'package:chronos/presentation/features/calendar/widgets/calendar_event_card.dart';
import '../view_models/calendar_view_model.dart';

class CalendarTimeGrid extends StatelessWidget {
  final CalendarViewModel vm;
  final double currentTimePos;
  final ScrollController scrollController;

  const CalendarTimeGrid({
    super.key,
    required this.vm,
    required this.currentTimePos,
    required this.scrollController,
  });

  // Hàm hỗ trợ chuyển đổi chuỗi "HH:mm" thành tổng số phút để tính tọa độ
  int _timeToMinutes(String time) {
    try {
      final parts = time.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rangeDays = vm.currentRangeDays;
    const double hourHeight = 60.0; // 1 giờ = 60px (tương đương 1 phút = 1px)

    return Column(
      children: [
        // 1. Header Ngày (Thứ & Số ngày) - Cố định phía trên
        Padding(
          padding: const EdgeInsets.only(left: 60, right: 10, bottom: 10),
          child: Row(
            children: rangeDays.map((date) {
              bool isToday = DateFormat('yyyy-MM-dd').format(date) ==
                  DateFormat('yyyy-MM-dd').format(DateTime.now());
              return Expanded(
                child: Column(
                  children: [
                    Text(
                      DateFormat('E', 'vi_VN').format(date).toUpperCase(),
                      style: TextStyle(
                        color: isToday ? AppColors.primary : Colors.white24,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        color: isToday ? AppColors.primary : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        // 2. Lưới thời gian cuộn dọc
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              height: 1440, // 24 giờ * 60px
              child: Stack(
                children: [
                  // A. Các đường kẻ ngang và nhãn giờ bên trái
                  for (int i = 0; i < 24; i++)
                    Positioned(
                      top: i * hourHeight,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: hourHeight,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.white.withOpacity(0.03)),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, top: 2),
                          child: Text(
                            "${i.toString().padLeft(2, '0')}:00",
                            style: const TextStyle(
                              color: Colors.white10,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // B. Các cột sự kiện cho từng ngày trong dải hiển thị
                  Positioned.fill(
                    left: 60,
                    child: Row(
                      children: rangeDays.map((date) {
                        final dateStr = DateFormat('yyyy-MM-dd').format(date);
                        return Expanded(
                          child: Stack(
                            children: [
                              // Đường kẻ dọc phân cách ngày
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(color: Colors.white.withOpacity(0.03)),
                                  ),
                                ),
                              ),
                              // Render các khối Event/Task cho ngày này
                              ..._buildBlocksForDate(context, dateStr),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // C. Thanh thời gian hiện tại (Màu đỏ)
                  Positioned(
                    top: currentTimePos,
                    left: 0,
                    right: 0,
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 4, backgroundColor: Colors.red),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.red.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- LOGIC TÍNH TOÁN VỊ TRÍ VÀ CHIỀU CAO ĐỘNG ---
  List<Widget> _buildBlocksForDate(BuildContext context, String dateStr) {
    final items = vm.getItemsForDate(dateStr);

    return items.map((item) {
      final bool isTask = item is TaskModel;

      // 1. Lấy thời gian bắt đầu và kết thúc
      final String startTimeStr = isTask ? item.startTime : item.time;
      // Nếu là Task thì lấy dueTime, nếu là Event thì mặc định kéo dài 60 phút
      final String endTimeStr = isTask ? item.dueTime : item.time;

      final int startMinutes = _timeToMinutes(startTimeStr);
      int endMinutes = _timeToMinutes(endTimeStr);

      // Xử lý logic chiều cao:
      // Nếu là Event (chỉ có 1 mốc giờ) hoặc giờ kết thúc nhỏ hơn giờ bắt đầu
      if (!isTask || endMinutes <= startMinutes) {
        endMinutes = startMinutes + 60; // Mặc định hiển thị khối 1 tiếng
      }

      // Tọa độ Y (top) = số phút tính từ 00:00
      final double top = startMinutes.toDouble();

      // Chiều cao (height) = số phút chênh lệch
      // Clamp tối thiểu 35px để đảm bảo vẫn đọc được chữ trong card
      final double height = (endMinutes - startMinutes).toDouble().clamp(35.0, 1440.0);

      return Positioned(
        top: top,
        left: 2, // Lề trái phải cực nhỏ để tối ưu cho chế độ xem Tuần
        right: 2,
        child: SizedBox(
          height: height,
          child: CalendarEventCard(
            item: item,
            isCompact: true,
            onTap: () => _handleItemTap(context, item),
          ),
        ),
      );
    }).toList();
  }

  void _handleItemTap(BuildContext context, dynamic item) {
    if (item is TaskModel) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceDark,
          content: Text(
            "Công việc: ${item.title}. Quản lý tại tab Việc làm.",
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      // Logic mở modal sửa sự kiện nếu cần
    }
  }
}