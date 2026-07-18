import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/message.dart';

/// استثناء مخصص لأخطاء الـ API
class ClaudeApiException implements Exception {
  final String message;
  final int? statusCode;
  ClaudeApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ClaudeService {
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';
  static const String _apiVersion = '2023-06-01';

  // الموديل المستخدم - يمكن تغييره حسب الحاجة
  static const String model = 'claude-sonnet-4-6';

  String get _apiKey => dotenv.env['CLAUDE_API_KEY'] ?? '';

  /// يتحقق من وجود مفتاح API صالح
  bool get hasApiKey => _apiKey.isNotEmpty;

  /// إرسال رسالة والحصول على رد كامل (بدون streaming)
  Future<String> sendMessage({
    required List<ChatMessage> conversationHistory,
    String? systemPrompt,
    int maxTokens = 1024,
  }) async {
    if (!hasApiKey) {
      throw ClaudeApiException(
        'مفتاح API غير موجود. تأكد من إضافته في ملف .env',
      );
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': _apiVersion,
        },
        body: jsonEncode({
          'model': model,
          'max_tokens': maxTokens,
          if (systemPrompt != null) 'system': systemPrompt,
          'messages': conversationHistory.map((m) => m.toApiJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['content'] as List;
        final textBlock = content.firstWhere(
          (block) => block['type'] == 'text',
          orElse: () => {'text': ''},
        );
        return textBlock['text'] as String;
      } else {
        final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
        final errorMessage =
            errorBody['error']?['message'] ?? 'خطأ غير معروف';
        throw ClaudeApiException(
          _translateError(response.statusCode, errorMessage),
          statusCode: response.statusCode,
        );
      }
    } on ClaudeApiException {
      rethrow;
    } catch (e) {
      throw ClaudeApiException('فشل الاتصال بالإنترنت أو بالخادم: $e');
    }
  }

  /// ترجمة أكواد الأخطاء الشائعة لرسائل مفهومة
  String _translateError(int statusCode, String originalMessage) {
    switch (statusCode) {
      case 401:
        return 'مفتاح API غير صحيح. تحقق منه في ملف .env';
      case 429:
        return 'تجاوزت الحد المسموح من الطلبات. حاول بعد قليل';
      case 500:
      case 529:
        return 'خادم Claude غير متاح حالياً. حاول لاحقاً';
      default:
        return 'خطأ ($statusCode): $originalMessage';
    }
  }
}
