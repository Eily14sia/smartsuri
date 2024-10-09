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

 // Change Email Dialog
void _showChangeEmailDialog() {
  _showCustomDialog(
    context,
    title: 'Change Email',
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
                    onPressed: _sendOTP,
                    style: _buttonStyle(), // Green background with white text
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
        onPressed: _changeEmail,
        child: const Text('Save'),
      ),
    ],
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

  // Create birthday field
  Widget _buildBirthdayField() {
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
              setState(() {
                _birthdayController.text = "${pickedDate.toLocal()}".split(' ')[0];
              });
            }
          },
        ),
      ),
    );
  }

  // Create city dropdown
  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
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
        setState(() {
          _cityController.text = newValue ?? '';
        });
      },
    );
  }

  // Create profile images
  Widget _buildProfileImages() {
    return Column(
      children: [
        Text('Profile Image'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () async {
                if (kIsWeb) {
                  // Handle file upload for web
                  html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
                  uploadInput.accept = 'image/*';
                  uploadInput.click();

                  uploadInput.onChange.listen((e) {
                    final files = uploadInput.files;
                    if (files!.isNotEmpty) {
                      final reader = html.FileReader();
                      reader.readAsDataUrl(files[0]);
                      reader.onLoadEnd.listen((e) {
                        setState(() {
                          _selectedProfileImage = reader.result as String;
                        });
                      });
                    }
                  });
                } else {
                  // Handle file upload for mobile
                  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    final bytes = await pickedFile.readAsBytes();
                    setState(() {
                      _selectedProfileImage = base64Encode(bytes);
                    });
                  }
                }
              },
              child: Container(
                width: 50,
                height: 50,
                color: _selectedProfileImage != null ? Colors.blue : Colors.grey,
                child: Center(
                  child: _selectedProfileImage != null
                      ? Icon(Icons.check, color: Colors.white)
                      : Text('Upload'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
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

      // Print the data being sent to the API
      print('Sending data to updatePassword API: $data');

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
          const SnackBar(content: Text('Password changed successfully')),
        );
        Navigator.of(context).pop();
      } else {
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

      // Print the data being sent to the API
      print('Sending data to updateUsername API: $data');

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
          const SnackBar(content: Text('Username changed successfully')),
        );
        Navigator.of(context).pop();
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
          'profileImage': _selectedProfileImage,
        };

        // Print the data being sent to the API
        print('Sending data to updateProfileInformation API: $data');

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
            const SnackBar(content: Text('Profile information updated successfully')),
          );
          Navigator.of(context).pop();
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
  Future<void> _changeEmail() async {
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

      // Print the data being sent to the API
      print('Sending data to updateEmail API: $data');

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
          const SnackBar(content: Text('Email changed successfully')),
        );
        Navigator.of(context).pop();
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
  Future<void> _sendOTP() async {
    setState(() {
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
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('API URL not found');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API URL not found')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }


}