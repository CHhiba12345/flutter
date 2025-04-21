import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

@RoutePage()
class TicketPage extends StatefulWidget {
  @override
  _TicketPageState createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  // Méthode pour ouvrir la caméra pour scanner le ticket
  Future<void> _scanTicket() async {
    print("Opening camera to scan ticket...");
    // Ici, vous pouvez utiliser une bibliothèque comme "flutter_barcode_scanner" pour scanner le ticket
  }

  // Méthode pour importer une image existante
  Future<void> _importImage() async {
    print("Importing existing image...");
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      print("Image selected: ${pickedFile.path}");
      // Traitez l'image ici (par exemple, analysez le QR code)
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Stack(
        children: [
          // Fond avec dégradé
          Container(
            height: statusBarHeight + 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF13729A),
                  Color(0xFF7FD3F8),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),

          // Contenu principal
          Column(
            children: [
              SizedBox(height: statusBarHeight),

              // Barre personnalisée
              Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Icône de ticket ou QR code
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.qr_code_scanner,
                        size: 24,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Titre de la page
                    Text(
                      'Scan Your Ticket',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Espacement entre la barre et le contenu principal
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Texte d'accueil
                      Text(
                        'Hi, you can scan your ticket to get information about your achat, discover the best prices, and get points for the first 5 scans.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 40),

                      // Icône centrale représentant un ticket ou un QR code
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 80,
                          color: Colors.blueAccent,
                        ),
                      ),

                      SizedBox(height: 40),

                      // Bouton 1 : Scanner le ticket
                      ElevatedButton(
                        onPressed: _scanTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Scan Ticket',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Bouton 2 : Importer une image existante
                      ElevatedButton(
                        onPressed: _importImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Import Existing Image',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension on ImagePicker {
  getImage({required ImageSource source}) {}
}
