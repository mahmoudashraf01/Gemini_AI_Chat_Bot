import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/screens/chat_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(GeminiAIChatBot(
    apiKey: dotenv.env['API_KEY'],
  ));
}

class GeminiAIChatBot extends StatelessWidget {
  const GeminiAIChatBot({super.key, this.apiKey});

  final String? apiKey;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini AI Chat Bot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(
        useMaterial3: true,
      ),
      home: ChatPAge(
        apiKey: apiKey!,
      ),
    );
  }
}
