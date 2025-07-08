import 'dart:convert' show jsonDecode, jsonEncode;
import 'package:aman_artify/secret.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final List<Map<String, String>> messages = [];

  /// Main method: handles prompt, decides between image/text, returns result
  Future<Map<String, String>> handlePrompt(String prompt) async {
    try {
      final isArt = await _isArtPrompt(prompt);

      if (isArt) {
        final image = await _dalleAPI(prompt);
        
        return {'type': 'image', 'content': image};
      } else {
        final reply = await _chatGPTAPI(prompt);
        
        return {'type': 'text', 'content': reply};
      }
    } catch (e) {
      return {'type': 'error', 'content': '❗ Exception: $e'};
    }
  }


  /// Classifies if input is image/art-related using GPT
  Future<bool> _isArtPrompt(String prompt) async {
    final res = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAIAPIKEY',
      },
      body: jsonEncode({
        "model": "gpt-4.1-mini",
        "messages": [
          {
            "role": "system",
            "content": "You are a helpful assistant."
          },
          {
            "role": "user",
            "content":
            "Does the user want to generate an AI image, picture, art, or anything similar with this message: '$prompt'? Just answer with yes or no."
          }
        ],
      }),
    );

    print("🟢 GPT Classifier Response: ${res.body}");

    if (res.statusCode == 200) {
      final answer = jsonDecode(res.body)['choices'][0]['message']['content']
          .trim()
          .toLowerCase();
      return answer.contains("yes");
    } else {
      throw Exception("Failed to classify prompt: ${res.statusCode}");
    }
  }

  /// Handles ChatGPT conversation
  Future<String> _chatGPTAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
      'type': 'text',
    });

    final openAIMessages = messages
        .map((msg) => {
      'role': msg['role'] ?? 'user', // fallback to avoid null
      'content': msg['content'] ?? '',
    })
        .toList();

    final res = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAIAPIKEY',
      },
      body: jsonEncode({
        "model": "gpt-4.1-mini",
        "messages": openAIMessages,
      }),
    );

    print("💬 ChatGPT Response: ${res.body}");

    if (res.statusCode == 200) {
      return jsonDecode(res.body)['choices'][0]['message']['content'].trim();
    } else {
      throw Exception("ChatGPT Error: ${res.body}");
    }
  }

  /// Handles image generation via DALL·E
  Future<String> _dalleAPI(String prompt) async {
    final res = await http.post(
      Uri.parse('https://api.openai.com/v1/images/generations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAIAPIKEY',
      },
      body: jsonEncode({
        "model": "dall-e-3",
        "prompt": prompt,
        "n": 1,
        "size": "1024x1024",
        "response_format": "b64_json",
      }),
    );

    print("🖼️ DALL·E Response: ${res.body}");

    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'][0]['b64_json'].trim();
    } else {
      throw Exception("DALL·E Error: ${res.statusCode}");
    }
  }
}
