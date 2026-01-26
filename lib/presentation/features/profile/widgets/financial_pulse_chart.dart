import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chronos/core/constants/app_colors.dart';
import '../view_models/profile_view_model.dart';

class FinancialPulseChart extends StatelessWidget {
  const FinancialPulseChart({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final data = vm.financialPulseData;

    return Container(
      height: 250,
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
                "MẠCH TÀI CHÍNH (K VND)",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey,
                  letterSpacing: 1.5,
                ),
              ),
              _buildMiniLegend(),
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
                      final mData = data[groupIndex];
                      return BarTooltipItem(
                        "${mData['month']}\n",
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(text: "Thu: ${mData['thu'].toInt()}K\n", style: const TextStyle(color: AppColors.primary, fontSize: 10)),
                          TextSpan(text: "Chi: ${mData['chi'].toInt()}K", style: const TextStyle(color: AppColors.red, fontSize: 10)),
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
                            data[index]['month'],
                            style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(data.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      // Cột THU NHẬP (To, Neon Green)
                      BarChartRodData(
                        toY: data[i]['thu'],
                        color: AppColors.primary,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: _getMaxY(data),
                          color: Colors.white.withOpacity(0.02),
                        ),
                      ),
                      // Cột CHI TIÊU (Mảnh, Neon Red - Giả lập đường Line)
                      BarChartRodData(
                        toY: data[i]['chi'],
                        color: AppColors.red,
                        width: 4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                    barsSpace: 4,
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxY(List<Map<String, dynamic>> data) {
    double max = 1000;
    for (var item in data) {
      if (item['thu'] > max) max = item['thu'];
      if (item['chi'] > max) max = item['chi'];
    }
    return max * 1.2;
  }

  Widget _buildMiniLegend() {
    return Row(
      children: [
        _dot(AppColors.primary, "THU"),
        const SizedBox(width: 12),
        _dot(AppColors.red, "CHI"),
      ],
    );
  }

  Widget _dot(Color color, String label) {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.w900)),
      ],
    );
  }
}