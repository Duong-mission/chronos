import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:chronos/core/constants/app_colors.dart';
import 'package:chronos/core/components/chronos_card.dart';
import 'package:chronos/presentation/features/finance/view_models/finance_view_model.dart';

class FinanceAnalyticsScreen extends StatefulWidget {
  const FinanceAnalyticsScreen({super.key});

  @override
  State<FinanceAnalyticsScreen> createState() => _FinanceAnalyticsScreenState();
}

class _FinanceAnalyticsScreenState extends State<FinanceAnalyticsScreen> {
  // Tạo dải năm rộng để tạo cảm giác "vô tận" (2000 - 2100)
  final List<int> availableYears = List.generate(101, (index) => 2100 - index);
  late FixedExtentScrollController _wheelController;

  @override
  void initState() {
    super.initState();
    final vm = context.read<FinanceViewModel>();
    int initialIndex = availableYears.indexOf(vm.selectedYear);
    _wheelController = FixedExtentScrollController(
      initialItem: initialIndex != -1 ? initialIndex : 0,
    );
  }

  @override
  void dispose() {
    _wheelController.dispose();
    super.dispose();
  }

  String _formatVND(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0)
        .format(amount)
        .replaceAll(",00", "");
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FinanceViewModel>();
    final chartData = vm.getMonthlyChartData();
    final summary = vm.yearlySummary;
    final balance = vm.yearlyBalance;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // 1. HEADER (BACK BUTTON + TITLE)
              _buildHeader(context),
              const SizedBox(height: 32),

              // 2. 3D WHEEL & SUMMARY CARD (Tỷ lệ 4:8)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- VERTICAL 3D WHEEL ---
                  Expanded(
                    flex: 4,
                    child: _buildYearWheel(vm),
                  ),
                  const SizedBox(width: 16),
                  // --- YEARLY SUMMARY CARD ---
                  Expanded(
                    flex: 8,
                    child: _buildSummaryCard(vm, summary, balance),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 3. BIẾN ĐỘNG DÒNG TIỀN (AREA CHART)
              _buildAreaChart(chartData),

              const SizedBox(height: 24),

              // 4. AI ANALYTICAL ADVISOR
              _buildAiInsightBox(vm, balance),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.grey),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Kho lưu trữ", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            Text("Xoay vòng quay chọn năm", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
          ],
        )
      ],
    );
  }

  Widget _buildYearWheel(FinanceViewModel vm) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Overlay highlight
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.symmetric(horizontal: BorderSide(color: AppColors.primary.withOpacity(0.2))),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: _wheelController,
            itemExtent: 50,
            perspective: 0.005, // Hiệu ứng 3D
            diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              vm.setSelectedYear(availableYears[index]);
              HapticFeedback.lightImpact(); // Rung nhẹ khi cuộn giống React
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: availableYears.length,
              builder: (context, index) {
                bool isSelected = vm.selectedYear == availableYears[index];
                return Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: isSelected ? 26 : 18,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? AppColors.primary : Colors.white10,
                      shadows: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 15)] : null,
                    ),
                    child: Text("${availableYears[index]}"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(FinanceViewModel vm, Map<String, double> summary, double balance) {
    return ChronosCard(
      height: 190,
      gradient: const LinearGradient(
        colors: [Color(0xFF1B3D2B), Color(0xFF0A1A12)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "THẶNG DƯ NIÊN ĐỘ ${vm.selectedYear}".toUpperCase(),
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 2),
          ),
          const SizedBox(height: 12),
          Text(
            _formatVND(balance),
            style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w900,
              color: balance >= 0 ? Colors.white : Colors.redAccent,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),
          Row(
            children: [
              _summaryItem("TỔNG THU", _formatVND(summary['income']!), AppColors.primary),
              const Spacer(),
              _summaryItem("TỔNG CHI", _formatVND(summary['expense']!), Colors.redAccent),
            ],
          )
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 2),
        Text(value.split(' ')[0], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
      ],
    );
  }

  Widget _buildAreaChart(List<Map<String, dynamic>> chartData) {
    return ChronosCard(
      padding: 24,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("BIẾN ĐỘNG DÒNG TIỀN (K VND)",
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
              Row(
                children: [
                  _chartLegend("Thu", AppColors.primary),
                  const SizedBox(width: 12),
                  _chartLegend("Chi", Colors.redAccent),
                ],
              )
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (val, meta) {
                        int idx = val.toInt();
                        if (idx < 0 || idx >= chartData.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(chartData[idx]['name'],
                              style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  _lineBarData(chartData, 'thu', AppColors.primary),
                  _lineBarData(chartData, 'chi', Colors.redAccent),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((s) => LineTooltipItem(
                        "${s.y.toInt()}K",
                        TextStyle(color: s.barIndex == 0 ? AppColors.primary : Colors.redAccent, fontWeight: FontWeight.bold),
                      )).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _lineBarData(List<Map<String, dynamic>> data, String key, Color color) {
    return LineChartBarData(
      spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i][key].toDouble())),
      isCurved: true,
      color: color,
      barWidth: 3,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _chartLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAiInsightBox(FinanceViewModel vm, double balance) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 15)],
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "LỜI KHUYÊN NIÊN ĐỘ ${vm.selectedYear}".toUpperCase(),
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 1),
                ),
                const SizedBox(height: 6),
                Text(
                  balance >= 0
                      ? "Tuyệt vời! Trong năm ${vm.selectedYear}, thặng dư của bạn đạt mức khả quan. Hãy cân nhắc tái đầu tư 20% vào học tập."
                      : "Hệ thống ghi nhận thâm hụt trong năm ${vm.selectedYear}. Hãy rà soát lại các mục chi tiêu không thiết yếu.",
                  style: const TextStyle(fontSize: 12, color: Colors.white70, fontStyle: FontStyle.italic, height: 1.5),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}