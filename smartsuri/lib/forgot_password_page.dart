import 'package:flutter/material.dart';
import 'verification_code_page.dart'; // Import the verification code page
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import flutter_dotenv
import 'dart:convert'; // For JSON encoding
import 'package:http/http.dart' as http;

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  Future<void> _sendVerificationCode() async {
    final String email = emailController.text;
    final String apiUrl = dotenv.env['API_URL'] ?? ''; // Get API URL from .env file

    if (email.isEmpty) {
      setState(() {
        errorMessage = "Please enter your email";
      });
      return;
    }

    if (apiUrl.isNotEmpty) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      try {
        var response = await http.post(
          Uri.parse('$apiUrl/auth/forgetPass'), // Append endpoint
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            'email': email, // Send email as part of the body
          }),
        );

        if (response.statusCode == 200) {
          // Parse the response body and extract the token
          var responseBody = json.decode(response.body);
          String token = responseBody['token']; // Assuming token is in the response

          // Navigate to the next page and pass the token
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationCodePage(token: token), // Pass the token
            ),
          );
        } else {
          // Handle error response
          setState(() {
            errorMessage = 'Failed to send verification code. Try again.';
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'Error occurred: $e';
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        errorMessage = 'API URL is missing or incorrect.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(  // Center all the elements
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Original eco icon at the top
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green[100],
              ),
              child: const Icon(Icons.eco, size: 50, color: Colors.green),
            ),
            const SizedBox(height: 20),
            // Forgot Password Title
            Text(
              'Forgot Password',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green[900]!,
              ),
            ),
            const SizedBox(height: 10),
            // Instructions text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                'Please enter your email address to receive a verification code.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),
            // Email input field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.green[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.green[700]!),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            // Error message display
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 10),
            // Send Verification Code Button with circular progress indicator
            ElevatedButton(
              onPressed: isLoading ? null : _sendVerificationCode,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                backgroundColor: Colors.green[900]!,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    )
                  : const Text(
                      'Send Verification Code',
                      style: TextStyle(color: Colors.white), // White text
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
