
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class TextToImageScreen extends StatefulWidget {
  @override
  _TextToImageScreenState createState() => _TextToImageScreenState();
}

class _TextToImageScreenState extends State<TextToImageScreen> {
  final String apiHost = "https://api.stability.ai";
  final String engineId = "stable-diffusion-v1-6";
  final String apiKey = "sk-DMLSZJSXsK0AgHDUV839O1ODEyCV8rBpVGTLRvXZeLiJ6tBb"; // Replace with your API Key
  String? _imagePath;
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false; // State to track loading

  Future<void> _generateImage() async {
    // Reset the image path to null before generating a new image
    setState(() {
      _imagePath = null; // Clear the previous image path
      _isLoading = true; // Start loading
    });

    final response = await http.post(
      Uri.parse('$apiHost/v1/generation/$engineId/text-to-image'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "text_prompts": [
          {
            "text": _textController.text,
          },
        ],
        "cfg_scale": 7,
        "height": 1024,
        "width": 1024,
        "samples": 1,
        "steps": 30,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["artifacts"].isNotEmpty) {
        final base64Image = data["artifacts"][0]["base64"]; // Get the first image only
        final imageBytes = base64.decode(base64Image);
        await _saveImage(imageBytes); // Save the image and clear previous ones
      }
    } else {
      setState(() {
        _isLoading = false; // Stop loading in case of failure
      });
      throw Exception("Failed to generate image: ${response.statusCode}");
    }
  }

  Future<void> _saveImage(List<int> bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/latest_image.png'; // Save with a constant name
    final file = File(path);
    await file.writeAsBytes(bytes);
    setState(() {
      _imagePath = path; // Store the path of the latest image
      _isLoading = false; // Stop loading
    });
    print('Image saved at $path');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Text to Image Generation')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TextField for user input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter a prompt',
                ),
              ),
            ),
            SizedBox(height: 20),
            // Show loading spinner if generating image
            if (_isLoading)
              CircularProgressIndicator()
            else if (_imagePath != null) ...[
              // Show the image only if it's generated
              Image.file(File(_imagePath!)),
              SizedBox(height: 20),
            ],
            ElevatedButton(
              onPressed: _generateImage,
              child: Text('Generate Image'),
            ),
          ],
        ),
      ),
    );
  }
}