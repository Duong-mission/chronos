import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chronos/core/constants/app_colors.dart';
import '../view_models/profile_view_model.dart';

class ActivityHeatmap extends StatelessWidget {
  const ActivityHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final data = vm.activityHeatmapData;

    return Container(
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
                "TẦN SUẤT HOẠT ĐỘNG",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                "4 TUẦN GẦN NHẤT",
                style: TextStyle(
                  color: AppColors.primary.withOpacity(0.4),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Lưới Heatmap (7 cột x 4 hàng)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // 7 ngày trong tuần
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1,
            ),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final level = data[index];
              return _buildHeatBox(level);
            },
          ),

          const SizedBox(height: 16),
          _buildHeatLegend(),
        ],
      ),
    );
  }

  Widget _buildHeatBox(int level) {
    Color color;
    List<BoxShadow>? shadow;

    switch (level) {
      case 3:
        color = AppColors.primary;
        shadow = [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 8)];
        break;
      case 2:
        color = AppColors.primary.withOpacity(0.6);
        break;
      case 1:
        color = AppColors.primary.withOpacity(0.2);
        break;
      default:
        color = Colors.white.withOpacity(0.05);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        boxShadow: shadow,
      ),
    );
  }

  Widget _buildHeatLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text("ÍT", style: TextStyle(fontSize: 7, color: Colors.white24, fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        _buildHeatBox(0).setHeightWidth(8, 8),
        const SizedBox(width: 2),
        _buildHeatBox(1).setHeightWidth(8, 8),
        const SizedBox(width: 2),
        _buildHeatBox(2).setHeightWidth(8, 8),
        const SizedBox(width: 2),
        _buildHeatBox(3).setHeightWidth(8, 8),
        const SizedBox(width: 4),
        const Text("NHIỀU", style: TextStyle(fontSize: 7, color: Colors.white24, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// Extension helper để set size nhanh cho legend
extension on Widget {
  Widget setHeightWidth(double h, double w) => SizedBox(height: h, width: w, child: this);
}