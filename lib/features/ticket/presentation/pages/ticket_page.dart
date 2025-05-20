import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app_router.dart';
import '../bloc/ticket_bloc.dart';
import '../bloc/ticket_event.dart';
import '../bloc/ticket_state.dart';

@RoutePage()
class TicketPage extends StatelessWidget {
  const TicketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TicketBloc, TicketState>(
      listener: (context, state) {
        if (state is TicketAnalysisSuccess) {
          context.router.push(const TicketAnalysisRoute());
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2C5C2D), Color(0xFF5A9E5D)],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              _buildAppBar(),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: BlocBuilder<TicketBloc, TicketState>(
                      builder: (context, state) {
                        if (state is TicketLoading) {
                          return _buildScanningState();
                        }
                        return _buildInitialState(context);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

      ),
    );
  }

  Widget _buildScanningState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D6A4F)),
          ),
          const SizedBox(height: 24),
          Text(
            'Analyzing your ticket...',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'This will only take a moment...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Hero(
            tag: 'receiptIcon',
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.all(10),
              child: const Icon(
                Icons.receipt_long,
                color: Color(0xFF1B4332),
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Nutritional Analysis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildInitialState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.qr_code_scanner,
          size: 120,
          color: Colors.grey,
        ),
        const SizedBox(height: 32),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              Text(
                'Discover the nutritional secrets',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Scan your receipt to get a detailed analysis of your food purchases',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () => context.read<TicketBloc>().add(ScanTicketEvent()),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C5C2D),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            shadowColor: Colors.black.withOpacity(0.2),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [

              SizedBox(width: 8),
              Text(
                'Start Scanning',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
