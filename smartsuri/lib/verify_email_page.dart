import 'package:flutter/material.dart';
import 'signup_success_page.dart';  // Import SignupSuccessPage

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController codeController = TextEditingController();

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
          // Background: plain white for a cleaner look
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
                // Verify Button
                ElevatedButton(
                  onPressed: () {
                    // After verification, navigate to SignupSuccessPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupSuccessPage(),
                      ),
                    );
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
                // Option to resend the code
                TextButton(
                  onPressed: () {
                    // Resend code logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Verification code resent')),
                    );
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
