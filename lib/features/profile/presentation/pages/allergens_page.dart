import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    'None': false,
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
    'Mustard': false,          // Ajouté
    'Sesame Seeds': false,     // Ajouté
    'Celery': false,           // Ajouté
    'Sulphur Dioxide': false,  // Ajouté
    'Sulfites': false,         // Ajouté
    'Lupin': false,
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
      for (var key in _selectedAllergens.keys) {
        _selectedAllergens[key] = false;
      }
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
        backgroundColor: AppColors.secondary, // 👈 Fond de la page en blanc
        appBar: AppBar(
          centerTitle: true, // ✅ centrer le titre
          title: Text(
            'Food Allergens',
            style: TextStyle(
              color: Colors.white,     // ✅ texte blanc
              fontWeight: FontWeight.bold, // ✅ texte en gras
            ),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.secondary,
          iconTheme: IconThemeData(color: Colors.white),
        ),



        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Select ingredients you are allergic to',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.background,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.background,
                        strokeWidth: 5,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Loading your allergens...',
                        style: TextStyle(
                          color: AppColors.background,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
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
                  backgroundColor: AppColors.background,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  shadowColor: Colors.black26,
                ),
                child: _isLoading
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.secondary,
                        strokeWidth: 3,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Saving...',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                )
                    : Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
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
          color: isSelected ? Colors.green.withOpacity(0.1) : Colors.transparent,
        ),
        child: CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.background,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: Duration(milliseconds: 200),
                scale: isSelected ? 1.2 : 1.0,
                child: Text(
                  getIconForAllergen(allergen),
                  style: TextStyle(
                    fontSize: 30,
                    color: isSelected ? Colors.green : Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                allergen,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.green : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getIconForAllergen(String allergen) {
    final Map<String, String> allergenEmojis = {
      'None': '❌',
      'Milk': '🥛',
      'Lactose': '🥛',
      'Fish': '🐟',
      'Tree Nuts': '🌰',
      'Peanuts': '🥜',
      'Shellfish': '🦐',
      'Crustacean Shellfish': '🦀',
      'Molluscan Shellfish': '🦪',
      'Wheat': '🌾',
      'Gluten': '🌾',
      'Eggs': '🥚',
      'Soy': '🫘',
      'Mustard': '🌿',
      'Sesame Seeds': '⚪',
      'Celery': '🥬',
      'Sulphur Dioxide': '☁️',
      'Sulfites': '☁️',
      'Lupin': '🌱',
    };
    return allergenEmojis[allergen] ?? '❓';
  }

  }

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return '';
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
