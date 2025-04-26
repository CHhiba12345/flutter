import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app_router.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../auth/presentation/blocs/auth_state.dart';
import '../bloc/profile_bloc.dart';
import '../../../../core/constants/app_colors.dart';

@RoutePage()
class AllergensPage extends StatefulWidget {
  const AllergensPage({Key? key}) : super(key: key);

  @override
  _AllergensPageState createState() => _AllergensPageState();
}

class _AllergensPageState extends State<AllergensPage> {
  final Map<String, bool> _selectedAllergens = {
    'Milk': false,
    'Fish': false,
    'Tree Nuts': false,
    'Peanuts': false,
    'Shellfish': false,
    'Crustacean Shellfish': false,
    'Molluscan Shellfish': false,
    'Wheat': false,
    'Eggs': false,
    'Soy': false,
    'Gluten': false,
    'Lactose': false,
  };

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserAllergens();
    });
  }

  void _loadUserAllergens() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      final uid = authState.user.uid;
      print('🔍 Chargement des allergènes pour UID: $uid');
      context.read<ProfileBloc>().add(LoadAllergens(uid));
    }
  }

  void _saveAllergens(BuildContext context) {
    setState(() {
      _isLoading = true;
    });

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) {
      print('❌ User not authenticated');
      return;
    }

    final selected = _selectedAllergens.entries
        .where((e) => e.value)
        .map((e) => e.key.toLowerCase())
        .toList();

    print('💾 Attempting to save allergens: $selected');

    context.read<ProfileBloc>().add(
      SetAllergens(
        allergens: selected,
        uid: authState.user.uid,
      ),
    );
  }

  void _updateAllergens(List<String> allergens) {
    setState(() {
      // Réinitialiser toutes les sélections
      for (var key in _selectedAllergens.keys) {
        _selectedAllergens[key] = false;
      }

      // Appliquer les allergènes de l'utilisateur
      for (var allergen in allergens) {
        final key = allergen.capitalize();
        if (_selectedAllergens.containsKey(key)) {
          _selectedAllergens[key] = true;
        }
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        print('🏗️ ProfileBloc state changed: $state');
        if (state is AllergensLoaded) {
          print('📦 Allergens loaded: ${state.allergens}');
          _updateAllergens(state.allergens);
        } else if (state is AllergensUpdated) {
          print('✅ Allergens updated successfully, navigating to Home');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.router.replaceAll([HomeRoute()]);
          });
        } else if (state is ProfileError) {
          print('❌ Error: ${state.message}');
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Food Allergens'),
          automaticallyImplyLeading: false, // Empêche le bouton retour
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select ingredients you are allergic to',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _selectedAllergens.length,
                  itemBuilder: (context, index) {
                    final allergen = _selectedAllergens.keys.elementAt(index);
                    final isSelected = _selectedAllergens[allergen]!;
                    return _buildAllergenItem(allergen, isSelected);
                  },
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : () => _saveAllergens(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.secondary,
                    strokeWidth: 2,
                  ),
                )

                    : Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.background, // place la couleur ici
                  ),
                )

              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllergenItem(String allergen, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedAllergens[allergen] = !isSelected),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.background,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIconForAllergen(allergen),
                size: 30,
                color: isSelected ? Colors.lightGreen : Colors.black,
              ),
              SizedBox(height: 5),
              Text(
                allergen,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary, // Couleur identique au texte du bouton
                ),
                textAlign: TextAlign.center,
              ),

            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForAllergen(String allergen) {
    const allergenIcons = {
      'Milk': Icons.local_drink,
      'Fish': Icons.abc,
      'Tree Nuts': Icons.nature_people,
      'Peanuts': Icons.food_bank,
      'Shellfish': Icons.beach_access,
      'Crustacean Shellfish': Icons.beach_access,
      'Molluscan Shellfish': Icons.beach_access,
      'Wheat': Icons.grain,
      'Eggs': Icons.egg,
      'Soy': Icons.lunch_dining,
      'Gluten': Icons.bakery_dining,
      'Lactose': Icons.local_drink,
    };
    return allergenIcons[allergen] ?? Icons.help_outline;
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return '';
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}