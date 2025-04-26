import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app_router.dart';
import '../../../auth/data/datasources/auth_service.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../auth/presentation/blocs/auth_event.dart';
import '../../../auth/presentation/blocs/auth_state.dart';
import '../bloc/profile_bloc.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';
  List<String> _selectedAllergies = [];
  List<ProfileSection> profileSections = [];

  @override
  void initState() {
    super.initState();
    profileSections = _initializeProfileSections();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileBloc>().add(InitializeAllergens());
    });
  }

  List<ProfileSection> _initializeProfileSections() {
    return [
      ProfileSection(
        title: 'APP PREFERENCES',
        items: [
          ProfileItem(
            title: 'Language',
            icon: Icons.language_outlined,
            color: Colors.blue,
            hasDropdown: true,
          ),
          ProfileItem(
            title: 'Dark Mode',
            icon: Icons.dark_mode_outlined,
            color: Colors.indigo,
            hasToggle: true,
          ),
        ],
      ),
      ProfileSection(
        title: 'HEALTH',
        items: [
          ProfileItem(
            title: 'My Allergies',
            icon: Icons.health_and_safety,
            color: Colors.red,
            hasAllergyEditor: true,
          ),
        ],
      ),
      // Autres sections...

      ProfileSection(
        title: 'SUPPORT',
        items: [
          ProfileItem(
            title: 'FAQs',
            icon: Icons.help_outline,
            color: Colors.teal,
          ),
          ProfileItem(
            title: 'Feedback',
            icon: Icons.feedback_outlined,
            color: Colors.orange,
          ),
          ProfileItem(
            title: 'Rate Us',
            icon: Icons.star_border,
            color: Colors.amber,
          ),
          ProfileItem(
            title: 'Share App',
            icon: Icons.share,
            color: Colors.green,
          ),
        ],
      ),
      ProfileSection(
        title: 'LEGAL',
        items: [
          ProfileItem(
            title: 'Privacy Policy',
            icon: Icons.lock_outline,
            color: Colors.purple,
          ),
          ProfileItem(
            title: 'Premium Terms',
            icon: Icons.check_circle_outline,
            color: Colors.deepPurple,
          ),
        ],
      ),
      ProfileSection(
        title: 'ACCOUNT',
        items: [
          ProfileItem(
            title: 'Sign Out',
            icon: Icons.exit_to_app,
            color: Colors.red,
            onTap: _handleSignOut,
          ),
          ProfileItem(
            title: 'Delete Account',
            icon: Icons.delete,
            color: Colors.red[300]!,
          ),
        ],
      ),
    ];
  }

  void _handleSignOut() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(SignOutEvent());
                context.router.replaceAll([const SignInRoute()]);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showAllergySelectionDialog(BuildContext context) {
    final commonAllergies = [
      'Milk', 'Fish', 'Tree Nuts', 'Peanuts', 'Shellfish',
      'Crustacean Shellfish', 'Molluscan Shellfish', 'Wheat',
      'Eggs', 'Soy', 'Gluten', 'Lactose'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            List<String> tempAllergies = [];
            if (state is AllergensLoaded) {
              tempAllergies = state.allergens.map((e) => e.capitalize()).toList();
              print('✅ Allergènes chargés dans la boîte de dialogue : $tempAllergies');
            } else {
              tempAllergies = List.from(_selectedAllergies);
              print('ℹ️ Utilisation des allergènes sélectionnés précédemment : $tempAllergies');
            }

            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text('Select Your Allergies'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: commonAllergies.map((allergy) {
                        return CheckboxListTile(
                          title: Text(allergy),
                          value: tempAllergies.contains(allergy),
                          onChanged: (selected) {
                            setState(() {
                              if (selected == true) {
                                tempAllergies.add(allergy);
                                print('➕ Allergène ajouté : $allergy');
                              } else {
                                tempAllergies.remove(allergy);
                                print('➖ Allergène retiré : $allergy');
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        print('❌ Sélection annulée');
                        Navigator.pop(context);
                      },
                      child: Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final authService = AuthService();
                        final uid = await authService.getCurrentUserId();
                        if (uid != null) {
                          context.read<ProfileBloc>().add(
                            SetAllergens(
                              uid: uid,
                              allergens: tempAllergies.map((a) => a.toLowerCase()).toList(),
                            ),
                          );
                          print('📤 Envoi des allergènes sélectionnés : $tempAllergies');
                          // Recharge immédiatement les allergènes
                          context.read<ProfileBloc>().add(LoadAllergens(uid));
                          setState(() {
                            _selectedAllergies = tempAllergies;
                            print('📌 Mise à jour locale des allergènes : $_selectedAllergies');
                          });
                        } else {
                          print('⚠️ UID introuvable, impossible d\'enregistrer');
                        }
                        Navigator.pop(context);
                        print('✅ Boîte de dialogue fermée après sauvegarde');
                      },
                      child: Text('SAVE'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );

  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is AllergensLoaded) {
              setState(() {
                _selectedAllergies = state.allergens.map((e) => e.capitalize()).toList();
                print('🎯 Allergènes chargés depuis ProfileBloc: $_selectedAllergies');
              });
            }
          },
        ),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              height: statusBarHeight + 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3E6839), Color(0xFF83BC6D)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(height: statusBarHeight),
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        child: Icon(Icons.person),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'User Name',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, state) {
                        if (state is ProfileLoading) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (state is ProfileError) {
                          return Center(child: Text(state.message));
                        }
                        return _buildProfileContent(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ...profileSections.map((section) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  section.title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ...section.items.map((item) => Column(
                      children: [
                        ListTile(
                          leading: Icon(item.icon, color: item.color),
                          title: Text(item.title),
                          subtitle: item.hasAllergyEditor ?? false
                              ? Text(
                            _selectedAllergies.isEmpty
                                ? 'No allergies selected'
                                : _selectedAllergies.join(', '),
                            style: TextStyle(color: Colors.grey[600]),
                          )
                              : null,
                          trailing: _buildTrailingWidget(item),
                          onTap: item.onTap ?? (item.hasAllergyEditor ?? false
                              ? () => _showAllergySelectionDialog(context)
                              : null),
                        ),
                        if (item != section.items.last)
                          Divider(height: 1, indent: 16),
                      ],
                    )),
                  ],
                ),
              ),
            ],
          )),
          SizedBox(height: 24),
          Text(
            'App Version 1.0.0',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTrailingWidget(ProfileItem item) {
    if (item.hasDropdown ?? false) {
      return IgnorePointer(
        child: DropdownButton<String>(
          value: _selectedLanguage,
          underline: Container(),
          items: ['English', 'French'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) => setState(() => _selectedLanguage = newValue!),
        ),
      );
    } else if (item.hasToggle ?? false) {
      return Switch(
        value: _darkModeEnabled,
        onChanged: (value) => setState(() => _darkModeEnabled = value),
      );
    }
    return const Icon(
      Icons.arrow_forward_ios,
      size: 16,
      color: Colors.grey,
    );
  }
}
class ProfileSection {
  final String title;
  final List<ProfileItem> items;

  ProfileSection({required this.title, required this.items});
}

class ProfileItem {
  final String title;
  final IconData icon;
  final Color color;
  final bool? hasDropdown;
  final bool? hasToggle;
  final bool? hasAllergyEditor;
  final VoidCallback? onTap;

  ProfileItem({
    required this.title,
    required this.icon,
    required this.color,
    this.hasDropdown = false,
    this.hasToggle = false,
    this.hasAllergyEditor = false,
    this.onTap,
  });
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return '';
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}