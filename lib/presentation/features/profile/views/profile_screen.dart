import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Core & Theme ---
import 'package:chronos/core/components/chronos_card.dart';
import 'package:chronos/core/components/chronos_header.dart';
import 'package:chronos/core/constants/app_colors.dart';
import '../view_models/profile_view_model.dart';

// --- 10 Widgets Biểu Đồ Chuyên Sâu ---
import '../widgets/growth_curve_chart.dart';
import '../widgets/mood_trend_chart.dart';
import '../widgets/productivity_scatter_chart.dart';
import '../widgets/life_balance_radar.dart';
import '../widgets/energy_pulse_chart.dart';
import '../widgets/activity_heatmap.dart';
import '../widgets/spending_pie_chart.dart';
import '../widgets/financial_pulse_chart.dart';
import '../widgets/efficiency_bar_chart.dart';
import '../widgets/priority_radial_chart.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe ViewModel (Dữ liệu thực tế từ Isar)
    final vm = context.watch<ProfileViewModel>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER CHÍNH
              const ChronosHeader(
                title: "Analytics Center",
                subtitle: "Phân tích dữ liệu cuộc sống đa chiều",
              ),

              // 2. THẺ PROFILE TỔNG QUAN
              _buildProfileCard(),
              const SizedBox(height: 32),

              // 3. PHÂN KHU: TĂNG TRƯỞNG & XP (Real-time data)
              _buildSectionHeader("TIẾN TRÌNH PHÁT TRIỂN"),
              const GrowthCurveChart(),
              const SizedBox(height: 32),

              // 4. PHÂN KHU: SỨC KHỎE TÂM TRÍ & TƯƠNG QUAN
              _buildSectionHeader("SỨC KHỎE TÂM TRÍ"),
              const MoodTrendChart(),
              const SizedBox(height: 16),
              const ProductivityScatterChart(),
              const SizedBox(height: 32),

              // 5. PHÂN KHU: CÂN BẰNG CUỘC SỐNG (RADAR)
              _buildSectionHeader("BẢN ĐỒ CÂN BẰNG"),
              const LifeBalanceRadar(),
              const SizedBox(height: 32),

              // 6. PHÂN KHU: KỶ LUẬT & NĂNG LƯỢNG
              _buildSectionHeader("NHỊP ĐỘ HOẠT ĐỘNG"),
              const EnergyPulseChart(),
              const SizedBox(height: 12),
              const ActivityHeatmap(), // 28 ngày thực tế
              const SizedBox(height: 32),

              // 7. PHÂN KHU: QUẢN TRỊ TÀI CHÍNH
              _buildSectionHeader("QUẢN TRỊ TÀI CHÍNH"),
              const SpendingPieChart(),
              const SizedBox(height: 16),
              const FinancialPulseChart(),
              const SizedBox(height: 32),

              // 8. PHÂN KHU: HIỆU SUẤT CÔNG VIỆC
              _buildSectionHeader("CHIẾN LƯỢC MỤC TIÊU"),
              const EfficiencyBarChart(),
              const SizedBox(height: 16),
              const PriorityRadialChart(),
              const SizedBox(height: 32),

              // 9. AI ANALYTICAL ADVISOR (Kết nối Gemini AI)
              _buildAiAdvisor(vm),
              const SizedBox(height: 32),

              // 10. ĐIỀU KHIỂN HỆ THỐNG
              _buildSystemControls(context, vm),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS THÀNH PHẦN CHI TIẾT ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.white24,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return ChronosCard(
      showNeon: true,
      padding: 30,
      child: Column(
        children: [
          // Avatar với viền Neon
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 2),
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage("https://api.dicebear.com/7.x/avataaars/svg?seed=Felix"),
              backgroundColor: AppColors.surfaceDark,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Nguyễn Minh Tuấn",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "LEVEL 18",
                  style: TextStyle(
                    color: AppColors.backgroundDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "DỮ LIỆU THỜI GIAN THỰC",
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiAdvisor(ProfileViewModel vm) {
    return ChronosCard(
      color: const Color(0xFF1B3D2B), // Xanh rêu đậm chuẩn React
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "AI ANALYTICAL ADVISOR".toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ],
              ),
              // Nút làm mới phân tích AI
              IconButton(
                onPressed: vm.isLoadingAi ? null : () => vm.getAiInsight(),
                icon: Icon(
                  Icons.sync,
                  color: AppColors.primary,
                  size: 18,
                ),
                style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.05)),
              )
            ],
          ),
          const SizedBox(height: 12),
          if (vm.isLoadingAi)
            const LinearProgressIndicator(backgroundColor: Colors.transparent, color: AppColors.primary)
          else
            Text(
              vm.aiInsight ?? "Nhấn nút xoay để Chronos AI quét dữ liệu 28 ngày qua và đưa ra chiến lược phát triển cá nhân tối ưu cho bạn.",
              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.white70, height: 1.6),
            ),
        ],
      ),
    );
  }

  Widget _buildSystemControls(BuildContext context, ProfileViewModel vm) {
    return Column(
      children: [
        // Nút Reset sạch dữ liệu (thay cho nút Seeder cũ)
        InkWell(
          onTap: () => _confirmClearData(context, vm),
          borderRadius: BorderRadius.circular(32),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.red.withOpacity(0.05),
              border: Border.all(color: AppColors.red.withOpacity(0.2), width: 1.5),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("DỌN DẸP TOÀN BỘ HỆ THỐNG",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.red)),
                    Text("Xóa vĩnh viễn mọi ký ức và dữ liệu",
                        style: TextStyle(fontSize: 8, color: Colors.white38, fontWeight: FontWeight.bold)),
                  ],
                ),
                Icon(Icons.delete_sweep, color: AppColors.red),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Nút Logout
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
            minimumSize: const Size(double.infinity, 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
              side: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
          ),
          child: const Text(
            "ĐĂNG XUẤT TÀI KHOẢN",
            style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
          ),
        ),
      ],
    );
  }

  void _confirmClearData(BuildContext context, ProfileViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: const Text("XÓA TẤT CẢ DỮ LIỆU?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.red)),
        content: const Text("Hành động này sẽ xóa sạch Task, Tài chính, Nhật ký và Thói quen. Bạn không thể hoàn tác."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("HỦY")),
          TextButton(
            onPressed: () {
              vm.clearAllData();
              Navigator.pop(context);
            },
            child: const Text("XÁC NHẬN XÓA", style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}