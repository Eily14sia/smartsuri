import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class MyProfilePage extends StatelessWidget {
  final String profileImage;
  final String userName;
  final String email;
  final DateTime now = DateTime.now(); // Current date to compare with event dates

  MyProfilePage({super.key, 
    this.profileImage = "https://via.placeholder.com/150", // Default placeholder image if none is provided
    this.userName = "YourUserName", // Default username if none is provided
    this.email = "sampleemail@gmail.com", // Default sample email if none is provided
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Make sure the page is scrollable
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
              
              // Profile Section (Adjusted to match the SettingsPage layout)
              const SizedBox(height: 20), // Add space between header and profile
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50, // Adjusted size to match SettingsPage
                      backgroundImage: NetworkImage(profileImage), // Dynamic profile image or default placeholder
                      backgroundColor: Colors.green[200], // Placeholder background color
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userName, // Dynamic user name or default
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Adjusted to match SettingsPage
                    ),
                    const SizedBox(height: 5), // Add space between username and email
                    Text(
                      email, // Dynamic or sample email
                      style: const TextStyle(
                        fontSize: 16, // Adjusted to match SettingsPage
                        color: Colors.black, // Black color
                        fontWeight: FontWeight.normal, // Ensure it's not bold
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30), // More space after the profile section

              // My Scan History Section with Green Background and Closer Spacing
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                color: Colors.green[100],
                child: Text(
                  'My Scan History:',
                  style: TextStyle(
                    fontSize: 16, // Slightly smaller font size for the section title
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900], // Dark green text color
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

              // Closer Spacing Between Sections
              const SizedBox(height: 15), // Reduce space between "Non-Recyclable" and "My Events"

              // My Events Section with Green Background
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                color: Colors.green[100],
                child: Text(
                  'My Events:',
                  style: TextStyle(
                    fontSize: 16, // Slightly smaller font size for the section title
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900], // Dark green text color
                  ),
                ),
              ),
              _buildEventTile(
                context,
                'Plastic Clearing Project',
                'August 19, 2024, 10:00 AM',
                'San Juan City',
                now,
                Icons.recycling,
                past: false,
              ),
              _buildEventTile(
                context,
                'Sample Event',
                'August 18, 2024, 10:00 AM',
                'Manila City',
                now,
                Icons.recycling,
                past: false,
              ),

              const SizedBox(height: 20),

              // Events History Section with Green Background
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                color: Colors.green[100],
                child: Text(
                  'Events History:',
                  style: TextStyle(
                    fontSize: 16, // Slightly smaller font size for the section title
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900], // Dark green text color
                  ),
                ),
              ),
              _buildEventTile(
                context,
                'Beach Cleanup',
                'July 10, 2024, 9:00 AM',
                'Davao City',
                now,
                Icons.history,
                past: true,
              ),
              _buildEventTile(
                context,
                'Tree Planting Activity',
                'June 5, 2024, 7:30 AM',
                'Cebu City',
                now,
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
  Widget _buildEventTile(BuildContext context, String title, String date, String location, DateTime now, IconData icon, {required bool past}) {
    DateTime eventDate = DateFormat('MMMM d, yyyy, hh:mm a').parse(date);
    // ignore: unused_local_variable
    bool isPast = eventDate.isBefore(now);

    return ListTile(
      leading: Icon(
        icon,
        color: Colors.green[900], // Matching color with recyclable icon
      ),
      title: Text(title, style: const TextStyle(fontSize: 16)), // Consistent font size for event title
      subtitle: Text('$date\n$location', style: const TextStyle(fontSize: 14)), // Slightly smaller font size for subtitle
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
