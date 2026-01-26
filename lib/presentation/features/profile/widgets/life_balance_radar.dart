import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import hệ thống
import 'package:chronos/core/constants/app_colors.dart';
import '../view_models/profile_view_model.dart';

class LifeBalanceRadar extends StatelessWidget {
  const LifeBalanceRadar({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Lấy dữ liệu thực tế từ ViewModel
    final vm = context.watch<ProfileViewModel>();
    final scores = vm.lifeBalanceScores;

    // Thứ tự các nhãn phải khớp với logic mapping trong ViewModel
    final labels = ['Học tập', 'Tài chính', 'Sức khỏe', 'Tâm hồn', 'Xã hội'];

    return Container(
      height: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          // Header: Tiêu đề và Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "BẢN ĐỒ CÂN BẰNG",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "LIFE 360°",
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 8,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Vùng biểu đồ Radar
          Expanded(
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.circle, // Tạo hình tròn giống React PolarGrid
                dataSets: [
                  RadarDataSet(
                    fillColor: AppColors.primary.withOpacity(0.25), // Màu Neon mờ
                    borderColor: AppColors.primary,
                    borderWidth: 2,
                    entryRadius: 3,
                    // Map dữ liệu từ scores sang RadarEntry
                    dataEntries: labels.map((label) {
                      return RadarEntry(value: scores[label] ?? 50.0);
                    }).toList(),
                  ),
                ],

                // Cấu hình nhãn tiêu đề cho các góc
                getTitle: (index, angle) {
                  return RadarChartTitle(
                    text: labels[index].toUpperCase(),
                    angle: angle,
                  );
                },
                titleTextStyle: const TextStyle(
                    color: Colors.white60,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1
                ),

                // Cấu hình lưới (Grid)
                gridBorderData: BorderSide(
                    color: Colors.white.withOpacity(0.05),
                    width: 1
                ),

                // Cấu hình các đường gạch chia mức (Ticks)
                tickBorderData: const BorderSide(color: Colors.transparent),
                ticksTextStyle: const TextStyle(color: Colors.transparent), // Ẩn số điểm ở giữa

                // Tắt tương tác Tooltip để tránh lỗi "Undefined" trên bản 0.66.0
                radarTouchData: RadarTouchData(enabled: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}