import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:chronos/core/constants/app_colors.dart';
import 'package:chronos/data/models/task_model.dart';

class CalendarEventCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback? onTap;
  final bool isCompact;

  const CalendarEventCard({
    super.key,
    required this.item,
    this.onTap,
    this.isCompact = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTask = item is TaskModel;
    final String title = item.title;
    final String startTime = isTask ? item.startTime : item.time;
    final bool isCompleted = isTask ? item.completed : false;

    Color baseColor;
    if (isTask) {
      if (item.priority == 'Cao') baseColor = Colors.redAccent;
      else if (item.priority == 'Trung bình') baseColor = Colors.orangeAccent;
      else baseColor = AppColors.primary;
    } else {
      try {
        baseColor = Color(int.parse(item.color.replaceFirst('#', '0xFF')));
      } catch (e) {
        baseColor = AppColors.primary;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isCompleted ? 0.5 : 1.0,
        child: LayoutBuilder( // Dùng LayoutBuilder để biết chiều cao thực tế của ô
          builder: (context, constraints) {
            final double h = constraints.maxHeight;
            // Nếu chiều cao quá thấp (dưới 40px), chúng ta sẽ ẩn bớt thông tin
            bool showTime = h > 45;
            bool showIcon = h > 55;

            return Container(
              margin: const EdgeInsets.all(0.5),
              decoration: BoxDecoration(
                color: baseColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border(left: BorderSide(color: baseColor, width: 3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // TIÊU ĐỀ (Luôn hiển thị)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isTask && showIcon)
                              Padding(
                                padding: const EdgeInsets.only(top: 2, right: 4),
                                child: Icon(Icons.task_alt, size: 10, color: baseColor),
                              ),
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: isCompact ? 9 : 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.1,
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                ),
                                maxLines: h > 80 ? 4 : (h > 40 ? 2 : 1),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        // THỜI GIAN (Chỉ hiện nếu ô đủ cao)
                        if (showTime) ...[
                          const Spacer(),
                          Text(
                            startTime,
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}