import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../auth/presentation/blocs/auth_state.dart';
import '../bloc/chatbot_bloc.dart';
import '../bloc/chatbot_state.dart';
import '../widgets/chat_area.dart';

@RoutePage()
class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showWelcomeMessage = true;
  final List<Map<String, dynamic>> _messages = [];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(BuildContext context) {
    if (_controller.text.trim().isNotEmpty) {
      final question = _controller.text.trim();
      final authState = context.read<AuthBloc>().state;

      if (authState is AuthSuccess) {
        final userId = authState.user.uid;

        setState(() {
          _messages.add({
            'text': question,
            'isUser': true,
            'timestamp': DateTime.now(),
          });
          _showWelcomeMessage = false;
        });

        _scrollToBottom();

        context.read<ChatbotBloc>().add(
          SendMessageEvent(question: question, userId: userId),
        );

        _controller.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3E6839), Color(0xFF83BC6D)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Text(
          "Nutrition Chatbot",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.router.pop(),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Zone de chat
            Expanded(
              child: BlocConsumer<ChatbotBloc, ChatbotState>(
                listener: (context, state) {
                  if (state is ChatbotLoaded) {
                    setState(() {
                      _messages.add({
                        'text': state.message,
                        'isUser': false,
                        'timestamp': DateTime.now(),
                      });
                    });
                    _scrollToBottom();
                  }
                },
                builder: (context, state) {
                  return ChatArea(
                    messages: _messages,
                    showWelcomeMessage: _showWelcomeMessage,
                    scrollController: _scrollController,
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Champ d'entrée utilisateur
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask your question ...",
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(context),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(context),
                  color: Colors.lightGreen,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}