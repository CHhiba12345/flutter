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
import 'edit_profile_page.dart';
import 'FAQ_page.dart'; // Importez la page FAQ
import 'feedback_page.dart';
import 'about_us_page.dart';
import 'privacy_policy_page.dart';
import 'premium_term_page.dart';
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
        title: 'HEALTH',
        items: [
          ProfileItem(title: 'My Allergies', icon: Icons.health_and_safety, color: Colors.red, hasAllergyEditor: true),
        ],
      ),
      ProfileSection(
        title: 'APP PREFERENCES',
        items: [
          ProfileItem(title: 'Language', icon: Icons.language_outlined, color: Colors.blue, hasDropdown: true),
          ProfileItem(
            title: 'Dark Mode',
            icon: Icons.dark_mode_outlined,
            color: Colors.indigo,
            hasToggle: true,
          ),
        ],
      ),
      ProfileSection(
        title: 'SUPPORT',
        items: [
          ProfileItem(
            title: 'FAQs',
            icon: Icons.help_outline,
            color: Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FAQPage()),
              );
            },
          ),
          ProfileItem(title: 'Feedback', icon: Icons.feedback_outlined, color: Colors.orange, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FeedbackPage()),
            );
          }),
          ProfileItem(title: 'About Us', icon: Icons.info_outline_rounded, color: Colors.amber, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutUsPage()),
            );
          }),
          ProfileItem(title: 'Share App', icon: Icons.share, color: Colors.green),
        ],
      ),
      ProfileSection(
        title: 'LEGAL',
        items: [
          ProfileItem(title: 'Privacy Policy', icon: Icons.lock_outline, color: Colors.purple, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
            );
          }),
          ProfileItem(title: 'Premium Terms', icon: Icons.check_circle_outline, color: Colors.deepPurple, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PremiumTermsPage()),
            );
          }),
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
      'Milk',
      'Lactose',
      'Eggs',
      'Fish',
      'Crustacean Shellfish',
      'Molluscan Shellfish',
      'Shellfish',
      'Tree Nuts',
      'Peanuts',
      'Soy',
      'Wheat',
      'Gluten',
      'Mustard',
      'Sesame Seeds',
      'Celery',
      'Sulphur Dioxide',
      'Sulfites',
      'Lupin',
      'None',
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
    final theme = Theme.of(context);
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
        backgroundColor: theme.colorScheme.background,
        body: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2C5C2D), Color(0xFF5A9E5D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: pickImage,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  backgroundImage: _profileImage != null
                                      ? FileImage(_profileImage!)
                                      : null,
                                  child: _profileImage == null
                                      ? Icon(Icons.person, size: 50, color: Colors.white)
                                      : null,
                                ),

                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Text(
                              '${_firstNameController.text} ${_lastNameController.text}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 2),
                          OutlinedButton(
                            onPressed: () => _navigateToEditProfile(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            child: Text('Edit Profile'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final section = profileSections[index];
                  return _buildProfileSection(context, section);
                },
                childCount: profileSections.length,
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 22),
                child: Center(

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, ProfileSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(
            section.title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...section.items.map((item) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: 60,
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, color: item.color, size: 20),
                      ),
                      title: Text(
                        item.title,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      subtitle: item.hasAllergyEditor ?? false
                          ? Text(
                        _selectedAllergies.isEmpty
                            ? 'No allergies selected'
                            : _selectedAllergies.join(', '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      )
                          : null,
                      trailing: _buildTrailingWidget(item),
                      onTap: item.onTap ??
                          (item.hasAllergyEditor ?? false
                              ? () => _showAllergySelectionDialog(context)
                              : null),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      minVerticalPadding: 12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  if (item != section.items.last)
                    Divider(height: 1, indent: 72),
                ],
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrailingWidget(ProfileItem item) {
    if (item.hasDropdown ?? false) {
      return DropdownButton<String>(
        value: _selectedLanguage,
        underline: Container(),
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
        items: ['English', 'French'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) => setState(() => _selectedLanguage = newValue!),
      );
    } else if (item.hasToggle ?? false) {
      return Switch.adaptive(
        value: _darkModeEnabled,
        onChanged: (value) => setState(() => _darkModeEnabled = value),
      );
    }
    return Icon(Icons.chevron_right, color: Colors.grey);
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