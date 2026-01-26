import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chronos/core/constants/app_colors.dart';
import '../view_models/profile_view_model.dart';

class MoodTrendChart extends StatelessWidget {
  const MoodTrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final data = vm.moodTrendData;

    // Chuyển đổi Map sang FlSpot
    final List<FlSpot> spots = List.generate(data.length, (i) {
      return FlSpot(i.toDouble(), data[i]['score']);
    });

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
                "BIẾN THIÊN TÂM TRẠNG (7 NGÀY)",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey,
                  letterSpacing: 1.5,
                ),
              ),
              const Text(
                "MOOD PULSE",
                style: TextStyle(
                  color: AppColors.purple,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  // Cấu hình nhãn ngày tháng bên dưới (X-Axis)
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= data.length) return const SizedBox();
                        return Text(
                          data[index]['date'],
                          style: const TextStyle(
                            color: Colors.white24,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 6, // Thang điểm tâm trạng 0-5
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    // getTooltipColor: (spot) => AppColors.surfaceDark,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((s) {
                        String moodLabel = _getMoodLabel(s.y);
                        return LineTooltipItem(
                          "$moodLabel (${s.y.toInt()}/5)",
                          const TextStyle(color: AppColors.purple, fontWeight: FontWeight.bold, fontSize: 10),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.4,
                    color: AppColors.purple,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    // Hiệu ứng vùng tím mờ phía dưới (Area Chart)
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.purple.withOpacity(0.3),
                          AppColors.purple.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMoodLabel(double score) {
    if (score >= 5) return "Tuyệt vời";
    if (score >= 4) return "Tốt";
    if (score >= 3) return "Ổn";
    if (score >= 2) return "Tệ";
    return "Rất tệ";
  }
}