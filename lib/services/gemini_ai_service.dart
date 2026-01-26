// import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/constants/app_keys.dart';

class GeminiAiService {
  late final GenerativeModel _model;

  GeminiAiService() {
    // Khởi tạo model - Nên dùng gemini-1.5-flash để ổn định nhất
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: AppKeys.geminiApiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  // 1. Chia nhỏ Task (HỖ TRỢ ĐA TẦNG - NESTED)
  Future<String?> decomposeTask(String taskDescription) async {
    // Thay đổi Prompt để yêu cầu cấu trúc đệ quy (subtasks chứa subtasks)
    final prompt = '''
Hãy phân tích và chia nhỏ mục tiêu sau đây thành một cấu trúc cây công việc (Work Breakdown Structure) chuyên sâu và đa tầng: "$taskDescription".

Yêu cầu:
1. Chia nhỏ mục tiêu thành ít nhất 2-3 tầng cấp độ (Nhiệm vụ chính -> Nhiệm vụ con -> Các bước thực hiện nhỏ hơn).
2. Mỗi đối tượng phải có cấu trúc đệ quy: { "title": string, "subtasks": [ đối tượng tương tự ] }.
3. Nếu một bước đã đủ nhỏ, trường "subtasks" sẽ là một mảng rỗng [].
4. Trả về kết quả CHỈ là một mảng JSON các đối tượng ở tầng cao nhất.

Định dạng mẫu:
[
  {
    "title": "Nhiệm vụ cấp 1",
    "subtasks": [
      {
        "title": "Nhiệm vụ cấp 2",
        "subtasks": [
          { "title": "Bước thực hiện cấp 3", "subtasks": [] }
        ]
      }
    ]
  }
]
''';

    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text;
  }

  // --- GIỮ NGUYÊN CÁC LOGIC ĐÃ ĐÚNG BÊN DƯỚI ---

  // 2. Tư vấn tài chính
  Future<String?> getFinancialAdvice(String transactionsJson, double budget) async {
    final prompt = 'Dựa trên dữ liệu chi tiêu sau: $transactionsJson và ngân sách $budget, hãy đưa ra 3 lời khuyên ngắn gọn để tiết kiệm tiền.';
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text;
  }

  // 3. Phân tích tâm trạng
  Future<String?> analyzeMood(String journalEntriesJson) async {
    final prompt = 'Phân tích xu hướng tâm trạng từ các nhật ký sau: $journalEntriesJson. Cho biết tâm trạng chủ đạo và một lời khuyên sức khỏe tâm thần.';
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text;
  }

  // 4. Tư vấn phát triển cá nhân
  Future<String?> getPersonalGrowthAdvice(String dataSummaryJson) async {
    final prompt = 'Đây là tóm tắt hoạt động của tôi: $dataSummaryJson. Hãy đóng vai một huấn luyện viên phát triển cá nhân, phân tích hiệu suất của tôi và đưa ra 2 chiến lược cụ thể để tôi cải thiện bản thân trong tuần tới. Phản hồi ngắn gọn, truyền cảm hứng.';
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text;
  }
}