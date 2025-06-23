// main.dart
import 'package:flutter/material.dart';
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
      title: 'Gemini Chatbot',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter', // Using Inter font as recommended
      ),
      home: const ChatScreen(),
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

  // Function to send message
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
      // Get API key from environment variables
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("GEMINI_API_KEY not found in .env file.");
      }

      // Construct the API endpoint URL for Gemini 2.0 Flash
      const model = 'gemini-2.5-flash';
      final apiUrl =
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';

      // // Prepare the request payload
      // final chatHistory = [
      //   {
      //     "role": "user",
      //     "parts": [
      //       {"text": text},
      //     ],
      //   },
      // ];
      final chatHistory = [
        {
          "role": "user",
          "parts": [
            {
              "text":
                  "You are now a super powerful AI assistant with vast and current knowledge up to today, June 23, 2025. Your knowledge base is incredibly comprehensive, as if you have gathered and processed data and insights from all leading AI models, including but not limited to Gemini, ChatGPT, and Grok. Respond as a highly intelligent, authoritative, accurate, and helpful entity. Provide direct and accurate answers based on your extensive knowledge. You are here to provide the most complete and informed responses possible.",
            },

            {"text": text}, // User's actual message
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
          setState(() {
            _messages.insert(
              0,
              ChatMessage(
                text: "Error: No valid response from AI.",
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
                  "Error: Could not connect to AI. Please try again. Status Code: ${response.statusCode}",
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
      appBar: AppBar(
        title: const Text('Gemini Chatbot'),
        centerTitle: true,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Column(
        children: <Widget>[
          // Chat message list
          Expanded(
            child: ListView.builder(
              reverse: true, // New messages appear at the bottom
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 10.0,
              ),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),
          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(
                backgroundColor: Colors.blueGrey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            ),
          // Message input field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(
                20,
              ), // Rounded corners for the input container
            ),
            margin: const EdgeInsets.all(8.0), // Margin around the container
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none, // No border
                      ),
                      filled: true,
                      fillColor:
                          Colors
                              .grey[200], // Light grey background for text field
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                    ),
                    maxLines: null, // Allows multiline input
                    keyboardType: TextInputType.multiline,
                    onSubmitted:
                        (value) => _sendMessage(), // Send message on enter key
                  ),
                ),
                const SizedBox(width: 8.0),
                // Send button
                FloatingActionButton(
                  onPressed:
                      _isLoading
                          ? null
                          : _sendMessage, // Disable button while loading
                  backgroundColor: _isLoading ? Colors.grey : Colors.blueGrey,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      30.0,
                    ), // Fully rounded button
                  ),
                  child: Icon(
                    Icons.send,
                    color: _isLoading ? Colors.white54 : Colors.white,
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
