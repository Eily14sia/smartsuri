import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'create_new_password_page.dart'; // Import the create new password page
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VerificationCodePage extends StatefulWidget {
  final String token;

  const VerificationCodePage({super.key, required this.token}); // Token passed in constructor

  @override
  _VerificationCodePageState createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';
  String? newToken; // Variable to hold the new token

  Future<void> _verifyCode() async {
    final String code = codeController.text;
    final String apiUrl = dotenv.env['API_URL'] ?? ''; // Get API URL from .env file

    if (code.isEmpty) {
      setState(() {
        errorMessage = "Please enter the verification code";
      });
      return;
    }

    if (apiUrl.isNotEmpty) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      try {
        // API call to verifyPass endpoint
        var response = await http.post(
          Uri.parse('$apiUrl/auth/verifyPass'), // Change to correct endpoint
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            'token': newToken ?? widget.token, // Use the new token if available
            'code': code,          // Code inputted by user
          }),
        );

        if (response.statusCode == 200) {
          // If verification is successful, proceed to create a new password
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateNewPasswordPage(token: newToken ?? widget.token),
            ),
          );
        } else {
          // Handle error from API response
          setState(() {
            errorMessage = 'Invalid code. Please try again.';
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'An error occurred: $e';
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

  Future<void> _resendVerificationCode() async {
    final String apiUrl = dotenv.env['API_URL'] ?? ''; // Get API URL from .env file

    if (apiUrl.isNotEmpty) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      try {
        // API call to resendPassCode endpoint
        var response = await http.post(
          Uri.parse('$apiUrl/auth/resendPassCode'), // Change to correct endpoint
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            'token': widget.token, 
          }),
        );

        if (response.statusCode == 200) {
          // Parse the response to get the new token
          var responseBody = json.decode(response.body);
          setState(() {
            newToken = responseBody['token']; // Set the new token
            errorMessage = 'Verification code has been resent to your email.';
          });
        } else {
          // Handle error from API response
          setState(() {
            errorMessage = 'Failed to resend verification code.';
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'An error occurred: $e';
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
      body: Center(
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
              'Verification Code',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green[900]!,
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                'Please enter the 6-digit code sent to your email.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
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
                  labelText: 'Enter Code',
                  labelStyle: TextStyle(color: Colors.green[700]!),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            if (errorMessage.isNotEmpty) // Display error message if any
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 10),
            // Verify Button
            ElevatedButton(
              onPressed: _verifyCode,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                backgroundColor: Colors.green[900]!,
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Verify', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _resendVerificationCode,
              child: Text(
                'Send verification code again',
                style: TextStyle(color: Colors.green[900]!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
