import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
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
            'Nutrition Analysis',
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

            if (state is TicketAnalysisSuccess || state is PriceComparisonsLoaded) {
              late final TicketAnalysisSuccess analysisState;

              if (state is TicketAnalysisSuccess) {
                analysisState = state;
              } else {
                final loadedState = state as PriceComparisonsLoaded;
                analysisState = TicketAnalysisSuccess(
                  analysis: loadedState.currentAnalysis,
                  receiptData: loadedState.currentReceiptData,
                  priceComparisons: loadedState.comparisons,
                );
              }

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
            'Analyzing...',
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
              'We are analyzing your receipt products to provide the best recommendations.',
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
            'No data available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please scan a receipt to view analysis',
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
    final products = state.analysis['products'] as List<dynamic>;

    final uniqueProducts = products.fold<Map<String, dynamic>>({}, (map, product) {
      final name = product['product_name'] as String;
      map.putIfAbsent(name, () => product);
      return map;
    }).values.toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.store, color: Color(0xFF2C5C2D), size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            receiptData['storeName'] ?? 'Magasin inconnu',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B1B1B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Acheté le ${_formatDate(receiptData['receiptDate'] as String?)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildReceiptSummary(receiptData),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Icon(Icons.shopping_basket, color: Color(0xFF2C5C2D), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Analyse des produits',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C5C2D),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Liste des cartes produits
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                if (index >= uniqueProducts.length) return null;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildProductCard(uniqueProducts[index], context),
                );
              },
              childCount: uniqueProducts.length,
            ),
          ),
        ),

        // Conseil global
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 60),
            child: _buildGlobalAdvice(state.analysis['global_advice']),
          ),
        ),
      ],
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '—';
    try {
      final date = DateTime.parse(isoDate);
      // jour avec 2 chiffres / mois avec 2 chiffres / année
      final dd = date.day.toString().padLeft(2, '0');
      final mm = date.month.toString().padLeft(2, '0');
      return '$dd/$mm/${date.year}';
    } catch (_) {
      return '—';
    }
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
                  'Total spent',
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
                  'Products count',
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
    final healthRisks = product['health_risks'] is Map
        ? _formatHealthRisks(product['health_risks'])
        : (product['health_risks'] as List? ?? []);
    final healthBenefits = product['health_benefits'] as List? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9), // Fond doux
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.15), width: 1.2), // Bord noir léger
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(product),
            const SizedBox(height: 16),
            if (healthRisks.isNotEmpty) ...[
              _buildChipSection("Health Risks", healthRisks, Colors.red[50]!, Colors.red[700]!),
              const SizedBox(height: 12),
            ],
            if (healthBenefits.isNotEmpty) ...[
              _buildChipSection("Health Benefits", healthBenefits, Colors.green[50]!, Colors.green[700]!),
              const SizedBox(height: 12),
            ],
            _buildInfoTile(
              icon: Icons.lightbulb_outline_rounded,
              iconColor: const Color(0xFFFFC107),
              title: 'Advice',
              content: product['advice'] ?? 'No analysis available',
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              icon: Icons.thumb_up_rounded,
              iconColor: const Color(0xFF4CAF50),
              title: 'Recommendation',
              content: product['consumption_recommendation'] ?? 'Not specified',
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Colors.black12), // Ligne de séparation
            const SizedBox(height: 12),
            _buildCompareButton(context, product),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> product) {
    final processingLevel = product['processing_level'];
    final nutritionalQuality = product['nutritional_quality'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getProcessingColor(processingLevel).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            _getProcessingEmoji(processingLevel),
            style: const TextStyle(fontSize: 24),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product['product_name'] ?? 'Unknown product',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              // Remplacez la Row par un Wrap pour permettre le passage à la ligne
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (processingLevel != null)
                    _buildTag(
                      label: processingLevel,
                      color: _getProcessingColor(processingLevel),
                    ),
                  if (nutritionalQuality != null)
                    _buildTag(
                      label: 'Quality: $nutritionalQuality',
                      color: _getNutritionalQualityColor(nutritionalQuality),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTag({
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  Widget _buildChipSection(String title, List<dynamic> items, Color bgColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: items.map<Widget>((item) {
            return Chip(
              label: Text(item, style: const TextStyle(fontSize: 12)),
              backgroundColor: bgColor,
              labelStyle: TextStyle(color: textColor, fontWeight: FontWeight.w500),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              side: BorderSide.none,
            );
          }).toList(),
        ),
      ],
    );
  }
  Widget _buildCompareButton(BuildContext context, Map<String, dynamic> product) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showOtherStoresPrices(context, product),
        icon: const Icon(Icons.compare_arrows_rounded, size: 20, color: Color(0xFF1D7A29)),
        label: const Text(
          'Compare prices',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1D7A29),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF1D7A29), width: 1.8),
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          shadowColor: Colors.transparent,
        ),
      ),
    );
  }


  List<String> _formatHealthRisks(Map<String, dynamic>? healthRisks) {
    if (healthRisks == null) return [];

    final List<String> formattedRisks = [];

    if (healthRisks['sugar'] != null && healthRisks['sugar'] != 'none') {
      formattedRisks.add('Sugar: ${healthRisks['sugar']}');
    }

    if (healthRisks['salt'] != null && healthRisks['salt'] != 'none') {
      formattedRisks.add('Salt: ${healthRisks['salt']}');
    }

    if (healthRisks['fats'] != null) {
      final fats = healthRisks['fats'] as Map;
      if (fats['saturated'] != null && fats['saturated'] != 'none') {
        formattedRisks.add('Sat. fats: ${fats['saturated']}');
      }
      if (fats['trans'] != null && fats['trans'] != 'none') {
        formattedRisks.add('Trans fats: ${fats['trans']}');
      }
    }

    if (healthRisks['additives'] != null && healthRisks['additives'] != 'none') {
      formattedRisks.add('Additives: ${healthRisks['additives']}');
    }

    if (healthRisks['allergens'] != null && (healthRisks['allergens'] as List).isNotEmpty) {
      formattedRisks.add('Allergens: ${(healthRisks['allergens'] as List).join(', ')}');
    }

    return formattedRisks;
  }

  void _showOtherStoresPrices(
      BuildContext context, Map<String, dynamic> product) {
    final productName = product['product_name'];
    final currentPrice = product['price']?.toDouble() ?? 0.0;

    if (productName == null || productName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid product name')),
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
    final validComparisons = comparisons
        .where((c) => c['price'] != null)
        .toList()
      ..sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));

    if (validComparisons.isEmpty) {
      return _buildNoComparisonsSheet(context, productName);
    }

    final bestPrice = validComparisons.first;

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
            'Price comparison for $productName',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Best price found',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${bestPrice['store']} - ${bestPrice['price'].toStringAsFixed(2)} DT',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (bestPrice['date'] != null)
                        Text(
                          'Updated: ${bestPrice['date']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: validComparisons.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
              itemBuilder: (context, index) {
                final comparison = validComparisons[index];
                return ListTile(
                  leading: comparison['isBest'] == true
                      ? const Icon(Icons.star, color: Colors.green)
                      : const Icon(Icons.store, color: Colors.blue),
                  title: Text(comparison['store'] ?? 'Unknown store'),
                  trailing: Text(
                    '${comparison['price']?.toStringAsFixed(2)} DT',
                    style: TextStyle(
                      fontWeight: comparison['isBest'] == true
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: comparison['date'] != null
                      ? Text('${comparison['date']}')
                      : null,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              label: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E512E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24), // Coins plus arrondis
                ),
                elevation: 8,
                shadowColor: const Color(0x552C5C2D), // Ombre douce
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                animationDuration: const Duration(milliseconds: 100),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                surfaceTintColor: Colors.transparent,
              ),
            ),
          )
        ],
      ),
    );
  }
  Widget _buildNoComparisonsSheet(BuildContext context, String productName) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'No comparisons found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'No prices found for "$productName" in other stores',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Close'),
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

  Widget _buildGlobalAdvice(dynamic advice) {
    // Vérifier si l'objet est vide ou inutile
    if (advice == null ||
        (advice is String && advice.trim().isEmpty) ||
        (advice is Map &&
            (advice['positive_aspects'] == null || (advice['positive_aspects'] as List).isEmpty) &&
            (advice['main_concerns'] == null || (advice['main_concerns'] as List).isEmpty) &&
            (advice['improvement_suggestions'] == null || (advice['improvement_suggestions'] as List).isEmpty))) {
      // Retourne un container vide
      return const SizedBox.shrink();
    }

    String adviceText;

    if (advice is String) {
      adviceText = advice;
    } else if (advice is Map) {
      final positive = (advice['positive_aspects'] as List?)?.join('\n• ');
      final concerns = (advice['main_concerns'] as List?)?.join('\n• ');
      final suggestions = (advice['improvement_suggestions'] as List?)?.join('\n• ');

      adviceText = '''
${positive != null && positive.isNotEmpty ? '• $positive' : ''}

${concerns != null && concerns.isNotEmpty ? 'Main concerns:\n• $concerns' : ''}

${suggestions != null && suggestions.isNotEmpty ? 'Suggestions:\n• $suggestions' : ''}
'''.trim();
    } else {
      return const SizedBox.shrink(); // Type non reconnu
    }

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
                'Nutritional Advice',
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
            adviceText,
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
    switch (level?.toLowerCase()) {
      case 'natural':
        return const Color(0xFF4CAF50);
      case 'minimally-processed':
      case 'processed':
        return const Color(0xFFFFC107);
      case 'ultra-processed':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  Color _getNutritionalQualityColor(String? quality) {
    switch (quality?.toLowerCase()) {
      case 'excellent':
        return const Color(0xFF4CAF50);
      case 'good':
        return const Color(0xFF8BC34A);
      case 'moderate':
        return const Color(0xFFFFC107);
      case 'poor':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _getProcessingEmoji(String? level) {
    switch (level?.toLowerCase()) {
      case 'natural':
        return '🌿';
      case 'minimally-processed':
      case 'processed':
        return '⚙️';
      case 'ultra-processed':
        return '⚠️';
      default:
        return '❓';
    }
  }
}