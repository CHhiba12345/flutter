import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../../../app_router.dart';
import '../../../auth/data/datasources/auth_service.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../auth/presentation/blocs/auth_event.dart';
import '../bloc/profile_bloc.dart';
import 'edit_profile_page.dart'; // Importez la nouvelle page

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

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  final picker = ImagePicker();
  File? _profileImage;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<ProfileBloc>().add(InitializeAllergens());
      await loadUserData();
      await _loadLocalImage();
    });

    profileSections = _initializeProfileSections();
  }

  Future<void> loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        final nameParts = (user.displayName ?? 'User Name').split(' ');

        if (nameParts.length >= 2) {
          _firstNameController.text = nameParts[0];
          _lastNameController.text = nameParts.sublist(1).join(' ');
        } else if (user.email != null) {
          final emailPart = user.email!.split('@').first.capitalize();
          _firstNameController.text = emailPart;
          _lastNameController.text = '';
        }
      });
    }
  }

  Future<void> _loadLocalImage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final imageFile = File('${directory.path}/profile_image_$uid.jpg');

      if (await imageFile.exists()) {
        setState(() {
          _profileImage = imageFile;
          _localImagePath = imageFile.path;
        });
      }
    } catch (e) {
      print('Error loading local image: $e');
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final uid = FirebaseAuth.instance.currentUser?.uid ?? 'default';
        final imageFile = File('${directory.path}/profile_image_$uid.jpg');

        if (await imageFile.exists()) {
          await imageFile.delete();
        }

        final bytes = await File(pickedFile.path).readAsBytes();
        await imageFile.writeAsBytes(bytes);

        setState(() {
          _profileImage = imageFile;
          _localImagePath = imageFile.path;
        });

        imageCache.clear();
        imageCache.clearLiveImages();
      } catch (e) {
        print('Error saving image locally: $e');
      }
    }
  }

  List<ProfileSection> _initializeProfileSections() {
    return [
      ProfileSection(
        title: 'PROFILE',
        items: [
          ProfileItem(
            title: 'Edit Profile',
            icon: Icons.edit,
            color: Colors.blue,
            onTap: () => _navigateToEditProfile(context),
          ),
        ],
      ),
      ProfileSection(
        title: 'APP PREFERENCES',
        items: [
          ProfileItem(title: 'Language', icon: Icons.language_outlined, color: Colors.blue, hasDropdown: true),
        ],
      ),
      ProfileSection(
        title: 'HEALTH',
        items: [
          ProfileItem(title: 'My Allergies', icon: Icons.health_and_safety, color: Colors.red, hasAllergyEditor: true),
        ],
      ),
      ProfileSection(
        title: 'SUPPORT',
        items: [
          ProfileItem(title: 'FAQs', icon: Icons.help_outline, color: Colors.teal),
          ProfileItem(title: 'Feedback', icon: Icons.feedback_outlined, color: Colors.orange),
          ProfileItem(title: 'Rate Us', icon: Icons.star_border, color: Colors.amber),
          ProfileItem(title: 'Share App', icon: Icons.share, color: Colors.green),
        ],
      ),
      ProfileSection(
        title: 'LEGAL',
        items: [
          ProfileItem(title: 'Privacy Policy', icon: Icons.lock_outline, color: Colors.purple),
          ProfileItem(title: 'Premium Terms', icon: Icons.check_circle_outline, color: Colors.deepPurple),
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

  Future<void> _navigateToEditProfile(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          profileImage: _profileImage,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _firstNameController.text = result['firstName'] ?? _firstNameController.text;
        _lastNameController.text = result['lastName'] ?? _lastNameController.text;
        if (result['imagePath'] != null) {
          _profileImage = File(result['imagePath']);
          _localImagePath = result['imagePath'];
        }
      });
      await loadUserData();
    }
  }

  void _handleSignOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Sign Out"),
        content: Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(onPressed: Navigator.of(context).pop, child: Text("No")),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(SignOutEvent());
              context.router.replaceAll([const SignInRoute()]);
            },
            child: Text("Yes"),
          ),
        ],
      ),
    );
  }

  void _showAllergySelectionDialog(BuildContext context) {
    List<String> commonAllergies = [
      'Milk', 'Fish', 'Tree Nuts', 'Peanuts', 'Shellfish',
      'Crustacean Shellfish', 'Molluscan Shellfish', 'Wheat',
      'Eggs', 'Soy', 'Gluten', 'Lactose'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            List<String> tempAllergies = state is AllergensLoaded
                ? state.allergens.map((e) => e.capitalize()).toList()
                : List.from(_selectedAllergies);

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
                              selected == true
                                  ? tempAllergies.add(allergy)
                                  : tempAllergies.remove(allergy);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final uid = await AuthService().getCurrentUserId();
                        if (uid != null) {
                          context.read<ProfileBloc>().add(
                            SetAllergens(
                              uid: uid,
                              allergens: tempAllergies.map((a) => a.toLowerCase()).toList(),
                            ),
                          );
                          context.read<ProfileBloc>().add(LoadAllergens(uid));
                          setState(() => _selectedAllergies = tempAllergies);
                        }
                        Navigator.pop(context);
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
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
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
                      GestureDetector(
                        onTap: pickImage,
                        child: CircleAvatar(
                          key: ValueKey(_localImagePath),
                          radius: 30,
                          backgroundColor: Colors.white.withOpacity(0.4),
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? Icon(Icons.person, size: 35, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _firstNameController.text,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_lastNameController.text.isNotEmpty)
                              Text(
                                _lastNameController.text,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                          ],
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
                          onTap: item.onTap ??
                              (item.hasAllergyEditor ?? false
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
    return const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey);
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
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}