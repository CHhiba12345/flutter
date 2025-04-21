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
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';
import '../widgets/history_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final statusBarHeight = MediaQueryData.fromWindow(WidgetsBinding.instance.window).padding.top;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dataSource = HistoryDataSource(jwtToken: 'your_jwt_token');
        final repository = HistoryRepositoryImpl(dataSource: dataSource);
        return HistoryBloc(
          getHistoryUseCase: GetHistoryUseCase(repository: repository),
          recordHistory: RecordHistory(repository: repository),
          deleteHistory: DeleteHistoryUseCase(repository: repository),
        )..add(const LoadHistoryEvent());
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Stack(
          children: [
            // Background gradient
            Container(
              height: statusBarHeight + 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF13729A),
                    Color(0xFF7FD3F8),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(height: statusBarHeight),
                // Custom AppBar
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.history, color: Colors.white, size: 30),
                      const SizedBox(width: 12),
                      Text(
                        'History',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tabs
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.label, // ou TabBarIndicatorSize.tab
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        width: 4.0, // hauteur de l’indicateur
                        color: Color(0xFF8598A1),
                      ),
                      insets: EdgeInsets.symmetric(horizontal: 50), // contrôle la largeur
                    ),
                    labelColor: Colors.lightBlue,
                    unselectedLabelColor: const Color(0xFF708E98),
                    tabs: const [
                      Tab(text: 'History'),
                      Tab(text: 'Analyse'),
                    ],
                  ),
                ),
                  // Tab content
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // History Tab
                        BlocBuilder<HistoryBloc, HistoryState>(
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
                                      context.read<HistoryBloc>().add(
                                          DeleteHistoryEvent(historyId: history.id!));
                                    },
                                  );
                                },
                              );
                            } else {
                              return const Center(child: Text('No history available'));
                            }
                          },
                        ),
                        // Analyse Tab
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning, size: 50, color: Colors.orange),
                              SizedBox(height: 16),
                              Text('Not valid at the moment',
                                  style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}