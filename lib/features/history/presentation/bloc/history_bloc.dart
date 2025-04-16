import 'dart:io';

import 'package:eye_volve/features/history/domain/usecases/delete_history_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_history_usecase.dart';
import '../../domain/usecases/record_history.dart';
import 'history_event.dart'; // Ajout de cet import
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistoryUseCase getHistoryUseCase;
  final RecordHistory recordHistory;
  final DeleteHistoryUseCase deleteHistory;

  HistoryBloc({
    required this.getHistoryUseCase,
    required this.recordHistory,
    required this.deleteHistory,
  }) : super(HistoryInitial()) {



    on<LoadHistoryEvent>((event, emit) async {
      emit(HistoryLoading());
      try {
        final histories = await getHistoryUseCase.execute();
        print("=========");
        emit(HistoryLoaded(histories));
      } on FormatException catch (e) {
        emit(HistoryError('Format de données invalide : ${e.message}'));
      } on Exception catch (e) {
        emit(HistoryError('Erreur : ${e.toString()}'));
      }catch(e){
        print("************** $e");
      }
    });

    on<RecordScanEvent>((event, emit) async {
      try {
        await recordHistory.recordScan(productId: event.productId);
        add(LoadHistoryEvent());
      } catch (e) {
        emit(HistoryError('Failed to record scan: ${e.toString()}'));
      }
    });

    on<RecordViewEvent>((event, emit) async {
      try {
        await recordHistory.recordView(productId: event.productId);
        add(LoadHistoryEvent());
      } catch (e) {
        emit(HistoryError('Failed to record view: ${e.toString()}'));
      }
    });
    on<DeleteHistoryEvent>((event, emit) async {
      if (event.historyId.isEmpty) {
        emit(HistoryError('ID invalide pour la suppression'));
        return;
      }
      try {
        await deleteHistory.execute(event.historyId); // Supprime l'entrée
        add(LoadHistoryEvent()); // Recharge l'historique après suppression
      } catch (e) {
        emit(HistoryError('Échec de la suppression : ${e.toString()}'));
      }
    });
  }
}