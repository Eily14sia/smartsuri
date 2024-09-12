import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'dart:typed_data';
import 'dart:convert'; // Import to use base64Decode

class MyProfilePage extends StatelessWidget {
  final String profileImage;
  final String userName;
  final String email;
  final DateTime now = DateTime.now(); // Current date to compare with event dates

  MyProfilePage({
    super.key,
    required this.profileImage,
    required this.userName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    // Decode Base64 string to Uint8List
    Uint8List? decodedImage;
    if (profileImage.isNotEmpty) {
      try {
        decodedImage = base64Decode(profileImage);
      } catch (e) {
        print('Error decoding Base64 image: $e');
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Add padding to the entire page
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thin Green Header with Back Button
              Stack(
                children: [
                  Container(
                    height: 40, // Thin height for the green section
                    color: Colors.green[100],
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.green[900]),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),

              // Profile Section
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: decodedImage != null
                        ? MemoryImage(decodedImage!) // Display decoded Base64 image
                        : AssetImage('assets/profile1.png') as ImageProvider, // Placeholder image if decoding fails
                      backgroundColor: Colors.green[200],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // My Scan History Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                color: Colors.green[100],
                child: Text(
                  'My Scan History:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.recycling, color: Colors.green[900]),
                title: const Text('Recyclable', style: TextStyle(fontSize: 16)),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RecyclablePage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Non-Recyclable', style: TextStyle(fontSize: 16)),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NonRecyclablePage()),
                  );
                },
              ),

              const SizedBox(height: 15),

              // My Events Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                color: Colors.green[100],
                child: Text(
                  'My Events:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
              ),
              _buildEventTile(
                context,
                'Plastic Clearing Project',
                'August 19, 2024, 10:00 AM',
                'San Juan City',
                Icons.recycling,
                past: false,
              ),
              _buildEventTile(
                context,
                'Sample Event',
                'August 18, 2024, 10:00 AM',
                'Manila City',
                Icons.recycling,
                past: false,
              ),

              const SizedBox(height: 20),

              // Events History Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                color: Colors.green[100],
                child: Text(
                  'Events History:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
              ),
              _buildEventTile(
                context,
                'Beach Cleanup',
                'July 10, 2024, 9:00 AM',
                'Davao City',
                Icons.history,
                past: true,
              ),
              _buildEventTile(
                context,
                'Tree Planting Activity',
                'June 5, 2024, 7:30 AM',
                'Cebu City',
                Icons.history,
                past: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build event tiles
  Widget _buildEventTile(BuildContext context, String title, String date, String location, IconData icon, {required bool past}) {
    DateTime eventDate = DateFormat('MMMM d, yyyy, h:mm a').parse(date);
    bool isPast = eventDate.isBefore(now);

    return ListTile(
      leading: Icon(
        icon,
        color: Colors.green[900],
      ),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle: Text('$date\n$location', style: const TextStyle(fontSize: 14)),
      isThreeLine: true,
    );
  }
}

class RecyclablePage extends StatelessWidget {
  const RecyclablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recyclable Items'),
      ),
      body: const Center(
        child: Text('List of recyclable items goes here'),
      ),
    );
  }
}

class NonRecyclablePage extends StatelessWidget {
  const NonRecyclablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Non-Recyclable Items'),
      ),
      body: const Center(
        child: Text('List of non-recyclable items goes here'),
      ),
    );
  }
}
