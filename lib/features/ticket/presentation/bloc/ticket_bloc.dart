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
    debugPrint('🔄 [TicketBloc] Processing ScanTicketEvent...');
    emit(TicketLoading());

    try {
      debugPrint('📷 [TicketBloc] Calling scannerService.scanAndAnalyzeReceipt()');
      final analysis = await scannerService.scanAndAnalyzeReceipt();
      debugPrint('✅ [TicketBloc] Received analysis data: ${analysis.keys}');

      debugPrint('🎫 [TicketBloc] Creating Ticket from analysis data');
      final ticket = Ticket.fromJson(analysis['receipt_data']);
      debugPrint('🛒 [TicketBloc] Ticket created for store: ${ticket.storeName}');

      debugPrint('📤 [TicketBloc] Sending ticket via sendTicketUseCase');
      await sendTicketUseCase.execute(ticket);
      debugPrint('📬 [TicketBloc] Ticket successfully sent');

      emit(TicketAnalysisSuccess(
        analysis: analysis['nutrition_analysis'],
        receiptData: analysis['receipt_data'],
        priceComparisons: [],
      ));
      debugPrint('🏁 [TicketBloc] Emitted TicketAnalysisSuccess state');

    } catch (e, stackTrace) {
      debugPrint('❌ [TicketBloc] Error in _onScanTicket: $e');
      debugPrint('📜 Stack trace: $stackTrace');
      emit(TicketError('Failed to scan receipt: ${e.toString()}'));
      debugPrint('⚠️ [TicketBloc] Emitted TicketError state');
    }
  }

  Future<void> _onGetPriceComparisons(
      GetPriceComparisonsEvent event,
      Emitter<TicketState> emit,
      ) async {
    debugPrint('🔄 [TicketBloc] Processing GetPriceComparisonsEvent for product: ${event.productName}');

    // Accepter soit TicketAnalysisSuccess soit PriceComparisonsLoaded comme état valide
    final Map<String, dynamic> currentAnalysis;
    final Map<String, dynamic> currentReceiptData;

    if (state is TicketAnalysisSuccess) {
      final s = state as TicketAnalysisSuccess;
      currentAnalysis = s.analysis;
      currentReceiptData = s.receiptData;
    } else if (state is PriceComparisonsLoaded) {
      final s = state as PriceComparisonsLoaded;
      currentAnalysis = s.currentAnalysis;
      currentReceiptData = s.currentReceiptData;
    } else {
      debugPrint('⏭️ [TicketBloc] Current state is not valid for comparisons, skipping');
      return;
    }

    debugPrint('⏳ [TicketBloc] Emitting TicketLoading state');
    emit(TicketLoading());

    try {
      debugPrint('🔍 [TicketBloc] Fetching price comparisons for: ${event.productName}');
      final comparisons = await getPriceComparisonsUseCase.execute(event.productName);
      debugPrint('📊 [TicketBloc] Received ${comparisons.length} comparison(s)');

      if (comparisons.isEmpty) {
        debugPrint('📭 [TicketBloc] No comparisons found, emitting empty state');
        emit(TicketAnalysisSuccess(
          analysis: currentAnalysis,
          receiptData: currentReceiptData,
          priceComparisons: [],
        ));
        return;
      }

      debugPrint('📈 [TicketBloc] Emitting PriceComparisonsLoaded with ${comparisons.length} items');
      emit(PriceComparisonsLoaded(
        comparisons: comparisons,
        currentAnalysis: currentAnalysis,
        currentReceiptData: currentReceiptData,
        productName: event.productName,
      ));

    } catch (e, stackTrace) {
      debugPrint('❌ [TicketBloc] Error fetching comparisons: $e');
      debugPrint('📜 Stack trace: $stackTrace');
      debugPrint('🔄 [TicketBloc] Reverting to previous state');
      emit(TicketAnalysisSuccess(
        analysis: currentAnalysis,
        receiptData: currentReceiptData,
        priceComparisons: [],
      ));
    }
  }
}