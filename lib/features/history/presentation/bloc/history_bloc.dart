import 'dart:io';

import 'package:eye_volve/features/history/domain/usecases/delete_history_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_history_usecase.dart';
import '../../domain/usecases/record_history.dart';
import 'history_event.dart';
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
    on<LoadHistoryEvent>(_onLoadHistory);
    on<RecordScanEvent>(_onRecordScan);
    on<RecordViewEvent>(_onRecordView);
    on<DeleteHistoryEvent>(_onDeleteHistory);
  }

  /// Charge l'historique complet de l'utilisateur
  Future<void> _onLoadHistory(
      LoadHistoryEvent event,
      Emitter<HistoryState> emit) async {
    emit(HistoryLoading());
    try {
      final histories = await getHistoryUseCase.execute();
      emit(HistoryLoaded(histories));
    } on FormatException catch (e) {
      emit(HistoryError('Format de données invalide : ${e.message}'));
    } on Exception catch (e) {
      emit(HistoryError('Erreur lors du chargement : ${e.toString()}'));
    }
  }

  /// Enregistre une action de scan
  Future<void> _onRecordScan(
      RecordScanEvent event,
      Emitter<HistoryState> emit) async {
    try {
      await recordHistory.recordScan(productId: event.productId);
      add(LoadHistoryEvent());
    } catch (e) {
      emit(HistoryError('Échec de l\'enregistrement du scan : $e'));
    }
  }

  /// Enregistre une consultation de produit
  Future<void> _onRecordView(
      RecordViewEvent event,
      Emitter<HistoryState> emit) async {
    try {
      await recordHistory.recordView(productId: event.productId);
      add(LoadHistoryEvent());
    } catch (e) {
      emit(HistoryError('Échec de l\'enregistrement de la vue : $e'));
    }
  }

  /// Supprime une entrée d'historique
  Future<void> _onDeleteHistory(
      DeleteHistoryEvent event,
      Emitter<HistoryState> emit) async {
    if (event.historyId.isEmpty) {
      emit(HistoryError('ID invalide pour la suppression'));
      return;
    }

    try {
      await deleteHistory.execute(event.historyId);
      add(LoadHistoryEvent());
    } catch (e) {
      emit(HistoryError('Échec de la suppression : ${e.toString()}'));
    }
  }
}