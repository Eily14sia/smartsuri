import 'package:flutter/material.dart';
import 'verification_code_page.dart'; // Import the verification code page

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  void _sendVerificationCode() {
    // Logic to send the verification code goes here
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VerificationCodePage()),
    );
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
      body: Center(  // Updated to center all the elements
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
            // Send Verification Code Button with white text
            ElevatedButton(
              onPressed: _sendVerificationCode,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                backgroundColor: Colors.green[900]!,
              ),
              child: const Text(
                'Send Verification Code',
                style: TextStyle(color: Colors.white),  // White text
              ),
            ),
          ],
        ),
      ),
    );
  }
}
