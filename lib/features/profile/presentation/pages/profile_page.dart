import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../app_router.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';
  List<String> _selectedAllergies = ['Gluten'];
  late List<ProfileSection> profileSections;

  @override
  void initState() {
    super.initState();
    _initializeProfileSections();
  }

  void _initializeProfileSections() {
    profileSections = [
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
          content: Text('You can sign out anytime. Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.router.replace(const SignInRoute());
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Stack(
        children: [
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
                      'John Doe',
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: profileSections.length,
                          itemBuilder: (context, sectionIndex) {
                            final section = profileSections[sectionIndex];
                            return Column(
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
                                      ...section.items.map((item) {
                                        return Column(
                                          children: [
                                            ListTile(
                                              leading: Icon(
                                                item.icon,
                                                color: item.color,
                                              ),
                                              title: Text(item.title),
                                          subtitle: item.hasAllergyEditor ?? false
                                                  ? Text(
                                                _selectedAllergies.join(', '),
                                                style: TextStyle(color: Colors.grey[600]),
                                              )
                                                  : null,
                                              trailing: item.hasDropdown ?? false
                                                  ? DropdownButton<String>(
                                                value: _selectedLanguage,
                                                underline: Container(),
                                                items: ['English', 'French']
                                                    .map((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    _selectedLanguage = newValue!;
                                                  });
                                                },
                                              )
                                                  : item.hasToggle ?? false
                                                  ? Switch(
                                                value: _darkModeEnabled,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _darkModeEnabled = value;
                                                  });
                                                },
                                              )
                                                  : item.hasAllergyEditor ?? false
                                                  ? null
                                                  : Icon(
                                                Icons.arrow_forward_ios,
                                                size: 16,
                                                color: Colors.grey[400],
                                              ),
                                              onTap: item.onTap ?? (item.hasAllergyEditor ?? false
                                                  ? () => _showAllergySelectionDialog()
                                                  : null),
                                            ),
                                            if (item != section.items.last)
                                              Divider(height: 1, indent: 16),
                                          ],
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 24),
                        Text(
                          'App Version 1.0.0',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAllergySelectionDialog() {
    final commonAllergies = [
      'Gluten',
      'Lactose',
      'Nuts',
      'Shellfish',
      'Eggs',
      'Soy',
      'Fish',
      'Peanuts'
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Your Allergies'),
          content: SingleChildScrollView(
            child: Column(
              children: commonAllergies.map((allergy) {
                return CheckboxListTile(
                  title: Text(allergy),
                  value: _selectedAllergies.contains(allergy),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedAllergies.add(allergy);
                      } else {
                        _selectedAllergies.remove(allergy);
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
                Navigator.of(context).pop();
              },
              child: Text('SAVE'),
            ),
          ],
        );
      },
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