//VERIFICATON PARA SA FORGOT PASSWORD
import 'package:flutter/material.dart';
import 'create_new_password_page.dart'; // Import the create new password page

class VerificationCodePage extends StatefulWidget {
  const VerificationCodePage({super.key});

  @override
  _VerificationCodePageState createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  final TextEditingController codeController = TextEditingController();

  void _verifyCode() {
    // Logic to verify the code goes here
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateNewPasswordPage()),
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
      body: Center(  // Centering the layout
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Checkmark symbol at the top
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
            // Verification Code Title
            Text(
              'Verification Code',
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
                'Please enter the 6-digit code sent to your email.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),
            // Code input field
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
              child: const Text('Verify', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            // Resend verification code text
            TextButton(
              onPressed: () {
                // Logic to resend verification code
              },
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
