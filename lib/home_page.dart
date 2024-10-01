import 'dart:io';
import 'dart:typed_data';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String wordsSpoken = "";
  final SpeechToText speechToText = SpeechToText();
  bool speechEnabled = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    print("Checking microphone permission...");
    var status = await Permission.microphone.status;
    print("Current microphone permission status: $status");
    
    if (status.isDenied) {
      print("Microphone permission is denied. Requesting permission...");
      status = await Permission.microphone.request();
      print("Microphone permission request result: $status");
    }

    if (status.isGranted) {
      print("Microphone permission is granted. Initializing speech...");
      initSpeech();
    } else {
      print("Microphone permission is not granted. Speech recognition will not be available.");
      setState(() {
        speechEnabled = false;
        wordsSpoken = "Microphone permission denied";
      });
    }
  }

  void initSpeech() async {
    try {
      print("Initializing speech recognition...");
      speechEnabled = await speechToText.initialize(
        onError: (error) => print("Speech recognition error: $error"),
        onStatus: (status) => print("Speech recognition status: $status"),
      
      );
      print("Speech recognition initialized. Enabled: $speechEnabled");
      setState(() {});
    } catch (e) {
      print("Error initializing speech recognition: $e");
      setState(() {
        speechEnabled = false;
        wordsSpoken = "Error initializing speech recognition";
      });
    }
  }

  void _startListening() async {
    print("Attempting to start listening...");
    if (speechEnabled) {
      try {
        await speechToText.listen(onResult: _onSpeechResult);
        setState(() {
          wordsSpoken = "Listening...";
        });
        print("Started listening successfully");
      } catch (e) {
        print("Error starting speech recognition: $e");
        setState(() {
          wordsSpoken = "Error starting speech recognition";
        });
      }
    } else {
      print("Speech recognition not available");
      setState(() {
        wordsSpoken = "Speech recognition not available";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Speech recognition not available. Please type your message.")),
      );
    }
  }

  void _stopListening() async {
    print("Stopping speech recognition...");
    await speechToText.stop();
    setState(() {
      wordsSpoken = "Stopped listening";
    });
    print("Stopped listening");
  }

  void _onSpeechResult(result) {
    print("Speech result received: ${result.recognizedWords}");
    setState(() {
      wordsSpoken = result.recognizedWords;
      if (result.finalResult) {
        print("Final result received. Sending as chat message.");
        ChatMessage chatMessage = ChatMessage(
          user: currentUser,
          createdAt: DateTime.now(),
          text: wordsSpoken,
        );
        sendMessage(chatMessage);
        wordsSpoken = "";
      }
    });
  }

  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(id: "1", firstName: "Gemini");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Gemini Chat'),
      ),
      body: buildUi(),
    );
  }

  Widget buildUi() {
    return Column(
      children: [
        Expanded(
          child: DashChat(
            currentUser: currentUser,
            onSend: sendMessage,
            messages: messages,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                onPressed: speechToText.isListening ? _stopListening : _startListening,
                icon: Icon(speechToText.isListening ? Icons.mic : Icons.mic_none),
                color: speechToText.isListening ? Colors.red : null,
              ),
              Expanded(
                child: Text(wordsSpoken),
              ),
              IconButton(
                onPressed: sendMediaMessage,
                icon: Icon(Icons.image),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      String question = chatMessage.text;
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [File(chatMessage.medias!.first.url).readAsBytesSync()];
      }
      gemini.streamGenerateContent(question, images: images).listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          String response = event.content?.parts
                  ?.fold("", (previous, current) => "$previous ${current.text}") ??
              "";
          lastMessage.text += response;
          setState(() {
            messages = [lastMessage!, ...messages];
          });
        } else {
          String response = event.content?.parts
                  ?.fold("", (previous, current) => "$previous ${current.text}") ??
              "";
          ChatMessage message = ChatMessage(
              user: geminiUser, createdAt: DateTime.now(), text: response);
          setState(() {
            messages = [message, ...messages];
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "Describe this Picture?",
        medias: [
          ChatMedia(url: file.path, fileName: "", type: MediaType.image)
        ],
      );
      sendMessage(chatMessage);
    }
  }
}