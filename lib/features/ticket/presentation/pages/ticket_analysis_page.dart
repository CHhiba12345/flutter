import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart';
import '../bloc/ticket_bloc.dart';
import '../bloc/ticket_event.dart';
import '../bloc/ticket_state.dart';

@RoutePage()
class TicketAnalysisPage extends StatelessWidget {
  const TicketAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TicketBloc, TicketState>(
      listener: (context, state) {
        if (state is TicketError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Analyse des résultats',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 28),
            onPressed: () => context.router.pop(),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2C5C2D), Color(0xFF5A9E5D)],
              ),
            ),
          ),
          elevation: 0,
        ),
        body: BlocBuilder<TicketBloc, TicketState>(
          builder: (context, state) {
            if (state is TicketLoading) {
              return _buildLoadingState();
            }

            // ✅ Toujours afficher l'analyse si disponible, même pendant ou après une comparaison
            if (state is TicketAnalysisSuccess || state is PriceComparisonsLoaded) {
              final analysisState = (state is TicketAnalysisSuccess)
                  ? state
                  : TicketAnalysisSuccess(
                analysis: (state as PriceComparisonsLoaded).currentAnalysis ?? {},
                receiptData: state.currentReceiptData ?? {},
                priceComparisons: state.comparisons,
              );
              return _buildAnalysisSuccess(context, analysisState);
            }

            return _buildEmptyState();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.read<TicketBloc>().add(ScanTicketEvent()),
          backgroundColor: const Color(0xFF3E6839),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.qr_code_scanner,
            size: 28,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C5C2D).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const Center(
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C5C2D)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Analyse en cours...',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Nous analysons les produits de votre ticket pour vous donner les meilleures recommandations.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/empty_analysis.json',
            width: 250,
            height: 250,
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucune donnée disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Veuillez scanner un ticket pour voir l’analyse',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSuccess(BuildContext context, TicketAnalysisSuccess state) {
    final receiptData = state.receiptData;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.store,
                        color: Color(0xFF2C5C2D),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            receiptData['storeName'] ?? 'Magasin inconnu',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Acheté le ${receiptData['receiptDate'] ?? 'date inconnue'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildReceiptSummary(receiptData),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_basket,
                      color: Color(0xFF2C5C2D),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Analyse des produits',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C5C2D),
                      ),
                    ),
                    const Spacer(),
                    Chip(
                      label: const Text(
                        'produits',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFF2C5C2D),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final product = state.analysis['products'][index];
                return _buildProductCard(product, context);
              },
              childCount: (state.analysis['products'] as List).length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
            child: _buildGlobalAdvice(state.analysis['global_advice']),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptSummary(Map<String, dynamic> receiptData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  'Total dépensé',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${receiptData['totalAmount']?.toStringAsFixed(2) ?? '0.00'} DT',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF2C5C2D),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            width: 1,
            color: Colors.grey.withOpacity(0.2),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Nombre de produits',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(receiptData['products'] as List).length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF2C5C2D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getProcessingColor(product['processing_level'])
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _getProcessingEmoji(product['processing_level']),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['product_name'] ?? 'Produit inconnu',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getProcessingColor(
                                product['processing_level'])
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            product['processing_level'] ?? 'N/A',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getProcessingColor(
                                  product['processing_level']),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if ((product['health_risks'] as List).isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: (product['health_risks'] as List)
                      .map<Widget>((risk) {
                    return Chip(
                      label: Text(
                        risk,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.red[50],
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      labelStyle: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 12),
              _buildInfoTile(
                icon: Icons.lightbulb_outline_rounded,
                iconColor: const Color(0xFFFFC107),
                title: 'Conseil',
                content: product['advice'] ?? 'Pas d\'analyse disponible',
              ),
              const SizedBox(height: 12),
              _buildInfoTile(
                icon: Icons.thumb_up_rounded,
                iconColor: const Color(0xFF4CAF50),
                title: 'Recommandation',
                content:
                product['consumption_recommendation'] ?? 'Non spécifié',
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showOtherStoresPrices(context, product);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor: Colors.blue.withOpacity(0.3),
                    side: BorderSide.none,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.compare_arrows_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Voir le prix dans d\'autres magasins',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOtherStoresPrices(
      BuildContext context, Map<String, dynamic> product) {
    final productName = product['product_name'];
    final currentPrice = product['price']?.toDouble() ?? 0.0;

    if (productName == null || productName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nom du produit invalide')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: BlocProvider.value(
          value: BlocProvider.of<TicketBloc>(context),
          child: BlocConsumer<TicketBloc, TicketState>(
            listener: (context, state) {
              if (state is TicketError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              if (state is PriceComparisonsLoaded) {
                final comparisons = state.comparisons ?? [];
                return _buildPriceComparisonSheet(
                  context,
                  productName,
                  currentPrice,
                  comparisons,
                );
              }
              return _buildLoadingSheet();
            },
          ),
        ),
      ),
    );

    // 🔁 Déclencher l’événement après avoir construit la modale
    BlocProvider.of<TicketBloc>(context).add(
      GetPriceComparisonsEvent(productName: productName),
    );
  }

  Widget _buildLoadingSheet() {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildPriceComparisonSheet(
      BuildContext context,
      String productName,
      double currentPrice,
      List<Map<String, dynamic>> comparisons,
      ) {
    final validComparisons = (comparisons ?? [])
        .where((s) => s['price'] != null)
        .toList();

    Map<String, dynamic>? bestStore;
    for (var store in validComparisons) {
      if (bestStore == null || store['price'] < bestStore['price']) {
        bestStore = store;
      }
    }

    final otherStores =
    validComparisons.where((s) => s != bestStore).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Text(
            'Prix de $productName',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (bestStore != null)
            Row(
              children: [
                const Text('🟢 ', style: TextStyle(fontSize: 18)),
                Expanded(
                  child: Text(
                    'Le meilleur prix est chez ${bestStore['store']} : ${bestStore['price'].toStringAsFixed(2)} DT',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: otherStores.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey[200]),
              itemBuilder: (context, index) {
                final store = otherStores[index];
                return ListTile(
                  leading: const Text('🔵', style: TextStyle(fontSize: 20)),
                  title: Text(store['store']),
                  trailing: Text(
                    '${store['price']?.toStringAsFixed(2)} DT',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: Navigator.of(context).pop,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C5C2D),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Fermer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoComparisonsSheet(String productName) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Aucune comparaison trouvée',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Aucun prix trouvé pour "$productName" dans d’autres magasins',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: Navigator.of(context as BuildContext).pop,
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalAdvice(String advice) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0F2E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C5C2D).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: Color(0xFF2C5C2D),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Conseil Nutritionnel',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2C5C2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            advice,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProcessingColor(String? level) {
    switch (level) {
      case 'naturel':
        return const Color(0xFF4CAF50);
      case 'transformé':
        return const Color(0xFFFFC107);
      case 'ultra-transformé':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _getProcessingEmoji(String? level) {
    switch (level) {
      case 'naturel':
        return '🌿';
      case 'transformé':
        return '⚙️';
      case 'ultra-transformé':
        return '⚠️';
      default:
        return '❓';
    }
  }
}