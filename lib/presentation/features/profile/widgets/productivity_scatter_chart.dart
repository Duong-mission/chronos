import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chronos/core/constants/app_colors.dart';
import '../view_models/profile_view_model.dart';

class ProductivityScatterChart extends StatelessWidget {
  const ProductivityScatterChart({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final spots = vm.productivityScatterSpots;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          // Header biểu đồ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TƯƠNG QUAN TÂM TRẠNG & HIỆU SUẤT",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Dữ liệu 12 ngày gần nhất",
                    style: TextStyle(fontSize: 8, color: Colors.white10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "AI CORRELATION",
                  style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Vùng biểu đồ
          Expanded(
            child: ScatterChart(
              ScatterChartData(
                scatterSpots: spots,
                minX: 0, maxX: 6, // Trục Mood (Tệ -> Tuyệt)
                minY: 0, maxY: 11, // Trục Hiệu suất (0 -> 10)
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.02), strokeWidth: 1),
                  getDrawingVerticalLine: (value) => FlLine(color: Colors.white.withOpacity(0.02), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  // Nhãn trục X: Các mức tâm trạng
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const moodLabels = ['', 'TỆ', 'BUỒN', 'ỔN', 'VUI', 'TUYỆT', ''];
                        if (value.toInt() < 0 || value.toInt() >= moodLabels.length) return const SizedBox();
                        return Text(
                          moodLabels[value.toInt()],
                          style: const TextStyle(color: Colors.white24, fontSize: 7, fontWeight: FontWeight.w900),
                        );
                      },
                    ),
                  ),
                  // Nhãn trục Y: Điểm hiệu suất
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value > 10) return const SizedBox();
                        return Text(
                          "${value.toInt()}/10",
                          style: const TextStyle(color: Colors.white24, fontSize: 7, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                scatterTouchData: ScatterTouchData(
                  touchTooltipData: ScatterTouchTooltipData(
                    // getTooltipColor: (spot) => AppColors.surfaceDark,
                    getTooltipItems: (spot) {
                      return ScatterTooltipItem(
                        "Tâm trạng: ${spot.x.toInt()}/5\nHiệu suất: ${spot.y.toInt()}/10",
                        textStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          // Chú thích chân trang giống React
          const Text(
            "CÀNG VỀ GÓC TRÊN BÊN PHẢI CÀNG TỐI ƯU",
            style: TextStyle(
              fontSize: 8,
              color: Colors.white10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}