import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:chronos/services/gemini_ai_service.dart';
import 'package:chronos/data/models/task_model.dart';

class AiRepositoryImpl {
  final GeminiAiService _aiService = GeminiAiService();

  // ============================================================
  // 1. CHIẾN THUẬT: STEP-BY-STEP (REALTIME STREAMING) - CẢI TIẾN
  // ============================================================

  /// BƯỚC 1: Lấy các giai đoạn chính (High-level Phases) - Level 0
  /// Cải thiện: Yêu cầu tính logic và trình tự thời gian
  Future<List<SubTaskModel>> getMainPhases(String goal) async {
    try {
      String prompt = """
      Bạn là một Chiến lược gia lão luyện (Expert Strategist).
      Nhiệm vụ: Phân rã mục tiêu "$goal" thành 5-7 GIAI ĐOẠN CHÍNH (Milestones) theo trình tự thời gian logic.
      
      Yêu cầu chất lượng:
      1. Các giai đoạn phải bao phủ từ lúc bắt đầu đến khi hoàn thành.
      2. Ngôn ngữ ngắn gọn, súc tích, đi thẳng vào vấn đề.
      3. KHÔNG được phân rã chi tiết con ở bước này.
      4. KHÔNG dùng các từ sáo rỗng như "Bước 1", "Giai đoạn đầu". Hãy đặt tên thực tế.
      
      Định dạng JSON bắt buộc:
      [{"title": "Tên giai đoạn 1"}, {"title": "Tên giai đoạn 2"}, ...]
      """;

      final responseText = await _aiService.decomposeTask(prompt);
      return _parseResponseToList(responseText, defaultLevel: 0);
    } catch (e) {
      debugPrint('AI_MAIN_PHASE_ERROR: $e');
      return [];
    }
  }

  /// BƯỚC 2: Lấy chi tiết cho một giai đoạn (Actionable Steps) - Level 1
  /// Cải thiện: Prompt cực gắt để tránh lặp lại và chung chung
  Future<List<SubTaskModel>> getSubStepsFor(String parentStep, String contextGoal) async {
    try {
      String prompt = """
      Vai trò: Bạn là một Quản lý dự án thực thi (Execution Manager) cực kỳ khắt khe.
      
      Bối cảnh: 
      - Mục tiêu lớn: "$contextGoal"
      - Giai đoạn hiện tại cần làm chi tiết: "$parentStep"
      
      Nhiệm vụ: Liệt kê 3-5 HÀNH ĐỘNG CỤ THỂ (Actionable Tasks) để hoàn thành Giai đoạn "$parentStep".
      
      LUẬT CẤM (TUYỆT ĐỐI KHÔNG VI PHẠM):
      1. KHÔNG được lặp lại tên của giai đoạn (Ví dụ: Giai đoạn là 'Lập kế hoạch' thì không được sinh task con là 'Lập kế hoạch chi tiết').
      2. KHÔNG sinh ra các bước chung chung vô nghĩa như: "Thực hiện kế hoạch", "Cố gắng hết sức", "Làm chăm chỉ".
      3. KHÔNG sinh ra các bước thuộc về giai đoạn khác.
      
      Yêu cầu nội dung:
      - Bắt đầu bằng Động từ hành động (Ví dụ: "Đọc...", "Viết...", "Mua...", "Liên hệ...", "Hoàn thành bài test...").
      - Phải cụ thể, đo lường được càng tốt.
      
      Định dạng JSON bắt buộc:
      [{"title": "Hành động 1"}, {"title": "Hành động 2"}, ...]
      """;

      final responseText = await _aiService.decomposeTask(prompt);
      // Mặc định trả về level 1, UI sẽ tự cộng thêm level của cha vào sau
      return _parseResponseToList(responseText, defaultLevel: 1);
    } catch (e) {
      debugPrint('AI_SUB_STEP_ERROR: $e');
      return [];
    }
  }

  // ============================================================
  // 2. CÁC HÀM CŨ (ONE-SHOT & HYBRID LOGIC) - GIỮ LẠI ĐỂ TƯƠNG THÍCH
  // ============================================================

  /// Hàm xử lý chính cho logic cũ (dùng cho nút Bolt hoặc các tính năng cũ)
  Future<List<SubTaskModel>> getDecomposedSubTasks(String input) async {
    try {
      final responseText = await _aiService.decomposeTask(input);
      if (responseText == null || responseText.isEmpty) return [];

      final cleanJson = _cleanJsonResponse(responseText);
      final dynamic decodedData = jsonDecode(cleanJson);
      List<SubTaskModel> result = [];

      if (decodedData is List) {
        _processOneShotList(decodedData, result);
      } else if (decodedData is Map) {
        final listData = decodedData['tasks'] ?? decodedData['steps'] ?? decodedData['subtasks'];
        if (listData is List) {
          _processOneShotList(listData, result);
        }
      }

      return result;
    } catch (e) {
      debugPrint('AI_DECOMPOSE_ERROR: $e');
      return [];
    }
  }

  /// Hàm điều phối logic One-shot: Quyết định dùng Đệ quy hay Phân tích số
  void _processOneShotList(List<dynamic> jsonList, List<SubTaskModel> result) {
    if (jsonList.isEmpty) return;

    // Kiểm tra xem AI có trả về cấu trúc lồng nhau không
    bool hasNestedStructure = jsonList.any((item) =>
    item is Map && (item.containsKey('subtasks') || item.containsKey('steps') || item.containsKey('children'))
    );

    if (hasNestedStructure) {
      // Logic Đệ quy (Recursive) - Cho JSON lồng nhau
      _flattenNestedJson(jsonList, result, 0);
    } else {
      // Logic Phân tích số (Numbering Parsing) - Cho JSON phẳng có đánh số 1.1, 1.1.1
      _parseFlatJsonWithNumbering(jsonList, result);
    }
  }

  void _flattenNestedJson(List<dynamic> jsonList, List<SubTaskModel> result, int currentLevel) {
    for (var item in jsonList) {
      if (item is! Map) continue;
      final title = item['title'] ?? item['name'] ?? 'Bước thực hiện';

      result.add(SubTaskModel()
        ..id = "${DateTime.now().microsecondsSinceEpoch}_${title.hashCode}"
        ..title = title.toString()
        ..completed = false
        ..level = currentLevel
      );

      final children = item['subtasks'] ?? item['steps'] ?? item['children'];
      if (children != null && children is List && children.isNotEmpty) {
        _flattenNestedJson(children, result, currentLevel + 1);
      }
    }
  }

  void _parseFlatJsonWithNumbering(List<dynamic> jsonList, List<SubTaskModel> result) {
    for (var item in jsonList) {
      if (item is! Map) continue;
      String title = (item['title'] ?? item['name'] ?? '').toString();

      // Tự động tính level dựa trên số lượng dấu chấm (1.1. -> Level 1)
      int level = _calculateLevelFromTitle(title);

      result.add(SubTaskModel()
        ..id = "${DateTime.now().microsecondsSinceEpoch}_${title.hashCode}"
        ..title = title
        ..completed = false
        ..level = level
      );
    }
  }

  int _calculateLevelFromTitle(String title) {
    if (title.trim().isEmpty) return 0;
    // Regex bắt chuỗi số ở đầu (VD: "2.1.3.1 " hoặc "2.1.3.1.")
    final RegExp regex = RegExp(r'^([\d\.]+)\s');
    final match = regex.firstMatch(title.trim());

    if (match != null) {
      String numbering = match.group(1)!;
      // Xóa dấu chấm cuối cùng nếu có
      if (numbering.endsWith('.')) {
        numbering = numbering.substring(0, numbering.length - 1);
      }
      // Đếm số phần tử
      return (numbering.split('.').length - 1).clamp(0, 5);
    }
    return 0;
  }

  // ============================================================
  // 3. CÁC HÀM TƯ VẤN (REFACTORED GỌN GÀNG)
  // ============================================================

  Future<String> fetchGrowthAdvice(String dataSummary) async {
    return _fetchAndFormatAdvice(
      apiCall: () => _aiService.getPersonalGrowthAdvice(dataSummary),
      fallback: "Dữ liệu cho thấy bạn đang đi đúng hướng. Hãy tập trung vào mục tiêu quan trọng nhất!",
    );
  }

  Future<String> fetchFinancialAdvice(List<dynamic> transactions, double budget) async {
    return _fetchAndFormatAdvice(
      apiCall: () => _aiService.getFinancialAdvice(jsonEncode(transactions), budget),
      fallback: "Hãy theo dõi sát sao các khoản chi tiêu và tuân thủ ngân sách tuần này.",
    );
  }

  Future<String> analyzeMoodTrend(List<dynamic> journalEntries) async {
    return _fetchAndFormatAdvice(
      apiCall: () => _aiService.analyzeMood(jsonEncode(journalEntries)),
      fallback: "Hãy dành thời gian ghi nhật ký và lắng nghe cảm xúc bản thân nhiều hơn.",
    );
  }

  // ============================================================
  // 4. COMMON HELPERS (UTILS)
  // ============================================================

  /// Helper parse JSON đơn giản cho chiến thuật Step-by-Step
  List<SubTaskModel> _parseResponseToList(String? responseText, {required int defaultLevel}) {
    if (responseText == null || responseText.isEmpty) return [];

    final cleanJson = _cleanJsonResponse(responseText);
    List<SubTaskModel> results = [];

    try {
      final dynamic decoded = jsonDecode(cleanJson);
      List listData = [];

      if (decoded is List) listData = decoded;
      else if (decoded is Map) {
        listData = decoded['tasks'] ?? decoded['steps'] ?? decoded['phases'] ?? [];
      }

      for (var item in listData) {
        if (item is Map) {
          final title = item['title'] ?? item['name'] ?? '';
          if (title.toString().isNotEmpty) {
            results.add(SubTaskModel()
              ..id = "${DateTime.now().microsecondsSinceEpoch}_${title.hashCode}"
              ..title = title.toString()
              ..completed = false
              ..level = defaultLevel
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Parse Error: $e");
    }
    return results;
  }

  Future<String> _fetchAndFormatAdvice({
    required Future<String?> Function() apiCall,
    required String fallback
  }) async {
    try {
      final response = await apiCall();
      if (response == null || response.isEmpty) return fallback;

      final cleanJson = _cleanJsonResponse(response);

      try {
        final dynamic decoded = jsonDecode(cleanJson);
        if (decoded is Map<String, dynamic>) {
          return _formatJsonToReadableText(decoded);
        } else if (decoded is List) {
          return decoded.join("\n\n");
        }
        return cleanJson;
      } catch (_) {
        return response;
      }
    } catch (e) {
      return fallback;
    }
  }

  String _formatJsonToReadableText(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    data.forEach((key, value) {
      if (value is String && value.isNotEmpty) {
        buffer.writeln(value);
        buffer.writeln();
      } else if (value is List) {
        for (var item in value) {
          if (item is Map) {
            final title = item['title'] ?? item['name'] ?? '';
            final content = item['description'] ?? item['content'] ?? '';
            if (title.toString().isNotEmpty) buffer.writeln("• ${title.toString().toUpperCase()}");
            if (content.toString().isNotEmpty) buffer.writeln("  ${content.toString()}");
            buffer.writeln();
          } else {
            buffer.writeln("• $item");
          }
        }
      }
    });
    return buffer.toString().trim();
  }

  String _cleanJsonResponse(String raw) {
    String result = raw.trim();
    final codeBlockRegex = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
    final match = codeBlockRegex.firstMatch(result);
    if (match != null) {
      result = match.group(1) ?? result;
    }

    final startBracket = result.indexOf('[');
    final startBrace = result.indexOf('{');
    int startIndex = -1;
    if (startBracket != -1 && (startBrace == -1 || startBracket < startBrace)) {
      startIndex = startBracket;
    } else {
      startIndex = startBrace;
    }

    final endBracket = result.lastIndexOf(']');
    final endBrace = result.lastIndexOf('}');
    final endIndex = (endBracket > endBrace) ? endBracket : endBrace;

    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return result.substring(startIndex, endIndex + 1);
    }
    return result.trim();
  }
}