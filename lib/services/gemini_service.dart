import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/message.dart';

/// استثناء مخصص لأخطاء الـ API
class GeminiApiException implements Exception {
  final String message;
  final int? statusCode;
  GeminiApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class GeminiService {
  // gemini-flash-latest هو اسم "متحرك" (alias) يشير دائماً لأحدث موديل Flash مستقر
  // بدل ما نثبّت اسم موديل معيّن (زي gemini-2.5-flash) اللي ممكن يتوقف لاحقاً
  static const String model = 'gemini-flash-latest';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent';

  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  /// يتحقق من وجود مفتاح API
  bool get hasApiKey => _apiKey.isNotEmpty;

  /// إرسال رسالة والحصول على رد كامل (بدون streaming)
  Future<String> sendMessage({
    required List<ChatMessage> conversationHistory,
    String? systemPrompt,
    int maxOutputTokens = 1024,
  }) async {
    if (!hasApiKey) {
      throw GeminiApiException(
        'مفتاح API غير موجود. تأكد من إضافته في ملف .env',
      );
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': _apiKey,
        },
        body: jsonEncode({
          if (systemPrompt != null)
            'system_instruction': {
              'parts': [
                {'text': systemPrompt}
              ]
            },
          'contents': conversationHistory.map(_toGeminiContent).toList(),
          'generationConfig': {
            'maxOutputTokens': maxOutputTokens,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final candidates = data['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) {
          throw GeminiApiException('لم يصل رد من Gemini، حاول مرة أخرى');
        }
        final parts = candidates[0]['content']?['parts'] as List?;
        if (parts == null || parts.isEmpty) {
          throw GeminiApiException('الرد فاضي، حاول تعيد صياغة رسالتك');
        }
        return parts[0]['text'] as String? ?? '';
      } else {
        final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
        final errorMessage = errorBody['error']?['message'] ?? 'خطأ غير معروف';
        throw GeminiApiException(
          _translateError(response.statusCode, errorMessage),
          statusCode: response.statusCode,
        );
      }
    } on GeminiApiException {
      rethrow;
    } catch (e) {
      throw GeminiApiException('فشل الاتصال بالإنترنت أو بالخادم: $e');
    }
  }

  /// تحويل الرسالة لصيغة Gemini (role: user/model بدل user/assistant)
  Map<String, dynamic> _toGeminiContent(ChatMessage m) {
    return {
      'role': m.role == MessageRole.user ? 'user' : 'model',
      'parts': [
        {'text': m.content}
      ],
    };
  }

  String _translateError(int statusCode, String originalMessage) {
    switch (statusCode) {
      case 400:
        return 'طلب غير صحيح، أو مفتاح API غير صالح';
      case 403:
        return 'مفتاح API غير مصرّح له، تحقق منه في Google AI Studio';
      case 429:
        return 'تجاوزت الحد المسموح من الطلبات على النسخة المجانية. حاول بعد دقيقة';
      case 500:
      case 503:
        return 'خادم Gemini غير متاح حالياً. حاول لاحقاً';
      default:
        return 'خطأ ($statusCode): $originalMessage';
    }
  }
}
