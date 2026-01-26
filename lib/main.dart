import 'package:chronos/data/repositories/ai_repository_impl.dart';
import 'package:chronos/presentation/features/calendar/view_models/calendar_view_model.dart';
import 'package:chronos/presentation/features/journal/view_models/journal_view_model.dart';
// import 'package:chronos/presentation/features/journal/views/journal_screen.dart';
import 'package:chronos/presentation/features/profile/view_models/profile_view_model.dart';
// import 'package:chronos/presentation/features/tasks/view_models/ai_plan_view_model.dart';
// import 'package:chronos/presentation/features/tasks/view_models/tasks_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chronos/core/theme/app_theme.dart';
import 'package:chronos/core/database/isar_service.dart';
import 'package:chronos/presentation/layout/main_layout.dart';
import 'presentation/features/tasks/view_models/tasks_view_model.dart';
import 'presentation/features/finance/view_models/finance_view_model.dart';
import 'presentation/features/habits/view_models/habits_view_model.dart';
import 'package:intl/date_symbol_data_local.dart';


// Import các ViewModels (Sẽ tạo ở các giai đoạn sau)
// Hiện tại chúng ta comment lại hoặc tạo sẵn khung để không bị lỗi code
// import 'presentation/features/tasks/view_models/tasks_view_model.dart';

void main() async {
  // 1. Đảm bảo các dịch vụ của Flutter đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);
  // 2. Khởi tạo Isar Database (Giai đoạn 2)
  final isarService = IsarService();
  await isarService.init();

  runApp(
    // 3. Sử dụng MultiProvider để quản lý trạng thái toàn ứng dụng
    // Tương tự như cách React Context bao bọc App
    MultiProvider(
      providers: [
        // Cung cấp IsarService cho toàn bộ app
        Provider<IsarService>.value(value: isarService),
        Provider<AiRepositoryImpl>(create: (_) => AiRepositoryImpl()),
        // Trong file main.dart, tìm MultiProvider và thêm dòng này:
        ChangeNotifierProvider(create: (_) => CalendarViewModel(isarService)),

        ChangeNotifierProvider(create: (_) => TasksViewModel(isarService)),
        ChangeNotifierProvider(create: (_) => FinanceViewModel(isarService)),
        ChangeNotifierProvider(create: (_) => HabitsViewModel(isarService)),

        ChangeNotifierProvider(create: (_) => JournalViewModel(isarService)),
        ChangeNotifierProvider(create: (_) => ProfileViewModel(isarService)),
        // ChangeNotifierProvider(create: (_) => AiPlanViewModel(isarService)),
        /*
        Sau này khi làm đến phần logic, bạn sẽ thêm các ViewModel vào đây:
        ChangeNotifierProvider(create: (_) => TasksViewModel(isarService)),
        ChangeNotifierProvider(create: (_) => FinanceViewModel(isarService)),
        */
      ],
      child: const ChronosApp(),
    ),
  );
}

class ChronosApp extends StatelessWidget {
  const ChronosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chronos - Smart Student Hub',

      // Tắt biểu tượng Debug ở góc màn hình
      debugShowCheckedModeBanner: false,

      // 4. Áp dụng Theme Neon Dark (Giai đoạn 1)
      theme: AppTheme.darkTheme,

      // 5. Màn hình chính (Tương đương Layout.tsx trong React)
      // Chúng ta sẽ tạo file này ở bước tiếp theo
      home: const MainLayout(),
    );
  }
}