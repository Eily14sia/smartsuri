import 'package:flutter/material.dart';
import 'verify_email_page.dart'; 
import 'terms_conditions.dart'; 
import 'privacy_policy.dart'; 
import 'login_page.dart'; 

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool agreeToTerms = false;
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  String selectedProfileImage = '';

  final List<String> cities = [
    'Caloocan', 'Las Piñas', 'Makati', 'Malabon', 'Mandaluyong', 'Manila',
    'Marikina', 'Muntinlupa', 'Navotas', 'Parañaque', 'Pasay', 'Pasig',
    'Quezon City', 'San Juan', 'Taguig', 'Valenzuela'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30), // Adjust the height to move content upwards
              Center(
                child: Text(
                  'Create New Account',
                  style: TextStyle(
                    color: Colors.green[900]!, // Match dark green color from login
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'YourFontFamily',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Sign up to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green[800]!, // Lighter green for secondary text
                  fontFamily: 'YourFontFamily',
                ),
              ),
              const SizedBox(height: 20),
              _buildRoundedButton(nameController, 'Name'),
              const SizedBox(height: 20),
              _buildRoundedButton(emailController, 'Email'),
              const SizedBox(height: 20),
              _buildBirthdayField(context),
              const SizedBox(height: 20),
              _buildCityDropdown(),
              const SizedBox(height: 20),
              _buildRoundedButton(passwordController, 'Password', isPassword: true),
              const SizedBox(height: 20),
              _buildRoundedButton(confirmPasswordController, 'Confirm Password', isPassword: true),
              const SizedBox(height: 30),
              const Text('Select Profile Image:', style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 10),
              _buildProfileImages(),
              const SizedBox(height: 20),
              _buildTermsAndPrivacy(),
              const SizedBox(height: 30),
              _buildSignUpButton(),
              const SizedBox(height: 30),
              _buildLoginText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedButton(TextEditingController controller, String label, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? (label == 'Password' ? _isPasswordHidden : _isConfirmPasswordHidden) : false,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.green[50], // Match background fill from VerificationPage
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        labelText: label,
        labelStyle: TextStyle(color: Colors.green[700]!), // Match green from login and VerificationPage
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none, // No border outline, matches VerificationPage
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  label == 'Password'
                      ? (_isPasswordHidden ? Icons.visibility_off : Icons.visibility)
                      : (_isConfirmPasswordHidden ? Icons.visibility_off : Icons.visibility),
                  color: Colors.green[700]!, // Match green from login
                ),
                onPressed: () {
                  setState(() {
                    if (label == 'Password') {
                      _isPasswordHidden = !_isPasswordHidden;
                    } else {
                      _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                    }
                  });
                },
              )
            : null,
      ),
      style: const TextStyle(color: Colors.black),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (label == 'Email' && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        if (label == 'Password' && value != confirmPasswordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildBirthdayField(BuildContext context) {
    return TextFormField(
      controller: birthdayController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.green[50], // Match background fill from VerificationPage
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        labelText: 'Birthday',
        labelStyle: TextStyle(color: Colors.green[700]!), // Match green from login
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none, // No border outline, matches VerificationPage
        ),
        suffixIcon: Icon(Icons.calendar_today, color: Colors.green[700]!), // Match green from login
      ),
      style: const TextStyle(color: Colors.black),
      readOnly: true, // Prevent manual input
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
          String formattedDate = '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
          setState(() {
            birthdayController.text = formattedDate;
          });
        }
            },
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      value: cityController.text.isEmpty ? null : cityController.text,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.green[50], // Match background fill from VerificationPage
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        labelText: 'City',
        labelStyle: TextStyle(color: Colors.green[700]!), // Match green from login
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none, // No border outline, matches VerificationPage
        ),
      ),
      style: const TextStyle(color: Colors.black),
      dropdownColor: Colors.white, // White dropdown background
      items: cities.map((String city) {
        return DropdownMenuItem<String>(
          value: city,
          child: Text(city, style: const TextStyle(color: Colors.black)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          cityController.text = newValue ?? '';
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a city';
        }
        return null;
      },
    );
  }

  Widget _buildProfileImages() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildProfileImageChoice('assets/profile1.png'),
        const SizedBox(width: 8), // Reduced the spacing
        _buildProfileImageChoice('assets/profile2.png'),
        const SizedBox(width: 8),
        _buildProfileImageChoice('assets/profile3.png'),
        const SizedBox(width: 8),
        _buildProfileImageChoice('assets/profile4.png'),
        const SizedBox(width: 8),
        _buildProfileImageChoice('assets/ayaw.png'), // Added new profile image
      ],
    );
  }

  Widget _buildProfileImageChoice(String imagePath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedProfileImage = imagePath;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: selectedProfileImage == imagePath
              ? Border.all(color: Colors.green[900]!, width: 2) // Match green from login
              : null,
        ),
        child: CircleAvatar(
          radius: 25, // Reduced the size of the avatar
          backgroundImage: AssetImage(imagePath),
        ),
      ),
    );
  }

  Widget _buildTermsAndPrivacy() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          value: agreeToTerms,
          onChanged: (bool? value) {
            setState(() {
              agreeToTerms = value ?? false;
            });
          },
        ),
        const Text(
          'I agree to the ',
          style: TextStyle(color: Colors.black), // No underline for this part
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsConditionsPage()));
          },
          child: Text(
            'Terms',
            style: TextStyle(
              color: Colors.green[700]!, // Match green from login
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const Text(' and ', style: TextStyle(color: Colors.black)), // Normal text for "and"
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()));
          },
          child: Text(
            'Privacy Policy',
            style: TextStyle(
              color: Colors.green[700]!, // Match green from login
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate() && agreeToTerms) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const VerifyEmailPage()));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[900]!, // Match dark green color from login
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text(
          'Sign Up',
          style: TextStyle(color: Colors.white, fontSize: 18), // White font color for button
        ),
      ),
    );
  }

  Widget _buildLoginText() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage())); // Redirect to login page
      },
      child: RichText(
        text: TextSpan(
          text: 'Already have an account? ',
          style: TextStyle(color: Colors.green[800]!),
          children: [
            TextSpan(
              text: 'Log in',
              style: TextStyle(
                color: Colors.green[900]!, // Match green from login
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
