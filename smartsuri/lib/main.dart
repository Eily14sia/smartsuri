import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_page.dart';
import 'sign_up_page.dart';
import 'about_us.dart';
import 'terms_conditions.dart';
import 'privacy_policy.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv

Future<void> main() async {
  await dotenv.load(fileName: ".env"); // Load the .env file
  runApp(const SmartSortApp());
}

class SmartSortApp extends StatelessWidget {
  const SmartSortApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartSort',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Arial',
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.grey[800]),
          bodyMedium: TextStyle(color: Colors.grey[800]),
          bodySmall: TextStyle(color: Colors.grey[800]),
        ),
      ),
      home: const IndexPage(),
    );
  }
}

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final List<String> images = ['assets/first.png', 'assets/second.png', 'assets/third.png'];
  int _currentImageIndex = 0;
  final Duration _duration = const Duration(seconds: 1);
  final Duration _interval = const Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _startImageSlider();
  }

  void _startImageSlider() {
    Future.delayed(_interval, () {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % images.length;
        });
        _startImageSlider();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Match background with login and sign-up pages
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 30), // Reduce excess height, layout panned upwards
              AnimatedSwitcher(
                duration: _duration,
                child: Container(
                  key: ValueKey<int>(_currentImageIndex),
                  height: 200,
                  width: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.transparent,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      images[_currentImageIndex],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/Logo1.png',
                height: 120, // Kept logo size unchanged
              ),
              const SizedBox(height: 20),
              Text(
                'WELCOME TO SMARTSURI!',
                style: TextStyle(
                  fontSize: 28,  // Keep font size consistent
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],  // Matching dark green from login page
                  fontFamily: 'YourFontFamily',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Updated Log-in Button
              SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.white,  // White background for button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(color: Colors.green[900]!, width: 2),  // Green border
                    ),
                  ),
                  child: Text(
                    'Log-in',
                    style: TextStyle(
                      color: Colors.green[900]!, // Green font color on white background
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Updated Sign-up Button
              SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.white,  // White background for button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(color: Colors.green[900]!, width: 2),  // Green border
                    ),
                  ),
                  child: Text(
                    'Sign-up',
                    style: TextStyle(
                      color: Colors.green[900]!, // Green font color on white background
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Contact Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.email, color: Colors.grey[700]),
                    onPressed: () {
                      _launchURL('mailto:smartsuri0903@gmail.com');
                    },
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: Icon(Icons.phone, color: Colors.grey[700]),
                    onPressed: () {
                      _launchURL('tel:09772066294');
                    },
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: Icon(Icons.contact_page, color: Colors.grey[700]),
                    onPressed: () {
                      _launchURL('https://www.facebook.com/profile.php?id=61565434558170');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // About Us, Terms, and Privacy Policy
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AboutUsPage()),
                      );
                    },
                    child: Text(
                      'About Us',
                      style: TextStyle(color: Colors.green[800]!),  // Matching lighter green
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TermsConditionsPage()),
                      );
                    },
                    child: Text(
                      'Terms and Conditions',
                      style: TextStyle(color: Colors.green[800]!),  // Matching lighter green
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                      );
                    },
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(color: Colors.green[800]!),  // Matching lighter green
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Copyright © 2024 SmartSuri. All Rights Reserved.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20), // Spacer to balance layout
            ],
          ),
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}
