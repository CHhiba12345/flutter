import 'package:flutter/material.dart';
import '../../../home/presentation/styles/constant.dart';
import '../../../home/presentation/styles/th.dart';

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    super.key,
    required this.currentIndex,
    this.onHomePressed,
    this.onHistoryPressed,
    this.onFavoritesPressed,
    this.onScanPressed,
  });

  final int currentIndex; // Indice pour savoir quelle page est active
  final VoidCallback? onHomePressed;
  final VoidCallback? onHistoryPressed;
  final VoidCallback? onFavoritesPressed;
  final VoidCallback? onScanPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppConstants.defaultPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_rounded,
            label: 'Accueil',
            isActive: currentIndex == 0,
            onTap: onHomePressed,
          ),
          _buildNavItem(
            icon: Icons.history_rounded,
            label: 'Historique',
            isActive: currentIndex == 1,
            onTap: onHistoryPressed,
          ),
          _buildNavItem(
            icon: Icons.favorite_border_rounded,
            label: 'Favoris',
            isActive: currentIndex == 2,
            onTap: onFavoritesPressed,
          ),
          _buildNavItem(
            icon: Icons.article_sharp,
            label: 'Scan',
            isActive: currentIndex == 3,
            onTap: onScanPressed,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? AppTheme.primaryDark : AppTheme.secondaryText),
          Text(
            label,
            style: TextStyle(color: isActive ? AppTheme.primaryDark : AppTheme.secondaryText),
          ),
        ],
      ),
    );
  }
}
