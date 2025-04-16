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
      backgroundColor: Colors.transparent, // Fond transparent
      elevation: 0, // Pas d'ombre
      title: HomeStyles.appTitle(context), // Titre de l'application avec dégradé
      actions: [
        // Icône de scan
        IconButton(
          icon: HomeStyles.cameraIcon, // Icône de la caméra
          onPressed: () async {
            // Action de scan
            final barcode = await BarcodeScanner.scan();
            if (barcode.rawContent.isNotEmpty) {
              // Envoyer l'événement de scan au Bloc
              context.read<HomeBloc>().add(ScanProductEvent(barcode: barcode.rawContent));
            }
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60), // Hauteur de la barre de recherche
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: HomeStyles.searchInputDecoration(context), // Style de la barre de recherche
            onChanged: (query) {
              // Envoyer l'événement de recherche au Bloc
              context.read<HomeBloc>().add(SearchProductsEvent(query: query));
            },
            style: HomeStyles.searchTextStyle(context), // Style du texte de recherche
          ),
        ),
      ),
    );
  }




  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 60); // Hauteur totale de l'AppBar
}