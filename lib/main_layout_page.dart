import 'package:auto_route/annotations.dart';
import 'package:eye_volve/features/home/presentation/widgets/home_bottom_nav.dart';
import 'package:eye_volve/features/ticket/presentation/pages/ticket_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'features/chatbot/presentation/pages/chatbot_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';

@RoutePage(name: 'MainLayoutRoute')
class MainLayoutPage extends StatefulWidget {
  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayoutPage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(), // Disable swipe
        children: [
          HomePage(),
          TicketPage(),
          ChatbotPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
// Additional logic when tab changes
        },
      ),
    );
  }
}
