import 'package:flutter/material.dart';
import 'signup_success_page.dart';  // Import SignupSuccessPage
import 'package:http/http.dart' as http;  // Import http package
import 'package:flutter_dotenv/flutter_dotenv.dart';  // Import dotenv for environment variables
import 'dart:convert';

class VerifyEmailPage extends StatefulWidget {
  final String email;  // Declare email as a final field

  const VerifyEmailPage({super.key, required this.email});  // Initialize email in the constructor

  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;
  bool isResending = false;

  Future<void> verifyEmail() async {
    final String code = codeController.text;
    final String apiUrl = dotenv.env['API_URL'] ?? '';  // Get API URL from env file

    if (apiUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API URL is not configured')),
      );
      return;
    }

    final Uri url = Uri.parse('$apiUrl/crud/user/verifyEmail');  // Adjust the endpoint if needed

    setState(() {
      isLoading = true;  // Show loading indicator
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': widget.email,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        // Handle successful response
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SignupSuccessPage(),
          ),
        );
      } else {
        // Handle error response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: Email Existing ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      // Handle network error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error occurred')),
      );
    } finally {
      setState(() {
        isLoading = false;  // Hide loading indicator
      });
    }
  }

  Future<void> resendVerificationCode() async {
    final String apiUrl = dotenv.env['API_URL'] ?? '';  // Get API URL from env file

    if (apiUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API URL is not configured')),
      );
      return;
    }

    final Uri url = Uri.parse('$apiUrl/auth/resendCode');  // Adjust the endpoint if needed

    setState(() {
      isResending = true;  // Show loading indicator for resending
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': widget.email,
        }),
      );

      if (response.statusCode == 200) {
        // Handle successful response
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification code resent successfully')),
        );
      } else {
        // Handle error response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resend verification code: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      // Handle network error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error occurred')),
      );
    } finally {
      setState(() {
        isResending = false;  // Hide loading indicator for resending
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);  // Navigate back to the previous page
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
                // Checkmark symbol
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
                // Verification Sent Text
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
                  'Please enter the 6-digit code sent to your email.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green[800]!,
                  ),
                ),
                const SizedBox(height: 30),
                // Code Input
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
                // Verify Button with loading indicator
                ElevatedButton(
                  onPressed: isLoading ? null : () => verifyEmail(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    backgroundColor: Colors.green[900]!,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        )
                      : const Text(
                          'VERIFY',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
                const SizedBox(height: 20),
                // Resend code button with loading indicator
                TextButton(
                  onPressed: isResending ? null : () => resendVerificationCode(),
                  child: isResending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.green,
                            strokeWidth: 2.0,
                          ),
                        )
                      : Text(
                          'Resend Code?',
                          style: TextStyle(color: Colors.green[900]!),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
