part of 'chatbot_bloc.dart';

abstract class ChatbotEvent {}

class SendMessageEvent extends ChatbotEvent {
  final String question;
  final String userId;

  SendMessageEvent({required this.question, required this.userId});
}