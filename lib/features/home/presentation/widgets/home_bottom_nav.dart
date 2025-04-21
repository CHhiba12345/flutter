import 'package:flutter/material.dart';
import '../../../../app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../pages/comp/navigation_item_class.dart';
import '../styles/constant.dart';


class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const HomeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<NavigationItem> items = [
      NavigationItem(
        icon: Icons.home_rounded,
        label: 'Accueil',
      ),
      NavigationItem(
        icon: Icons.history_rounded,
        label: 'Historique',
      ),
      NavigationItem(
        icon: Icons.person,
        label: 'Profil',
      ),
      NavigationItem(
        icon: Icons.receipt_long,
        label: 'Ticket',
      ),
    ];

    return Container(
      padding: AppConstants.defaultPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isActive = currentIndex == index;

          return _buildNavItem(
            context,
            icon: item.icon,
            label: item.label,
            isActive: isActive,
            onTap: () => onTap(index),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required bool isActive,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 26,
            color: isActive ? AppTheme.primaryDark : Colors.black,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppTheme.primaryDark : AppTheme.secondaryText,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

