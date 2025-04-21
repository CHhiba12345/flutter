import 'package:barcode_scan2/gen/protos/protos.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import '../bloc/home_bloc.dart';
import '../styles/home_styles.dart';
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade400],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
      title: HomeStyles.appTitle(context),
      actions: [
        IconButton(
          icon: HomeStyles.cameraIcon,
          onPressed: () async {
            final barcode = await BarcodeScanner.scan();
            if (barcode.rawContent.isNotEmpty) {
              context.read<HomeBloc>().add(ScanProductEvent(barcode: barcode.rawContent));
            }
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: HomeStyles.searchInputDecoration(context),
            onChanged: (query) {
              context.read<HomeBloc>().add(SearchProductsEvent(query: query));
            },
            style: HomeStyles.searchTextStyle(context),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 60);
}