import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'package:shared_preferences/shared_preferences.dart';


class VerificationPage extends StatelessWidget {
  final String email;
  final String profileImage;
  final String userName;

  const VerificationPage({
    super.key, 
    required this.email,
    required this.profileImage,
    required this.userName,
  });

Future<void> verifyCode(BuildContext context, String code) async {
  final String apiUrl = dotenv.env['API_URL'] ?? ''; // Get API URL from env file

  try {
    final response = await http.post(
      Uri.parse('$apiUrl/auth/verifCode'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );

    if (response.statusCode == 200) {
      // Decode the response
      final responseBody = jsonDecode(response.body);

      // Extract data
      final accessToken = responseBody['access_token']['accessToken'];
      final userInfo = responseBody['userinfo'];

      // Store the access token in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);

      // Navigate to HomePage with the response data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            userName: userInfo['username'],
            profileImage: userInfo['prof_img'], // Use default or update as needed
            email: userInfo['email'],
          ),
        ),
      );
    } else {
      // Handle error
      final responseBody = jsonDecode(response.body);
      final errorMessage = responseBody['errorMessage'] ?? 'Invalid verification code';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $error')),
    );
  }
}

  Future<void> resendVerificationCode(BuildContext context) async {
    final String apiUrl = dotenv.env['API_URL'] ?? ''; // Get API URL from env file

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/resendCode'), // URL for resending the code
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        // Handle success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification code resent successfully')),
        );
      } else {
        // Handle error
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['errorMessage'] ?? 'Failed to resend verification code';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController codeController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green[100],
                  ),
                  child: const Icon(Icons.verified, size: 50, color: Colors.green),
                ),
                const SizedBox(height: 20),
                Text(
                  'Verification Sent',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900]!,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Please enter the 6-digit code sent to',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green[800]!,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green[700]!,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: TextField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.green[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      labelText: 'Enter code',
                      labelStyle: TextStyle(color: Colors.green[700]!),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    final enteredCode = codeController.text;
                    if (enteredCode.isNotEmpty) {
                      verifyCode(context, enteredCode);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter the code')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    backgroundColor: Colors.green[900]!,
                  ),
                  child: const Text(
                    'VERIFY',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                 const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    resendVerificationCode(context);
                  },
                  child: Text(
                    'Resend Code?',
                    style: TextStyle(color: Colors.green[900]!),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
