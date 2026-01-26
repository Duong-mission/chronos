import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chronos/core/constants/app_colors.dart';
import '../view_models/profile_view_model.dart';

class PriorityRadialChart extends StatelessWidget {
  const PriorityRadialChart({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final data = vm.priorityDistribution;

    return Container(
      height: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "ƯU TIÊN & NỖ LỰC",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey,
                  letterSpacing: 1.5,
                ),
              ),
              const Text(
                "RADIAL EFFORT",
                style: TextStyle(color: Colors.white10, fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Text ở giữa biểu đồ (giống Radial Chart thường có)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      vm.tasks.length.toString(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const Text("MỤC TIÊU", style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
                // Biểu đồ Radial giả lập bằng PieChart
                PieChart(
                  PieChartData(
                    sectionsSpace: 12, // Khoảng cách giữa các thanh
                    centerSpaceRadius: 40,
                    startDegreeOffset: -90,
                    sections: List.generate(data.length, (i) {
                      final item = data[i];
                      // Bán kính thay đổi (40, 55, 70) để tạo hiệu ứng Radial Bar
                      final double radius = 40.0 + (i * 15.0);

                      return PieChartSectionData(
                        color: item['color'],
                        value: item['value'] == 0 ? 0.1 : item['value'], // Tránh lỗi giá trị 0
                        radius: radius,
                        showTitle: true,
                        title: item['value'].toInt().toString(),
                        titleStyle: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.backgroundDark
                        ),
                        badgeWidget: _buildBadgeIcon(item['name']),
                        badgePositionPercentageOffset: 0.98,
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildLegend(data),
        ],
      ),
    );
  }

  Widget? _buildBadgeIcon(String priority) {
    IconData icon;
    Color color;
    if (priority == 'Cao') {
      icon = Icons.priority_high;
      color = AppColors.red;
    } else if (priority == 'Trung bình') {
      icon = Icons.bolt;
      color = AppColors.orange;
    } else {
      icon = Icons.low_priority;
      color = AppColors.blue;
    }
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, size: 8, color: Colors.white),
    );
  }

  Widget _buildLegend(List<Map<String, dynamic>> data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: data.map((item) {
        return Row(
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: item['color'], shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              item['name'].toUpperCase(),
              style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.w900),
            ),
          ],
        );
      }).toList(),
    );
  }
}