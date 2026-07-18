import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../services/gemini_service.dart';

class ChatProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _lastError;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  bool get hasApiKey => _geminiService.hasApiKey;

  static const String _systemPrompt =
      'أنت مساعد ذكي ومفيد. أجب باللغة التي يستخدمها المستخدم.';

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // إضافة رسالة المستخدم فوراً
    final userMessage = ChatMessage(content: text.trim(), role: MessageRole.user);
    _messages.add(userMessage);
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final reply = await _geminiService.sendMessage(
        conversationHistory: _messages,
        systemPrompt: _systemPrompt,
      );

      _messages.add(ChatMessage(content: reply, role: MessageRole.assistant));
    } on GeminiApiException catch (e) {
      _lastError = e.message;
      _messages.add(ChatMessage(
        content: e.message,
        role: MessageRole.assistant,
        isError: true,
      ));
    } catch (e) {
      _lastError = 'حدث خطأ غير متوقع: $e';
      _messages.add(ChatMessage(
        content: _lastError!,
        role: MessageRole.assistant,
        isError: true,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _lastError = null;
    notifyListeners();
  }
}
