import 'package:auto_route/annotations.dart';
import 'package:eye_volve/features/history/domain/usecases/delete_history_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/data/datasources/auth_service.dart';
import '../../data/datasources/history_datasource.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../domain/usecases/get_history_usecase.dart';
import '../../domain/usecases/record_history.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart'; // Import ajouté
import '../bloc/history_state.dart';
import '../widgets/history_card.dart';

@RoutePage()
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
      ),
      body: BlocProvider(
        create: (context) {
          final dataSource = HistoryDataSource(jwtToken: 'your_jwt_token');
          final repository = HistoryRepositoryImpl(dataSource: dataSource);
          return HistoryBloc(
            getHistoryUseCase: GetHistoryUseCase(repository: repository),
            recordHistory: RecordHistory(repository: repository),
            deleteHistory: DeleteHistoryUseCase(repository: repository),
          )..add(const LoadHistoryEvent());
        },
        child: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HistoryError) {
              return Center(child: Text(state.message));
            } else if (state is HistoryLoaded) {
              return ListView.builder(
                itemCount: state.histories.length,
                itemBuilder: (context, index) {
                  final history = state.histories[index];
                  return HistoryCard(
                    history: history,
                    onDelete: () {
                      context.read<HistoryBloc>().add(DeleteHistoryEvent(historyId: history.id!));
                    },
                  );
                },
              );
            } else {
              return const Center(child: Text('Aucun historique disponible'));
            }
          },
        ),
      ),
    );
  }
}