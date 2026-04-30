
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_localizations.dart';
import 'screens/auth/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('ar', '');
  // لم نعد بحاجة لهذه المتغيرات هنا
  // final AuthService _authService = AuthService();
  // late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    // تم حذف السطر الذي يجلب المستخدم المسجل
    // _userFuture = _authService.getLoggedInUser();
  }

  void changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SCAI Sales',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [
        Locale('en', ''),
        Locale('ar', ''),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      // --- ✅ التعديل الرئيسي هنا ---
      // تم حذف الـ FutureBuilder وتعيين LoginScreen كشاشة رئيسية دائمة
      home: LoginScreen(onLanguageChanged: changeLanguage),
    );
  }
}


/*
// main.dart
// Enhanced Flutter chatbot with improved design and AI-like conversational style using DuckDuckGo + Wikipedia API.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Wiki Chatbot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
      ),
      home: const ChatPage(),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _ctrl = TextEditingController();
  bool _isLoading = false;

  Future<String> _searchKnowledge(String q) async {
    final duckResult = await _searchDuckDuckGo(q);
    if (duckResult.isNotEmpty && !duckResult.contains('لم أجد')) {
      return duckResult;
    }
    return await _searchWikipedia(q);
  }

  Future<String> _searchDuckDuckGo(String q) async {
    final encoded = Uri.encodeQueryComponent(q);
    final url = Uri.parse('https://api.duckduckgo.com/?q=$encoded&format=json&no_html=1&skip_disambig=1');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final abstractText = (data['AbstractText'] as String?)?.trim();
        if (abstractText != null && abstractText.isNotEmpty) {
          return abstractText;
        }
        return '';
      }
    } catch (_) {}
    return '';
  }

  Future<String> _searchWikipedia(String q) async {
    final encoded = Uri.encodeComponent(q);
    final url = Uri.parse('https://en.wikipedia.org/api/rest_v1/page/summary/$encoded');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['extract'] != null && data['extract'].toString().isNotEmpty) {
          return data['extract'];
        }
      }
    } catch (_) {}
    return 'لم أتمكن من العثور على إجابة دقيقة، حاول صياغة السؤال بشكل أوضح.';
  }

  void _sendMessage() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.insert(0, ChatMessage(text: text, isUser: true));
      _isLoading = true;
      _ctrl.clear();
    });

    final reply = await _searchKnowledge(text);
    final aiReply = _generateAIStyleReply(reply);

    setState(() {
      _messages.insert(0, ChatMessage(text: aiReply, isUser: false));
      _isLoading = false;
    });
  }

  String _generateAIStyleReply(String content) {
    if (content.startsWith('لم أتمكن')) {
      return '🤖 آسف، لم أجد إجابة دقيقة لذلك السؤال. جرب إعادة صياغته أو طلب شرح لمفهوم محدد.';
    }
    return '🤖 بالتأكيد! إليك ما وجدته:\n\n$content';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('🤖 AI Wiki Chatbot'),
        centerTitle: true,
        elevation: 4,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? const Center(
                child: Text('ابدأ بكتابة سؤال عن أي موضوع عام.',
                    style: TextStyle(fontSize: 16)),
              )
                  : ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final m = _messages[index];
                  return Align(
                    alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: const BoxConstraints(maxWidth: 320),
                      decoration: BoxDecoration(
                        color: m.isUser ? Colors.deepPurple : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          )
                        ],
                      ),
                      child: Text(
                        m.text,
                        style: TextStyle(
                          color: m.isUser ? Colors.white : Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              ),
            const Divider(height: 1),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'اكتب سؤالك هنا...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _sendMessage,
                    child: const Icon(Icons.send),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
*/