import 'package:flutter/material.dart';
import 'forgot_password_page.dart';
import 'verification_page.dart';
import 'sign_up_page.dart'; // Import the sign-up page
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;
  bool isLoading = false;

// Function to handle login request
Future<void> loginUser(String email, String password) async {
  final String apiUrl = dotenv.env['API_URL'] ?? ''; // Get API URL from env file

  if (apiUrl.isNotEmpty) {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      var response = await http.post(
        Uri.parse('$apiUrl/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        print('Login successful: $jsonResponse');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationPage(
              profileImage: 'assets/default_profile.png', // Default image
              userName: 'YourUserName', // Default or fetched username
              email: email,
            ),
          ),
        );
      } else {
        String errorMessage = response.statusCode == 401
            ? 'Invalid email or password. Please try again.'
            : 'Login failed with status: ${response.statusCode}';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
    }
  } else {
    print('API URL not found');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API URL not found')));
    setState(() {
      isLoading = false; // Hide loading indicator
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.white, // Set a plain white background
            ),
          ),
          Column(
            children: [
              Container(
                height: 250,
                width: double.infinity,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/Logooo.png', // Your logo asset
                      height: 170,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Create a Change Now!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green[900],
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900]!,
                          fontFamily: 'YourFontFamily',
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Sign in to continue',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green[800]!,
                          fontFamily: 'YourFontFamily',
                        ),
                      ),
                      const SizedBox(height: 20),
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
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: TextField(
                          controller: passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.green[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.green[700]!),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility_off : Icons.visibility,
                                color: Colors.green[700]!,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      isLoading
                      ? CircularProgressIndicator() // Show loading indicator
                      :ElevatedButton(
                        onPressed: () {
                          final email = emailController.text;
                          final password = passwordController.text;
                          loginUser(email, password);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                          backgroundColor: Colors.green[900]!,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Text(
                          'Log In',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.green[900]!),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Not signed in yet? ",
                            style: TextStyle(color: Colors.green[800]!, fontFamily: 'YourFontFamily'),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SignUpPage()),
                              );
                            },
                            child: Text(
                              "Sign up",
                              style: TextStyle(
                                color: Colors.green[800]!,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                fontFamily: 'YourFontFamily',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
