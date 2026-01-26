import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chronos/core/constants/app_colors.dart';
import '../view_models/profile_view_model.dart';

class EfficiencyBarChart extends StatelessWidget {
  const EfficiencyBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final data = vm.categoryEfficiencyData;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "HIỆU SUẤT DANH MỤC",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey,
                  letterSpacing: 1.5,
                ),
              ),
              const Icon(Icons.bar_chart, color: AppColors.primary, size: 16),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(data),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    // getTooltipColor: (group) => AppColors.surfaceDark,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final category = data[groupIndex];
                      return BarTooltipItem(
                        "${category['name']}\n",
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        children: [
                          TextSpan(
                            text: "Xong: ${category['done']}",
                            style: const TextStyle(color: AppColors.primary, fontSize: 11),
                          ),
                          TextSpan(
                            text: " / Còn: ${category['remaining']}",
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= data.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            data[index]['name'].toString().toUpperCase(),
                            style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.w900),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(data.length, (i) {
                  final done = (data[i]['done'] as num).toDouble();
                  final remaining = (data[i]['remaining'] as num).toDouble();
                  final total = done + remaining;

                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: total,
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                        // ĐIỂM QUAN TRỌNG: Stacked logic giống React stackId="a"
                        rodStackItems: [
                          BarChartRodStackItem(0, done, AppColors.primary),
                          BarChartRodStackItem(done, total, Colors.white.withOpacity(0.05)),
                        ],
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildLegend(),
        ],
      ),
    );
  }

  double _getMaxY(List<Map<String, dynamic>> data) {
    double max = 5;
    for (var item in data) {
      double sum = (item['done'] + item['remaining']).toDouble();
      if (sum > max) max = sum;
    }
    return max + 2;
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem("Xong", AppColors.primary),
        const SizedBox(width: 16),
        _legendItem("Chưa", Colors.white10),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold)),
      ],
    );
  }
}