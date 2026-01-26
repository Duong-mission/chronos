import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Import chuẩn package
import 'package:chronos/core/constants/app_colors.dart';
import 'package:chronos/core/components/chronos_header.dart';
import 'package:chronos/presentation/features/calendar/view_models/calendar_view_model.dart';
import 'package:chronos/presentation/features/calendar/widgets/calendar_time_grid.dart';
import 'package:chronos/presentation/features/calendar/widgets/calendar_month_grid.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Timer _timer;
  double _currentTimePos = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _updateTime();
    // Cập nhật vị trí thanh đỏ mỗi phút
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _updateTime());

    // Tự động cuộn đến giờ hiện tại sau khi render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    if (mounted) {
      setState(() {
        _currentTimePos = (now.hour * 60 + now.minute).toDouble();
      });
    }
  }

  void _scrollToCurrentTime() {
    if (_scrollController.hasClients) {
      final now = DateTime.now();
      double target = (now.hour * 60.0) - 150;
      _scrollController.animateTo(
          target.clamp(0, 1440),
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CalendarViewModel>();

    return Scaffold(
      // BỎ floatingActionButton TẠI ĐÂY
      body: SafeArea(
        child: Column(
          children: [
            // 1. PHẦN ĐIỀU KHIỂN (Header + Switcher + Navigator)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  const ChronosHeader(
                      title: "Lịch biểu",
                      subtitle: "Sắp xếp thời gian của bạn"
                  ),
                  const SizedBox(height: 8),
                  _buildViewSwitcher(vm),
                  const SizedBox(height: 20),
                  _buildDateNavigator(vm),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 2. NỘI DUNG CHÍNH (Lưới Tháng hoặc Lưới Giờ)
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: vm.viewMode == CalendarViewMode.month
                    ? CalendarMonthGrid(vm: vm)
                    : CalendarTimeGrid(
                    vm: vm,
                    currentTimePos: _currentTimePos,
                    scrollController: _scrollController
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS CHI TIẾT ---

  Widget _buildViewSwitcher(CalendarViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: CalendarViewMode.values.map((mode) {
          bool isSelected = vm.viewMode == mode;
          String label = "";
          switch(mode) {
            case CalendarViewMode.day: label = "1 NGÀY"; break;
            case CalendarViewMode.threeDays: label = "3 NGÀY"; break;
            case CalendarViewMode.week: label = "TUẦN"; break;
            case CalendarViewMode.month: label = "THÁNG"; break;
          }
          return Expanded(
            child: GestureDetector(
              onTap: () {
                vm.setViewMode(mode);
                if (mode != CalendarViewMode.month) {
                  Future.delayed(const Duration(milliseconds: 100), _scrollToCurrentTime);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: isSelected ? AppColors.neonShadow : null,
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? AppColors.backgroundDark : Colors.grey,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateNavigator(CalendarViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                DateFormat('yyyy').format(vm.selectedDate),
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2
                )
            ),
            Text(
                DateFormat('MMMM', 'vi_VN').format(vm.selectedDate).toUpperCase(),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)
            ),
          ],
        ),
        Row(
          children: [
            _navButton(Icons.chevron_left, () => vm.navigate(-1)),
            const SizedBox(width: 12),
            _navButton(Icons.chevron_right, () => vm.navigate(1)),
          ],
        )
      ],
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}