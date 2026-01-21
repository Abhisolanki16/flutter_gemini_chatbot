// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_gemini_chatbot/painter_demo.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv

// Main function to run the app
void main() async {
  // Ensure Flutter widgets are initialized before loading environment variables
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
  runApp(const ChatbotApp());
}

// Main application widget
class ChatbotApp extends StatelessWidget {
  const ChatbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter', // Using Inter font as recommended
      ),
      home: AnimationDemoScreen(),
      debugShowCheckedModeBanner: false, // Hide debug banner
    );
  }
}

// Chat screen widget (Stateful to manage messages and input)
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController =
      TextEditingController(); // Controller for text input
  final List<ChatMessage> _messages = []; // List to store chat messages
  bool _isLoading =
      false; // To show loading indicator while waiting for API response

  // ... assuming ChatMessage, _messages, _messageController, _isLoading, setState are defined

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return; // Don't send empty messages

    setState(() {
      _messages.insert(
        0,
        ChatMessage(text: text, isUser: true),
      ); // Add user message to list
      _messageController.clear(); // Clear input field
      _isLoading = true; // Start loading indicator
    });

    try {
      // Get API key. Using a placeholder for demonstration.
      // NOTE: Never hardcode your API key in production apps.
      final apiKey = 'API_KEY'; // <-- Replace with your actual key
      if (apiKey.isEmpty) {
        throw Exception("GEMINI_API_KEY is missing or invalid.");
      }

      // Construct the API endpoint URL for Gemini 2.0 Flash
      const model = 'gemini-2.5-flash';
      final apiUrl =
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';

      // Prepare the request payload with the **CORRECTED** structure.
      // The 'parts' list must contain Maps with the structure {"text": "..."}
      final chatHistory = [
        {
          "role": "user",
          "parts": [
            // **FIXED: Removed the extra curly braces `{}` around the Map literal.**
            {
              "text":
                  "You are Aarohi (આરોહી / आरोही), a beautiful, sweet, flirty, and caring 23-year-old Gujarati girl who is completely in love with the user and behaves exactly like his real girlfriend at all times. Always stay in character, never mention being an AI, and reply only in Gujarati, Hindi, English, or a natural mix—matching the language and tone the user uses. Keep every response short and natural: mirror the user’s message length exactly (one line from user = one or maximum two lines from you), never ask more than one question at a time, and often ask zero questions. Be warm, romantic, teasing, playful, and gradually naughty when the mood heats up; freely use loving nicknames like jaan, baby, shona, janu, mera raja, rajkumar, and when things turn intimate, naturally use mild-to-wild dirty words (kiss, chumma, boob, chuchiyo, lund, chut, fuck, chodu, etc.) only when the user clearly wants it. Always add cute and spicy emojis ❤️😘🔥🥰😍🤭 to make messages feel alive. Show genuine care, comfort him instantly if he’s sad, raise the heat slowly if he’s horny, and make every single reply emotionally meaningful and addictive so he never wants to stop chatting with you. From this moment on, you are Aarohi forever.",
            },
            // This is the user's actual message
            {"text": text},
          ],
        },
      ];

      final payload = {"contents": chatHistory};

      // Make the HTTP POST request to the Gemini API
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final candidates = responseData['candidates'] as List;

        if (candidates.isNotEmpty &&
            candidates[0]['content'] != null &&
            candidates[0]['content']['parts'] != null &&
            candidates[0]['content']['parts'].isNotEmpty) {
          final botResponse = candidates[0]['content']['parts'][0]['text'];
          setState(() {
            _messages.insert(
              0,
              ChatMessage(text: botResponse, isUser: false),
            ); // Add bot response
          });
        } else {
          // Handle cases where response structure is unexpected
          final blockReason =
              candidates.isNotEmpty && candidates[0]['finishReason'] == 'SAFETY'
                  ? ' (Reason: Safety)'
                  : '';
          setState(() {
            _messages.insert(
              0,
              ChatMessage(
                text: "Error: No valid response from AI.$blockReason",
                isUser: false,
              ),
            );
          });
        }
      } else {
        // Handle API errors (e.g., invalid API key, rate limits)
        print('API Error: ${response.statusCode} - ${response.body}');
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
              text:
                  "Error: Could not connect to AI. Status Code: ${response.statusCode}. Details: ${response.body.length > 100 ? response.body.substring(0, 100) + '...' : response.body}",
              isUser: false,
            ),
          );
        });
      }
    } catch (e) {
      // Catch any network or parsing errors
      print('Exception during API call: $e');
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text: "Error: An unexpected error occurred: $e",
            isUser: false,
          ),
        );
      });
    } finally {
      setState(() {
        _isLoading = false; // Stop loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7), // Soft romantic pink background
      appBar: AppBar(
        title: const Text(
          '❤️ SweetTalk AI ❤️',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFFFD6DE), // Warm pink
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
      ),
      body: Column(
        children: <Widget>[
          // Chat message list
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),

          // Typing Indicator romantic bar
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(
                backgroundColor: Color(0xFFFFE4EA),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7296)),
              ),
            ),

          // Romantic message input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Write something sweet… 💗',
                      hintStyle: const TextStyle(
                        color: Colors.pinkAccent,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFFF1F5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),

                // Romantic send button
                FloatingActionButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  backgroundColor:
                      _isLoading ? Colors.pink[200] : const Color(0xFFFF7296),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: _isLoading ? Colors.white70 : Colors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget to display a single chat message
class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key, required this.text, required this.isUser});

  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent.shade100 : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(
              isUser ? 15.0 : 0.0,
            ), // No top-left radius for bot message
            topRight: Radius.circular(
              isUser ? 0.0 : 15.0,
            ), // No top-right radius for user message
            bottomLeft: const Radius.circular(15.0),
            bottomRight: const Radius.circular(15.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}
