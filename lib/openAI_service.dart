import 'dart:convert' show jsonDecode, jsonEncode;
import 'package:aman_artify/secret.dart';
import 'package:http/http.dart' as http;

class OpenAIService{

  final List<Map<String, String>> messages = [];

  // Future<String> isArtPromptAPI(String prompt) async {
  //   try {
  //     final res = await http.post(
  //       Uri.parse('https://api.openai.com/v1/chat/completions'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $openAIAPIKEY',
  //       },
  //       body: jsonEncode({
  //         "model": "gpt-4.1-mini",
  //         "messages": [
  //           {
  //             "role": "system",
  //             "content": "You are a helpful assistant."
  //           },
  //           {
  //             "role": "user",
  //             "content":
  //             "Does the user want to generate an AI image, picture, art, or anything similar with this message: '$prompt'? Just answer with yes or no."
  //           }
  //         ],
  //       }),
  //     );
  //
  //     print("🔵 OpenAI response: ${res.body}");
  //
  //     if (res.statusCode == 200) {
  //       String content =
  //       jsonDecode(res.body)['choices'][0]['message']['content'].trim();
  //
  //       if (content.toLowerCase().contains("yes")) {
  //         return await dalleAPI(prompt);
  //       } else {
  //         return await chatGPTAPI(prompt);
  //       }
  //     }
  //
  //     return "❌ Error: ${res.statusCode} - ${res.body}";
  //   }
  //   catch (e) {
  //     return "❗ Exception: $e";
  //   }
  // }

// // way 2 for isArtPromptAPI.
//   Future<String> isArtPromptAPI(String prompt) async {
//     try {
//       final res = await http.post(
//         Uri.parse('https://api.openai.com/v1/chat/completions'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $openAIAPIKEY',
//         },
//         body: jsonEncode({
//           "model": "gpt-4.1-mini",
//           "messages": [
//             {
//               "role": "system",
//               "content": "You are a helpful assistant."
//             },
//             {
//               "role": "user",
//               "content":
//               "Does the user want to generate an AI image, picture, art, or anything similar with this message: '$prompt'? Just answer with yes or no."
//             }
//           ],
//         }),
//       );
//
//       print("🔵 OpenAI response: ${res.body}");
//
//       if (res.statusCode == 200) {
//         String content = jsonDecode(res.body)['choices'][0]['message']['content']
//             .trim()
//             .toLowerCase();
//
//         if (content.contains("yes")) {
//           String base64Image = await dalleAPI(prompt);
//           messages.add({
//             'role': 'assistant',
//             'content': base64Image,
//             'type': 'image', // 👈 for UI detection
//           });
//           return "🖼️ Image generated.";
//         } else {
//           String response = await chatGPTAPI(prompt);
//           messages.add({
//             'role': 'assistant',
//             'content': response,
//             'type': 'text',
//           });
//           return response;
//         }
//       }
//
//       return "❌ Error: ${res.statusCode} - ${res.body}";
//     } catch (e) {
//       return "❗ Exception: $e";
//     }
//   }

// // WAY 3
  Future<String> isArtPromptAPI(String prompt) async {
    try {
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
              "content": "Does the user want to generate an AI image, picture, art, or anything similar with this message: '$prompt'? Just answer with yes or no."
            }
          ],
        }),
      );

      print("🔵 GPT Response for detection: ${res.body}");

      if (res.statusCode == 200) {
        String answer = jsonDecode(res.body)['choices'][0]['message']['content']
            .trim()
            .toLowerCase();

        if (answer.contains("yes")) {
          String base64Image = await dalleAPI(prompt);
          messages.add({
            'role': 'assistant',
            'content': base64Image,
            'type': 'image', // 👈 for UI display
          });
          return base64Image; // This is the image, not text
        } else {
          String chat = await chatGPTAPI(prompt);
          messages.add({
            'role': 'assistant',
            'content': chat,
            'type': 'text',
          });
          return chat;
        }
      }

      return "❌ Error: ${res.statusCode} - ${res.body}";
    } catch (e) {
      return "❗ Exception: $e";
    }
  }


  Future<String> chatGPTAPI(String prompt) async {

    messages.add({
      'role': 'user',
      'content': prompt,
      'type': 'text',
    });

    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKEY',
        },
        body: jsonEncode({
          "model": "gpt-4.1-mini",
          "messages": messages,
        }),
      );

      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'].trim();

        messages.add({
          'role': 'assistant',
          'content': content,
          'type': 'text',
        });

        return content;
      }

      return "❌ Error: ${res.statusCode} - ${res.body}";
    }
    catch (e) {
      return "❗ Exception: $e";
    }
  }

  // Future<String> dalleAPI(String prompt) async {
  //   try {
  //     final res = await http.post(
  //       Uri.parse('https://api.openai.com/v1/images/generations'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $openAIAPIKEY',
  //       },
  //       body: jsonEncode({
  //         "model": "gpt-image-1",  // or "dall-e-3"
  //         "prompt": prompt,
  //         "n": 1,
  //         "size": "1024x1024",
  //         "response_format": "b64_json"
  //       }),
  //     );
  //
  //     print("🔵 OpenAI response: ${res.body}");
  //
  //     if (res.statusCode == 200) {
  //
  //       String base64Image = jsonDecode(res.body)['data'][0]['b64_json'].trim();
  //
  //       return base64Image;
  //     }
  //
  //     return "❌ Error: ${res.statusCode} - ${res.body}";
  //   } catch (e) {
  //     return "❗ Exception: $e";
  //   }
  // }

  Future<String> dalleAPI(String prompt) async {
    try {
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
          "response_format": "b64_json", // 👈 REQUIRED!
        }),
      );

      print("🔵 DALL·E response: ${res.body}");

      if (res.statusCode == 200) {
        // Make sure to extract and return base64 string
        String base64Image = jsonDecode(res.body)['data'][0]['b64_json'].trim();
        return base64Image;
      }

      return "❌ Error: ${res.statusCode} - ${res.body}";
    } catch (e) {
      return "❗ Exception: $e";
    }
  }


}