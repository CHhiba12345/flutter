import 'package:eye_volve/features/profile/data/datasources/profile_datasource.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../styles/constant.dart';

/// Classe déplacée en dehors du widget
class NavigationItem {
  final Widget icon;
  final String label;

  NavigationItem({required this.icon, required this.label});
}

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
        icon: FaIcon(FontAwesomeIcons.home),
        label: 'Home',
      ),
      NavigationItem(
        icon: FaIcon(FontAwesomeIcons.receipt),
        label: 'Receipt',
      ),
      NavigationItem(
        icon: FaIcon(FontAwesomeIcons.robot), // Chatbot
        label: 'Chatbot',
      ),
      NavigationItem(
        icon: FaIcon(FontAwesomeIcons.user),
        label: 'Profile',
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

  /// 🔁 Changement : on accepte un Widget au lieu d'IconData
  Widget _buildNavItem(
      BuildContext context, {
        required Widget icon,
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
            child: IconTheme(
              data: IconThemeData(
                size: isActive ? 29 : 24,
                color: isActive ? const Color(0xFF4E7A03) : Colors.black,
              ),
              child: icon,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: isActive ? const Color(0xFF4E7A03) : Colors.black,
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
