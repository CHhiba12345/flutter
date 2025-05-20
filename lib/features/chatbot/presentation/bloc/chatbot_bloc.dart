import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/send_question_usecase.dart';
import 'chatbot_state.dart';
part 'chatbot_event.dart';

class ChatbotBloc extends Bloc<ChatbotEvent, ChatbotState> {
  final SendQuestionUsecase usecase;

  ChatbotBloc({required this.usecase}) : super(ChatbotInitial()) {
    on<SendMessageEvent>(_onSendMessage);
  }

  FutureOr<void> _onSendMessage(SendMessageEvent event, Emitter<ChatbotState> emit) async {
    emit(ChatbotLoading());

    try {
      final response = await usecase.execute(event.question, event.userId);
      emit(ChatbotLoaded(
        question: event.question,
        message: response.message,
      ));
    } catch (e) {
      emit(ChatbotError(message: 'Erreur: $e'));
    }
  }
}