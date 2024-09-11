import 'package:flutter/material.dart';
import 'about_us.dart'; // For navigation to About App
import 'terms_conditions.dart'; // For navigation to Terms & Conditions
import 'privacy_policy.dart'; // For navigation to Privacy Policy
import 'main.dart'; // For redirection after logging out

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedProfileImage = 'assets/profile2.png';

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
                      backgroundImage: AssetImage(_selectedProfileImage), // Dynamic profile image
                      backgroundColor: Colors.green[200], // Placeholder background color
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Name', // Dynamic user name
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'email@example.com', // Dynamic or sample email
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                const SizedBox(height: 20),
                content,
                const SizedBox(height: 20),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: _buttonStyle(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Handle the update logic here
                      },
                      style: _buttonStyle(),
                      child: const Text('Update'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Profile Images Picker
  Widget _buildProfileImages() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildProfileImageChoice('assets/profile1.png'),
        _buildProfileImageChoice('assets/profile2.png'),
        _buildProfileImageChoice('assets/profile3.png'),
        _buildProfileImageChoice('assets/profile4.png'),
        _buildProfileImageChoice('assets/ayaw.png'),
      ],
    );
  }

  Widget _buildProfileImageChoice(String imagePath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProfileImage = imagePath;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle, // Make the image circular
          border: _selectedProfileImage == imagePath
              ? Border.all(color: Colors.green[900]!, width: 2) // Add green border when selected
              : null,
        ),
        child: CircleAvatar(
          radius: 25, // Adjust radius as needed
          backgroundImage: AssetImage(imagePath),
        ),
      ),
    );
  }

  // City Dropdown Field
  Widget _buildCityDropdown() {
    final List<String> cities = [
      'Caloocan', 'Las Piñas', 'Makati', 'Malabon', 'Mandaluyong',
      'Manila', 'Marikina', 'Muntinlupa', 'Navotas', 'Parañaque',
      'Pasay', 'Pasig', 'Quezon City', 'San Juan', 'Taguig', 'Valenzuela'
    ];
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.green[50], // Match the filled background from the other text fields
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none, // No outline for consistency
        ),
        labelText: 'City',
        labelStyle: TextStyle(color: Colors.green[700]!),
      ),
      items: cities.map((String city) {
        return DropdownMenuItem<String>(
          value: city,
          child: Text(city),
        );
      }).toList(),
      onChanged: (String? newValue) {},
    );
  }

  // Birthday Field
  // Update the _buildBirthdayField method to include the validation check
Widget _buildBirthdayField() {
  TextEditingController birthdayController = TextEditingController();
  return TextField(
    controller: birthdayController,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.green[50], // Match the filled background
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide.none, // No outline for consistency
      ),
      labelText: 'Birthday',
      suffixIcon: Icon(Icons.calendar_today, color: Colors.green[700]!),
      labelStyle: TextStyle(color: Colors.green[700]!),
    ),
    readOnly: true,
    onTap: () async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );
      int age = DateTime.now().year - pickedDate!.year;
      if (age < 13) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You must be at least 13 years old.")));
      } else {
        birthdayController.text = '${pickedDate.year}-${pickedDate.month}-${pickedDate.day}';
      }
        },
  );
}

bool _isPasswordHidden = true;

  // Custom TextField Builder
 // Update the _buildCustomTextField method to include password toggle
Widget _buildCustomTextField(String hintText, {bool isPassword = false}) {
  return TextField(
    obscureText: isPassword && _isPasswordHidden, // Toggle based on visibility
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.green[50], // Match the filled background
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide.none, // No outline for consistency
      ),
      labelText: hintText,
      labelStyle: TextStyle(color: Colors.green[700]!),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                color: Colors.green[700]!, // Green eye icon color
              ),
              onPressed: () {
                setState(() {
                  _isPasswordHidden = !_isPasswordHidden; // Toggle the state
                });
              },
            )
          : null, // Show eye icon only for password fields
    ),
  );
}

  // Button Style
ButtonStyle _buttonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: Colors.white, // White background
    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
      side: BorderSide(color: Colors.green[900]!, width: 2), // Green border
    ),
    textStyle: TextStyle(
      color: Colors.green[900], // Set green font color
    ),
  );
}

}
