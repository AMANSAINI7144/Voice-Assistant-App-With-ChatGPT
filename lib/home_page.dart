import 'package:aman_artify/feature_box.dart';
import 'package:aman_artify/openAI_service.dart';
import 'package:aman_artify/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:convert'; // for base64Decode
import 'package:animate_do/animate_do.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final fluttertts = FlutterTts();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImage;
  int start = 200;
  int delay = 200;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await fluttertts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
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
    if (!result.finalResult) {
      setState(() {
        lastWords = result.recognizedWords;
        print("📝 Recognized: $lastWords");
      });
      return;
    }

    print("✅ Final Result Reached. Sending to OpenAI...");
    final prompt = result.recognizedWords;

    setState(() {
      lastWords = prompt;
    });

    // ✅ Only add user message ONCE
    openAIService.messages.add({
      'type': 'user',
      'content': prompt,
    });

    final responseMap = await openAIService.handlePrompt(prompt);
    final type = responseMap['type'];
    final content = responseMap['content'];

    if (type == 'image') {
      setState(() {
        generatedImage = content;
        generatedContent = null;

        openAIService.messages.add({
          'role': 'assistant',
          'type': 'image',
          'content': content ?? '',
        });
      });
    } else if (type == 'text') {
      setState(() {
        generatedContent = content;
        generatedImage = null;

        openAIService.messages.add({
          'role': 'assistant',
          'type': 'text',
          'content': content ?? '',
        });
      });

      await systemSpeak(content ?? '');
    } else {
      setState(() {
        generatedContent = "Something went wrong.";
        generatedImage = null;
      });
    }

    await stopListening();
  }

  Future<void> systemSpeak(String content) async {
    await fluttertts.speak(content);
  }

  void _resetApp() {
  setState(() {
    generatedContent = null;
    generatedImage = null;
    lastWords = '';
    openAIService.messages.clear();
  });
  print("🧹 Reset done");
}


  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    fluttertts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(child: const Text('EnriqueAman')),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Virtual Assistant Picture
            ZoomIn(
              child: Stack(
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
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (openAIService.messages.isEmpty)
                  FadeInRight(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(top: 30),
                      decoration: BoxDecoration(
                        border: Border.all(color: Pallete.borderColor),
                        borderRadius: BorderRadius.circular(20).copyWith(topLeft: Radius.zero),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          'Hey Aman, What Can I Do For You???',
                          style: TextStyle(
                            fontFamily: 'Cera Pro',
                            color: Pallete.mainFontColor,
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ),
                  ),

                // 🧠 Show full conversation
                ...openAIService.messages.map((msg) {
                  if (msg['type'] == 'user') {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "🧑‍💬 You: ${msg['content'] ?? ''}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  } else if (msg['type'] == 'text') {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Align(
                        alignment: Alignment.centerRight,
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
                      ),
                    );
                  } else if (msg['type'] == 'image') {
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
                    return const SizedBox.shrink();
                  }
                }).toList(),
              ],
            ),



            // Section Title
            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null && generatedImage == null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 10, left: 22),
                  child: const Text(
                    'Here are a few features',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // Features List
            Visibility(
              visible: generatedContent == null && generatedImage == null,
              child: Column(
                children: [
                   SlideInLeft(
                     delay: Duration(milliseconds: start),
                     child: const FeatureBox(
                      color: Pallete.firstSuggestionBoxColor,
                      headerText: "ChatGPT",
                      descriptionText:
                          "A Smarter Way To Stay Organised And Informed With ChatGPT!",
                                       ),
                   ),
                   SlideInLeft(
                     delay: Duration(milliseconds: start + delay),
                     child: const FeatureBox(
                      color: Pallete.secondSuggestionBoxColor,
                      headerText: "Dall-E",
                      descriptionText:
                          "Get Inspired And Stay Creative With Your Personal Assistant Powered By Dall - E!",
                                       ),
                   ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + 2 * delay),
                    child: const FeatureBox(
                      color: Pallete.thirdSuggestionBoxColor,
                      headerText: "Smart Voice Assistant",
                      descriptionText:
                          "Get The Best Of Both Worlds With A Voice Assistant Powered By Dall-E and ChatGPT!",
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 30), // slight padding from the left edge

          ZoomIn(
            delay: Duration(milliseconds: start + 4 * delay),
            child: FloatingActionButton(
              heroTag: 'reset',
              mini: true,
              backgroundColor: Colors.redAccent,
              onPressed: _resetApp,
              child: const Icon(Icons.clear),
              tooltip: 'Reset App',
            ),
          ),
          const Spacer(), // pushes the mic to the right side
          ZoomIn(
            delay: Duration(milliseconds: start + 4 * delay),
            child: FloatingActionButton(
              heroTag: 'mic',
              backgroundColor: Pallete.firstSuggestionBoxColor,
              onPressed: () async {
                if (await speechToText.hasPermission && !speechToText.isListening) {
                  await startListening();
                } else if (speechToText.isListening) {
                  await stopListening();
                } else {
                  await initSpeechToText();
                }
              },
              child:  Icon(
                speechToText.isListening ? Icons.stop : Icons.mic,
              ),
              tooltip: 'Start Listening',
            ),
          ),
          const SizedBox(width: 16), // right padding
        ],
      ),
    );
  }
}
