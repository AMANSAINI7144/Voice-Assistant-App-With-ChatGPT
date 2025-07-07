import 'package:aman_artify/feature_box.dart';
import 'package:aman_artify/openAI_service.dart';
import 'package:aman_artify/pallete.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:convert'; // for base64Decode

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final speechToText = SpeechToText();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();

  @override
  void initState() {
    super.initState();
    initSpeechToText();
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {

    });
  }

  // Future<void> startListening() async {
  //   await speechToText.listen(onResult: onSpeechResult);
  //   setState(() {});
  // }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    print("🎧 Started Listening");
    setState(() {});
  }


  // Future<void> stopListening() async {
  //   await speechToText.stop();
  //   setState(() {});
  // }

  Future<void> stopListening() async {
    await speechToText.stop();
    print("🛑 Stopped Listening");
    setState(() {});
  }


  // void onSpeechResult(SpeechRecognitionResult result) {
  //   setState(() {
  //     lastWords = result.recognizedWords;
  //     print(lastWords);
  //   });
  // }

  void onSpeechResult(SpeechRecognitionResult result) async {
    setState(() {
      lastWords = result.recognizedWords;
      print("📝 Recognized: $lastWords");
    });

    if (result.finalResult) {
      print("✅ Final Result Reached. Sending to OpenAI...");
      final output = await openAIService.isArtPromptAPI(lastWords);
      print("🤖 OpenAI Response: $output");

      await stopListening(); // Automatically stop after getting final speech
    }
  }



  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EnriqueAman'),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Virtual Assistant Picture
            Stack(
              children: [
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: Pallete.assistantCircleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  height: 125,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/virtual_Assistant.jpg'),
                    ),
                  ),
                ),
              ],
            ),
            // Chat Bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(top: 30),
              decoration: BoxDecoration(
                border: Border.all(color: Pallete.borderColor),
                borderRadius: BorderRadius.circular(20).copyWith(topLeft: Radius.zero),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "Good Morning, What Task Can I Do For You?",
                  style: TextStyle(
                    fontFamily: 'Cera Pro',
                    color: Pallete.mainFontColor,
                    fontSize: 25,
                  ),
                ),
              ),
            ),

            // Display recognized speech
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🗣️ Show recognized last words (what user said)
                if (lastWords.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Heard: $lastWords',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),

                const SizedBox(height: 10),

                // 🧠 Show AI responses (text or image)
                ...openAIService.messages.map((msg) {
                  if (msg['type'] == 'image') {
                    // Decode base64 and show image
                    final decodedBytes = base64Decode(msg['content']!);
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          decodedBytes,
                          width: 300,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  } else {
                    // Show text message
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg['content'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  }
                }).toList(),
              ],
            ),



            // Section Title
            Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(top: 10, left: 22),
              child: const Text(
                "Here Are Some Features",
                style: TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Features List
            const FeatureBox(
              color: Pallete.firstSuggestionBoxColor,
              headerText: "ChatGPT",
              descriptionText: "A Smarter Way To Stay Organised And Informed With ChatGPT!",
            ),
            const FeatureBox(
              color: Pallete.secondSuggestionBoxColor,
              headerText: "Dall-E",
              descriptionText: "Get Inspired And Stay Creative With Your Personal Assistant Powered By Dall - E!",
            ),
            const FeatureBox(
              color: Pallete.thirdSuggestionBoxColor,
              headerText: "Smart Voice Assistant",
              descriptionText: "Get The Best Worlds With A Voice Assistant Powered By Dall-E and ChatGPT!",
            ),
            const SizedBox(height: 80), // add some bottom space so floating button doesn't overlap
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Pallete.firstSuggestionBoxColor,
        onPressed: () async {
          if (await speechToText.hasPermission && !speechToText.isListening) {
            await startListening();
          } else if (speechToText.isListening) {
            await stopListening();
          } else {
            await initSpeechToText(); // Optional: run this once in initState() ideally
          }
        },
        child: const Icon(Icons.mic),
      ),
    );
  }
}
