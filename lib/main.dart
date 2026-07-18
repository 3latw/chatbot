import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'screens/chat_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تحميل متغيرات البيئة (بما فيها مفتاح API) من ملف .env
  // إذا لم يكن الملف موجوداً، يستمر التطبيق ويعرض تحذيراً للمستخدم
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // لا شيء - سيتم التعامل مع غياب المفتاح داخل ChatScreen
  }

  runApp(const AiChatbotApp());
}

class AiChatbotApp extends StatelessWidget {
  const AiChatbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: MaterialApp(
        title: 'المساعد الذكي',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFDA7756)),
          fontFamily: 'Cairo',
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFDA7756),
            brightness: Brightness.dark,
          ),
          fontFamily: 'Cairo',
        ),
        themeMode: ThemeMode.system,
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: ChatScreen(),
        ),
      ),
    );
  }
}
