import 'package:chronos/presentation/features/calendar/views/calendar_screen.dart';
import 'package:chronos/presentation/features/journal/views/journal_screen.dart';
// import 'package:chronos/presentation/features/tasks/views/ai_plan_screen.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../features/tasks/views/tasks_screen.dart';
import '../features/finance/views/finance_screen.dart';
import '../features/habits/views/habits_screen.dart';
import '../features/profile/views/profile_screen.dart';
// Import các màn hình khác...

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // Danh sách các màn hình tương ứng với các Tab
  final List<Widget> _screens = [
    const TasksScreen(),
    const CalendarScreen(), // Sẽ thay bằng CalendarScreen
    const FinanceScreen(),
    const HabitsScreen(),
    const JournalScreen(),
    const ProfileScreen(),
    // const AiPlanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),

      // Nút AI Plan lơ lửng (Nút Bolt trong React)
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => setState(() => _selectedIndex = 6), // Ví dụ mở AI Plan
      //   backgroundColor: AppColors.primary,
      //   elevation: 10,
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      //   child: const Icon(Icons.bolt, color: AppColors.backgroundDark, size: 30),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // Thanh điều hướng dưới cùng (Bottom Navigation)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surfaceDark.withOpacity(0.95),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'VIỆC LÀM'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'LỊCH BIỂU'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'TÀI CHÍNH'),
            BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'THÓI QUEN'),
            BottomNavigationBarItem(icon: Icon(Icons.history_edu), label: 'NHẬT KÝ'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'CÁ NHÂN'),
          ],
        ),
      ),
    );
  }
}