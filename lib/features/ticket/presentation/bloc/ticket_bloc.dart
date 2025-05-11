import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/receipt_scanner_service.dart';
import '../../domain/usecases/get_price_comparisons_usecase.dart';
import '../../domain/usecases/send_ticket_usecase.dart';
import '../../domain/entities/ticket.dart';
import 'ticket_event.dart';
import 'ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final SendTicketUseCase sendTicketUseCase;
  final ReceiptScannerService scannerService;
  final GetPriceComparisonsUseCase getPriceComparisonsUseCase;
  TicketBloc({
    required this.sendTicketUseCase,
    required this.scannerService,
    required this.getPriceComparisonsUseCase,
  }) : super(TicketInitial()) {
    on<ScanTicketEvent>(_onScanTicket);
    on<GetPriceComparisonsEvent>(_onGetPriceComparisons);
  }

  Future<void> _onScanTicket(ScanTicketEvent event, Emitter<TicketState> emit) async {
    emit(TicketLoading());
    try {
      final analysis = await scannerService.scanAndAnalyzeReceipt();
      final ticket = Ticket.fromJson(analysis['receipt_data']);

      await sendTicketUseCase.execute(ticket);

      // Initialisez avec une liste vide si vous ne pouvez pas obtenir les comparaisons
      emit(TicketAnalysisSuccess(
        analysis: analysis['nutrition_analysis'],
        receiptData: analysis['receipt_data'],
        priceComparisons: [], // Liste vide par défaut
      ));

    } catch (e) {
      emit(TicketError('Failed to scan receipt: ${e.toString()}'));
    }
  }
  Future<void> _onGetPriceComparisons(
      GetPriceComparisonsEvent event,
      Emitter<TicketState> emit,
      ) async {
    if (state is! TicketAnalysisSuccess) return;

    final currentState = state as TicketAnalysisSuccess;
    emit(TicketLoading()); // Affiche un indicateur de chargement

    try {
      final comparisons = await getPriceComparisonsUseCase.execute(event.productName);

      if (comparisons.isEmpty) {
        emit(TicketError('Aucune comparaison disponible pour ce produit'));
        await Future.delayed(Duration(milliseconds: 500)); // Petit délai pour le message
      }

      emit(PriceComparisonsLoaded(
        comparisons: comparisons,
        currentAnalysis: currentState.analysis,
        currentReceiptData: currentState.receiptData,
      ));

    } catch (e) {
      emit(TicketError('Erreur lors de la récupération des comparaisons'));
      emit(currentState); // Revenir à l'état précédent
    }
  }
}