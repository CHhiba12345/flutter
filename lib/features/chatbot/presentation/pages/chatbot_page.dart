import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../auth/presentation/blocs/auth_state.dart';
import '../bloc/chatbot_bloc.dart';
import '../bloc/chatbot_state.dart';

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
print('🔵 Message saisi : $question');
final authState = context.read<AuthBloc>().state;

if (authState is AuthSuccess) {
final userId = authState.user.uid;
print('🟢 User ID trouvé : $userId');

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
SendMessageEvent(
question: question,
userId: userId,
),
);
_controller.clear();
} else {
print('🔴 Utilisateur non connecté');
}
} else {
print('⚠️ Aucun texte à envoyer');
}
}

@override
Widget build(BuildContext context) {
return Scaffold(appBar: AppBar(
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
return _buildChatArea(state);
},
),
),
const SizedBox(height: 12),
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

Widget _buildChatArea(ChatbotState state) {
  if (_showWelcomeMessage && _messages.isEmpty) {
    return SingleChildScrollView(  // <-- Ajout d'un SingleChildScrollView principal
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),  // <-- Ajout de padding vertical
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,  // <-- Important: mainAxisSize.min
            children: [
              // Animation optimisée
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

              // Titre
              Text(
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

              // Grille de cartes horizontales
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    _buildFeatureCard("🥑", "Diet plans"),
                    const SizedBox(width: 12),
                    _buildFeatureCard("🍎", "Nutritional values"),
                    const SizedBox(width: 12),
                    _buildFeatureCard("🥘", "Balanced recipes"),
                    const SizedBox(width: 12),
                    _buildFeatureCard("💪", "Your health goals"),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  else if (state is ChatbotLoading && _messages.isNotEmpty) {
    return Column(
      children: [
        Expanded(  // <-- Expanded pour la ListView
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return MessageBubble(
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
    controller: _scrollController,
    reverse: false,
    itemCount: _messages.length,
    itemBuilder: (context, index) {
      final message = _messages[index];
      return MessageBubble(
        message: message['text'],
        isUser: message['isUser'],
      );
    },
  );
}
}
// Fonction helper pour construire une Card avec un texte centré
Widget _buildFeatureCard(String emoji, String text) {
return Container(
width: 120, // Largeur fixe pour uniformité
padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(12),
boxShadow: [
BoxShadow(
color: Colors.grey.withOpacity(0.1),
blurRadius: 8,
offset: const Offset(0, 2),
)
],
border: Border.all(color: Colors.green.shade100, width: 1),
),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Text(emoji, style: const TextStyle(fontSize: 24)),
const SizedBox(height: 8),
Text(
text,
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 13,
color: Colors.grey.shade800,
fontWeight: FontWeight.w500,
),
),
],
),
);
}
class MessageBubble extends StatelessWidget {
final String message;
final bool isUser;

const MessageBubble({
Key? key,
required this.message,
required this.isUser,
}) : super(key: key);

@override
Widget build(BuildContext context) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
child: Align(
alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
child: ConstrainedBox(
constraints: BoxConstraints(
maxWidth: MediaQuery.of(context).size.width * 0.8,
),
child: Container(
padding: const EdgeInsets.all(12),
margin: const EdgeInsets.only(bottom: 8),
decoration: BoxDecoration(
color: isUser
? Colors.lightGreen.withOpacity(0.8)
    : Colors.grey[300],
borderRadius: BorderRadius.circular(16),
),
child: Text(
message,
style: TextStyle(
fontSize: 15,
color: isUser ? Colors.white : Colors.black87,
),
),
),
),
),
);
}
}