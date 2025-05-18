import 'package:eye_volve/features/profile/data/datasources/profile_datasource.dart';
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
        icon: Icons.mark_chat_read_rounded,
        label: 'Chatbot',
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Icon(
              icon,
              size: isActive ? 29 : 24, // Agrandir si actif
              color: isActive ? Color(0xFF4E7A03) : Colors.black,

            ),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: isActive ? Color(0xFF4E7A03) : Colors.black,


              fontSize: isActive ? 13 : 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}