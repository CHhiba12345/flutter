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

  Future<void> _onScanTicket(ScanTicketEvent event,
      Emitter<TicketState> emit,) async {
    emit(TicketLoading());
    try {
      debugPrint('🔵 Starting receipt scan and analysis');

      // 1. Scan et analyse du ticket
      final analysis = await scannerService.scanAndAnalyzeReceipt();
      debugPrint('✅ Received analysis from Gemini');

      // 2. Envoi des données brutes au backend (enveloppé dans un try/catch séparé)
      try {
        final ticket = Ticket.fromJson(analysis['receipt_data']);
        await sendTicketUseCase.execute(ticket);
        debugPrint('📡 Ticket data sent to backend');
      } catch (e) {
        debugPrint('⚠️ Failed to send to backend (but continuing): $e');
        // On continue même si l'envoi échoue
      }

      // 3. Affichage de l'analyse dans tous les cas
      emit(TicketAnalysisSuccess(
        analysis: analysis['nutrition_analysis'],
        receiptData: analysis['receipt_data'], // Ajout des données brutes pour affichage
      ));
    } catch (e) {
      debugPrint('❌ Error: $e');
      emit(TicketError('Failed to scan receipt: ${e.toString()}'));
    }
  }
  Future<void> _onGetPriceComparisons(
      GetPriceComparisonsEvent event,
      Emitter<TicketState> emit,
      ) async {
    try {
      final comparisons = await getPriceComparisonsUseCase.execute(event.productName);

      // Si l'état actuel est TicketAnalysisSuccess, on le conserve avec les nouvelles comparaisons
      if (state is TicketAnalysisSuccess) {
        final currentState = state as TicketAnalysisSuccess;
        emit(currentState.copyWith(comparisons: comparisons));
      } else {
        emit(PriceComparisonsLoaded(comparisons: comparisons));
      }
    } catch (e) {
      emit(TicketError('Failed to load price comparisons: ${e.toString()}'));
    }
  }
}