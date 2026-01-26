import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
import 'package:chronos/core/constants/app_colors.dart';
import '../view_models/profile_view_model.dart';

class SpendingPieChart extends StatelessWidget {
  const SpendingPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final data = vm.spendingPieData;
    final total = vm.totalExpenseSum;

    return Container(
      height: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "PHÂN BỔ CHI TIÊU",
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: Colors.grey,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                // 1. Biểu đồ Donut (Bên trái)
                Expanded(
                  flex: 3,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Text hiển thị tổng ở giữa Donut
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("TỔNG CHI", style: TextStyle(fontSize: 7, color: Colors.grey, fontWeight: FontWeight.bold)),
                          Text(
                            "${(total / 1000).toStringAsFixed(0)}K",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      PieChart(
                        PieChartData(
                          sectionsSpace: 6, // paddingAngle={8} trong React
                          centerSpaceRadius: 45, // innerRadius={50}
                          startDegreeOffset: -90,
                          sections: data.map((item) {
                            return PieChartSectionData(
                              color: item['color'],
                              value: item['value'],
                              radius: 18, // Độ dày của vành Donut
                              showTitle: false,
                              badgeWidget: _buildPercentageBadge(item['value'], total),
                              badgePositionPercentageOffset: 1.4,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // 2. Chú thích (Legend) bên phải
                Expanded(
                  flex: 2,
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: data.map((item) => _buildLegendItem(item)).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageBadge(double value, double total) {
    if (total == 0) return const SizedBox();
    int percent = ((value / total) * 100).toInt();
    if (percent < 5) return const SizedBox(); // Ẩn nếu quá nhỏ để tránh đè chữ
    return Text(
      "$percent%",
      style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white60),
    );
  }

  Widget _buildLegendItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: item['color'], shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item['name'].toString().toUpperCase(),
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white38),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}