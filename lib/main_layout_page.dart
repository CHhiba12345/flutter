import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../../app_router.dart';
import 'features/home/presentation/widgets/home_bottom_nav.dart';


@RoutePage(name: 'MainLayoutRoute')
class MainLayoutPage extends StatelessWidget {
  const MainLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: [
        HomeRoute(),
        HistoryRoute(),
        ProfileRoute(),
        TicketRoute(),
        FavoritesRoute(),

      ],
      builder: (context, child) {
        final tabsRouter = context.tabsRouter; // Récupère le TabsRouter
        return Scaffold(
          body: child, // Affiche la page active
          bottomNavigationBar: HomeBottomNav(
            currentIndex: tabsRouter.activeIndex,
            onTap: (index) => tabsRouter.setActiveIndex(index),
          ),
        );
      },
    );
  }
}