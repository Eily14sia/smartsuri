import 'package:flutter/material.dart';
import 'login_page.dart';  // Import the login page

class PasswordChangedSuccessPage extends StatelessWidget {
  const PasswordChangedSuccessPage({super.key});

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
            // Bigger logo, centered higher
            Image.asset(
              'assets/Logooo.png',  // Assuming the logo is in the assets folder
              height: 200,  // Increased height for a bigger logo
            ),
            const SizedBox(height: 20),  // Reduced spacing below the logo
            // Success Message
            Text(
              'PASSWORD CHANGED SUCCESSFULLY!',
              style: TextStyle(
                fontSize: 24,  // Increased font size for the message
                fontWeight: FontWeight.bold,
                color: Colors.green[900]!,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Additional Message
            const Text(
              'You may now log in to your account.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            // Log-In Button
            ElevatedButton(
              onPressed: () {
                // Navigate to the login page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),  // Navigates to login page
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                backgroundColor: Colors.green[900]!,  // Green background
              ),
              child: const Text(
                'LOG-IN',
                style: TextStyle(color: Colors.white),  // White text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
