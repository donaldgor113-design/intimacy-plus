import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class AiService {
  static const _url = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';
  static const _system = 'Доброзичливий AI помічник для Intimacy+ (здорові стосунки, комунікація). Українською, емпатично, без медичних порад.';

  /// TODO: Вставте свій Groq API ключ нижче (замініть ПУСТО на ключ):
  /// Отримати: https://console.groq.com/keys
  static const String _apiKey = 'ПУСТО';

  static Future<String> send(List<ChatMessage> history) async {
    if (_apiKey == 'ПУСТО') throw Exception('API ключ не встановлено! Відкрийте ai_service.dart і вставте ключ.');
    final resp = await http.post(Uri.parse(_url), headers: {'Content-Type':'application/json','Authorization':'Bearer $_apiKey'}, body: jsonEncode({
      'model': _model,
      'messages': [{'role':'system','content':_system}, ...history.map((m)=>m.toApiMap())],
      'max_tokens': 1024, 'temperature': 0.7,
    }));
    if (resp.statusCode == 200) return jsonDecode(resp.body)['choices'][0]['message']['content'];
    throw Exception('Помилка ${resp.statusCode}');
  }
}
