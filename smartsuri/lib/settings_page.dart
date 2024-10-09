import 'package:flutter/material.dart';
import 'about_us.dart'; // For navigation to About App
import 'terms_conditions.dart'; // For navigation to Terms & Conditions
import 'privacy_policy.dart'; // For navigation to Privacy Policy
import 'main.dart'; // For redirection after logging out
import 'dart:typed_data';
import 'dart:convert'; // Import to use base64Decode
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html; // For handling file uploads in web
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'dart:io';

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

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  String _profileImageController = '';

  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

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
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.email, // Dynamic email
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30), // Space after the profile section

              // General Settings Section with Green Background
              _buildSectionHeader('General Settings'),
              _buildSettingsTile('Change Username', Icons.person, _showChangeUsernameDialog),
              _buildSettingsTile('Change Email', Icons.email, _showChangeEmailDialog),
              _buildSettingsTile('Change Profile Information', Icons.info, _showChangeProfileInfoDialog),
              _buildSettingsTile('Change Password', Icons.lock, _showChangePasswordDialog),

              const SizedBox(height: 15),

              // Information Section with Green Background
              _buildSectionHeader('Information'),
              _buildSettingsTile('About App', Icons.info_outline, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsPage()));
              }),
              _buildSettingsTile('Terms & Conditions', Icons.article_outlined, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsConditionsPage()));
              }),
              _buildSettingsTile('Privacy Policy', Icons.privacy_tip_outlined, () {
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
  Widget _buildSettingsTile(String title, IconData icon, Function onTap) {
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
      content: _buildCustomTextField('Enter new username', controller: _usernameController),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _changeUsername,
          child: const Text('Save'),
        ),
      ],
    );
  }

void _showChangeEmailDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Change Email'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildCustomTextField('Enter new email', controller: _emailController),
                    ),
                    const SizedBox(width: 10),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () => _sendOTP(setState),
                            style: _buttonStyle(),
                            child: const Text('Send OTP'),
                          ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildCustomTextField('Enter OTP', controller: _codeController),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => _changeEmail(setState),
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
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
          _buildCustomTextField('Current Password', controller: _currentPasswordController, isPassword: true),
          const SizedBox(height: 10),
          _buildCustomTextField('New Password', controller: _newPasswordController, isPassword: true),
          const SizedBox(height: 10),
          _buildCustomTextField('Confirm New Password', controller: _confirmNewPasswordController, isPassword: true),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _changePassword,
          child: const Text('Save'),
        ),
      ],
    );
  }

  // Common custom dialog builder
  void _showCustomDialog(BuildContext context, {required String title, required Widget content, List<Widget>? actions}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: content,
          actions: actions,
        );
      },
    );
  }

  // Create custom text field
  Widget _buildCustomTextField(String hint, {bool isPassword = false, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: hint,
      ),
    );
  }

 void _showChangeProfileInfoDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: const Text('Change Profile Information'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBirthdayField(setDialogState),
                const SizedBox(height: 10),
                _buildCityDropdown(setDialogState),
                const SizedBox(height: 10),
                _buildProfileImageSelector(setDialogState),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: _changeProfileInfo,
                      child: const Text('Save'),
                      
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildBirthdayField(StateSetter setDialogState) {
  return TextField(
    controller: _birthdayController,
    decoration: InputDecoration(
      border: const OutlineInputBorder(),
      hintText: 'Enter your birthday',
      suffixIcon: IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            setDialogState(() {
              _birthdayController.text = "${pickedDate.toLocal()}".split(' ')[0];
            });
          }
        },
      ),
    ),
  );
}

Widget _buildCityDropdown(StateSetter setDialogState) {
  return DropdownButtonFormField<String>(
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      hintText: 'Select your city',
    ),
    items: <String>[ 'Caloocan', 'Las Piñas', 'Makati', 'Malabon', 'Mandaluyong', 'Manila',
    'Marikina', 'Muntinlupa', 'Navotas', 'Parañaque', 'Pasay', 'Pasig',
    'Quezon City', 'San Juan', 'Taguig', 'Valenzuela'].map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList(),
    onChanged: (String? newValue) {
      setDialogState(() {
        _cityController.text = newValue ?? '';
      });
    },
  );
}

Widget _buildProfileImageSelector(StateSetter setDialogState) {
  return GestureDetector(
    onTap: () => _pickImageFromGallery(setDialogState),
    child: CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey[300],
      backgroundImage: _profileImageController.isNotEmpty 
          ? MemoryImage(base64Decode(_profileImageController)) as ImageProvider
          : null,
      child: _profileImageController.isEmpty
          ? Icon(Icons.add_a_photo, color: Colors.grey[600], size: 50)
          : null,
    ),
  );
}

Future<void> _pickImageFromGallery(StateSetter setDialogState) async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    if (foundation.kIsWeb) {
      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);
      setDialogState(() {
        _profileImageController = base64String;
      });
    } else {
      final bytes = await File(pickedFile.path).readAsBytes();
      final base64String = base64Encode(bytes);

      setDialogState(() {
        _profileImageController = base64String;
      });
    }
  }
}

  // Common button style
  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.green[900], // Green background
      foregroundColor: Colors.white, // White text color
    );
  }

// Change Password API Call
Future<void> _changePassword() async {
  final String currentPassword = _currentPasswordController.text;
  final String newPassword = _newPasswordController.text;
  final String confirmNewPassword = _confirmNewPasswordController.text;

  if (newPassword != confirmNewPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New passwords do not match')),
    );
    return;
  }

  final String apiUrl = dotenv.env['API_URL'] ?? ''; // Get API URL from env file

  if (apiUrl.isNotEmpty) {
    try {
      // Retrieve the access token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Access token not found')),
        );
        return;
      }

      final data = <String, String>{
        'oldPassword': currentPassword,
        'newPassword': newPassword,
      };

      final response = await http.put(
        Uri.parse('$apiUrl/crud/user/updatePassword'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully. Login Aagin.')),
        );
          // Set access_token to null in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const IndexPage()), // Redirect to login page
          (route) => false,
        );
      } 
      else if  (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Current password is incorrect')),
        );
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to change password with status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  } else {
    print('API URL not found');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API URL not found')),
    );
  }
}

// Change Username API Call
Future<void> _changeUsername() async {
  final String username = _usernameController.text;

  final String apiUrl = dotenv.env['API_URL'] ?? ''; // Get API URL from env file

  if (apiUrl.isNotEmpty) {
    try {
      // Retrieve the access token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Access token not found')),
        );
        return;
      }

      final data = <String, String>{
        'username': username,
      };

      final response = await http.put(
        Uri.parse('$apiUrl/crud/user/updateUsername'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username changed successfully. Login Again.')),
        );

            // Set access_token to null in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const IndexPage()), // Redirect to login page
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to change username with status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  } else {
    print('API URL not found');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API URL not found')),
    );
  }
}

 // Change Profile Information API Call
  Future<void> _changeProfileInfo() async {
    final String birthday = _birthdayController.text;
    final String city = _cityController.text;
    final String profileImage = _profileImageController;

    final String apiUrl = dotenv.env['API_URL'] ?? ''; // Get API URL from env file

    if (apiUrl.isNotEmpty) {
      try {
        // Retrieve the access token from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final String? accessToken = prefs.getString('access_token');

        if (accessToken == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Access token not found')),
          );
          return;
        }

        final data = <String, String>{
          'birthday': birthday,
          'city': city,
          'profileImage': profileImage,
        };

        final response = await http.put(
          Uri.parse('$apiUrl/crud/user/updateProfileInformation'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile information updated successfully. Login Again.')),
          );

              // Set access_token to null in SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('access_token');

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const IndexPage()), // Redirect to login page
              (route) => false,
            );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile information with status: ${response.statusCode}')),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    } else {
      print('API URL not found');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API URL not found')),
      );
    }
  }

  // Change Email API Call
  Future<void> _changeEmail(StateSetter setDialogState) async {
  final String email = _emailController.text;
  final String code = _codeController.text;

  final String apiUrl = dotenv.env['API_URL'] ?? ''; // Get API URL from env file

  if (apiUrl.isNotEmpty) {
    try {
      // Retrieve the access token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Access token not found')),
        );
        return;
      }

      final data = <String, String>{
        'email': email,
        'code': code,
      };

      final response = await http.put(
        Uri.parse('$apiUrl/crud/user/updateEmail'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email changed successfully. Login Again.')),
        );
            // Set access_token to null in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const IndexPage()), // Redirect to login page
          (route) => false,
        );
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to change email with status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  } else {
    print('API URL not found');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API URL not found')),
    );
  }
}

  // Send OTP API Call
  Future<void> _sendOTP(StateSetter setDialogState) async {
   setDialogState(() {
    _isLoading = true;
  });

    final String email = _emailController.text;
    final String apiUrl = dotenv.env['API_URL'] ?? ''; // Get API URL from env file

    if (apiUrl.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse('$apiUrl/crud/user/sendOTP'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': email,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send OTP with status: ${response.statusCode}')),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      } finally {
         setDialogState(() {
        _isLoading = false;
      });
      }
    } else {
      print('API URL not found');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API URL not found')),
      );
       setDialogState(() {
        _isLoading = false;
      });
    }
  }


}