# AI-Powered Chatbot and Image Generator App

This Flutter-based mobile app combines two powerful features into a single application: a chatbot that assists users by answering questions and generating content, and an AI image generator that creates images based on user-provided prompts using the Stability AI API. The app has a user-friendly interface and provides a seamless experience for interacting with AI models.

## Features

### 1. Chatbot
- **Conversational Interface**: Users can interact with a chatbot that answers questions, provides information, and offers recommendations.
- **User-friendly UI**: The chatbot interface is intuitive, making it easy for users to type queries and receive responses.
- **Intelligent Responses**: The chatbot utilizes AI technology to provide meaningful and contextually relevant responses to user inputs.

### 2. Image Generator
- **Text-to-Image Generation**: Generate images from a prompt using Stability AI's Stable Diffusion model.
- **Real-time Updates**: Users can input a new prompt to generate a new image, and the existing image is replaced accordingly.
- **Loading State**: While generating the image, a loading spinner is displayed to provide a visual indication of the process.
- **Local Image Storage**: Generated images are saved locally, allowing users to view them after the generation process is complete.

### 3. Flutter Animations
- **Smooth Transitions**: Flutter animations are used to provide smooth visual transitions throughout the app, enhancing the user experience.
- **Loading Animations**: Animated loading indicators are displayed while the app is processing requests, making the experience visually appealing.



## Getting Started

### Prerequisites
- [Flutter](https://flutter.dev/docs/get-started/install) (version 2.0 or later)
- [Dart](https://dart.dev/get-dart) (version 2.12 or later)

### Installation

1. **Clone the Repository**:

2. **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3. **Set Up API Keys**:
    - Replace the placeholder API key in `image_generator.dart` with your own Stability AI API key.

4. **Run the App**:
    ```bash
    flutter run
    ```

## Project Structure

```plaintext
.
├── lib/
│   ├── home_page.dart           # Main page for the app with navigation
│   ├── front_page.dart          # Chatbot functionality
│   ├── image_generator.dart     # Image generator functionality
│   └── main.dart                # App entry point
├── assets/
│   ├── images/                  # Static images used in the app
├── pubspec.yaml                 # Dependencies for the Flutter project
