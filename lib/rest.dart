import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

final homeProvider = ChangeNotifierProvider<HomeProvider>((ref) => HomeProvider());

class HomeProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isSearching = false;
  Uint8List? imageData;

  void loadingChange(bool val) {
    isLoading = val;
    notifyListeners();
  }

  void searchingChange(bool val) {
    isSearching = val;
    notifyListeners();
  }

  Future<void> textToImage(String prompt, BuildContext context) async {
    String apiHost = 'https://api.stability.ai';
    String apiKey = 'sk-OyBGkvEgtXi5tPzYtieEHOU5UngBgPPrRf6m5uEwTH8wjTos';
    
    debugPrint(prompt);
    loadingChange(true);
    searchingChange(true);
    
    final response = await http.post(
      Uri.parse('$apiHost/v2beta/stable-image/generate/ultra'),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Accept": "image/*",
      },
      // This line is specific to the Python request, it may not be applicable in Dart.
      body: {
        "prompt": prompt,
        "output_format": "webp",
      },
    );

    if (response.statusCode == 200) {
      try {
        debugPrint(response.statusCode.toString());
        imageData = response.bodyBytes; // Store the received image data
        // Optionally, save to a file or use directly in the app
      } catch (e) {
        debugPrint("Failed to generate image: $e");
      } finally {
        loadingChange(false);
        searchingChange(false);
      }
    } else {
      debugPrint("Failed to generate image: ${response.body}");
      loadingChange(false);
      searchingChange(false);
      throw Exception('Error: ${response.statusCode}, ${response.body}');
    }
  }
}
