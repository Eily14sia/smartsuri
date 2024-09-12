import 'package:flutter/material.dart';
import 'about_us.dart'; // For navigation to About App
import 'terms_conditions.dart'; // For navigation to Terms & Conditions
import 'privacy_policy.dart'; // For navigation to Privacy Policy
import 'main.dart'; // For redirection after logging out
import 'dart:typed_data';
import 'dart:convert'; // Import to use base64Decode

class SettingsPage extends StatefulWidget {
  final String profileImage;
  final String userName;
  final String email;

  const SettingsPage({
    super.key,
    required this.profileImage,
    required this.userName,
    required this.email,
  });

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedProfileImage = 'assets/profile2.png';
  Uint8List? _decodedImage;

  @override
  void initState() {
    super.initState();
    _decodeProfileImage();
  }

  void _decodeProfileImage() {
    if (widget.profileImage.isNotEmpty) {
      try {
        _decodedImage = base64Decode(widget.profileImage);
      } catch (e) {
        print('Error decoding Base64 image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding for overall layout
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thin Green Header with Back Button
              Stack(
                children: [
                  Container(
                    height: 40, // Match the height from profile page green section
                    color: Colors.green[100], // Green background
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.green[900]),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),

              // Profile Section with Spacing
              const SizedBox(height: 20), // Add space between header and profile
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: _decodedImage != null
                          ? MemoryImage(_decodedImage!)
                          : AssetImage(_selectedProfileImage) as ImageProvider, // Dynamic profile image
                      backgroundColor: Colors.green[200], // Placeholder background color
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.userName, // Dynamic user name
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.email, // Dynamic email
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30), // Space after the profile section

              // General Settings Section with Green Background
              _buildSectionHeader('General Settings'),
              _buildSettingsTile('Change Username', Icons.person, context, _showChangeUsernameDialog),
              _buildSettingsTile('Change Email', Icons.email, context, _showChangeEmailDialog),
              _buildSettingsTile('Change Profile Information', Icons.info, context, _showChangeProfileInfoDialog),
              _buildSettingsTile('Change Password', Icons.lock, context, _showChangePasswordDialog),

              const SizedBox(height: 15),

              // Information Section with Green Background
              _buildSectionHeader('Information'),
              _buildSettingsTile('About App', Icons.info_outline, context, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsPage()));
              }),
              _buildSettingsTile('Terms & Conditions', Icons.article_outlined, context, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsConditionsPage()));
              }),
              _buildSettingsTile('Privacy Policy', Icons.privacy_tip_outlined, context, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()));
              }),

              const SizedBox(height: 20),

              // Logout Button with "Browse More" Style
              Center(
                child: ElevatedButton(
                  onPressed: () => _showLogoutDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // White background
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(color: Colors.green[900]!, width: 2), // Green border
                    ),
                  ),
                  child: Text(
                    'LOG OUT',
                    style: TextStyle(
                      color: Colors.green[900], // Green text color
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            color: Colors.green[100], // Green background
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to build settings tiles
  Widget _buildSettingsTile(String title, IconData icon, BuildContext context, Function onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[900]), // Green icon color
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => onTap(),
    );
  }

  // Show Logout Confirmation Dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Do you want to log out of your account?'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: _buttonStyle(), // Close the pop-up
              child: const Text('No'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const IndexPage()), // Redirect to main page
                  (route) => false,
                );
              },
              style: _buttonStyle(),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  // Change Username Dialog
  void _showChangeUsernameDialog() {
    _showCustomDialog(
      context,
      title: 'Change Username',
      content: _buildCustomTextField('Enter new username'),
    );
  }

  // Change Email Dialog
  void _showChangeEmailDialog() {
    _showCustomDialog(
      context,
      title: 'Change Email',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCustomTextField('Enter new email'),
          const SizedBox(height: 20),
          _buildCustomTextField('Enter OTP'),
        ],
      ),
    );
  }

  // Change Profile Information Dialog
  void _showChangeProfileInfoDialog() {
    _showCustomDialog(
      context,
      title: 'Change Profile Information',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBirthdayField(),
          const SizedBox(height: 10),
          _buildCityDropdown(),
          const SizedBox(height: 10),
          _buildProfileImages(),
        ],
      ),
    );
  }

  // Change Password Dialog
  void _showChangePasswordDialog() {
    _showCustomDialog(
      context,
      title: 'Change Password',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCustomTextField('Current Password', isPassword: true),
          const SizedBox(height: 10),
          _buildCustomTextField('New Password', isPassword: true),
          const SizedBox(height: 10),
          _buildCustomTextField('Confirm New Password', isPassword: true),
        ],
      ),
    );
  }

  // Common custom dialog builder
  void _showCustomDialog(BuildContext context, {required String title, required Widget content}) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(color: Colors.green[900]!, width: 2), // Green border outline
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                const SizedBox(height: 20),
                content,
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: _buttonStyle(), // Green background with white text
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Create custom text field
  Widget _buildCustomTextField(String hint, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: hint,
      ),
    );
  }

  // Create birthday field
  Widget _buildBirthdayField() {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Enter your birthday',
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () {
            // Add date picker logic
          },
        ),
      ),
    );
  }

  // Create city dropdown
  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Select your city',
      ),
      items: <String>['City1', 'City2', 'City3'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        // Handle city selection
      },
    );
  }

  // Create profile images
  Widget _buildProfileImages() {
    return Wrap(
      spacing: 10,
      children: [
        _buildProfileImageOption('assets/profile1.png'),
        _buildProfileImageOption('assets/profile2.png'),
        _buildProfileImageOption('assets/profile3.png'),
      ],
    );
  }

  // Create profile image option
  Widget _buildProfileImageOption(String assetPath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProfileImage = assetPath;
        });
      },
      child: CircleAvatar(
        radius: 30,
        backgroundImage: AssetImage(assetPath),
      ),
    );
  }

  // Common button style
  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.green[900], // Green background
      foregroundColor: Colors.white, // White text color
    );
  }
}
