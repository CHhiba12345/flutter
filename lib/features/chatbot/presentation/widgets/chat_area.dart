import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import ' chat_message_bubble.dart';
import '../bloc/chatbot_bloc.dart';
import '../bloc/chatbot_state.dart';

import '../widgets/feature_card.dart';

class ChatArea extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final bool showWelcomeMessage;
  final ScrollController scrollController;

  const ChatArea({
    Key? key,
    required this.messages,
    required this.showWelcomeMessage,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ChatbotBloc>().state;

    if (showWelcomeMessage && messages.isEmpty) {
      return SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.lightGreen.shade50,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Lottie.asset(
                    'assets/animations/chat.json',
                    width: 190,
                    height: 190,
                    repeat: true,
                    animate: true,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "I'm here anytime to help with all your nutrition questions like ..",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black38,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      FeatureCard(emoji: "🥑", text: "Diet plans"),
                      const SizedBox(width: 12),
                      FeatureCard(emoji: "🍎", text: "Nutritional values"),
                      const SizedBox(width: 12),
                      FeatureCard(emoji: "🥘", text: "Balanced recipes"),
                      const SizedBox(width: 12),
                      FeatureCard(emoji: "💪", text: "Your health goals"),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (state is ChatbotLoading && messages.isNotEmpty) {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ChatMessageBubble(
                  message: message['text'],
                  isUser: message['isUser'],
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: scrollController,
      reverse: false,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return ChatMessageBubble(
          message: message['text'],
          isUser: message['isUser'],
        );
      },
    );
  }
}