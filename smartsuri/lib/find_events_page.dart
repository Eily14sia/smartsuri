import 'package:flutter/material.dart';
import 'recent_events_page.dart';
import 'events_button.dart'; // Import the EventsButtonPage
import 'my_profile_page.dart'; // Import MyProfilePage
import 'settings_page.dart'; // Import SettingsPage
import 'home_page.dart'; // Import HomePage
import 'dart:typed_data';
import 'dart:convert'; // Import to use base64Decode

class FindEventsPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final String profileImage;
  final String userName;
  final String email;

  FindEventsPage({
    super.key,
    required this.profileImage,
    required this.userName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Decode Base64 string to Uint8List if necessary
    Uint8List? decodedImage;
    if (profileImage.isNotEmpty && profileImage.startsWith('data:image')) {
      try {
        decodedImage = base64Decode(profileImage.split(',').last);
      } catch (e) {
        print('Error decoding Base64 image: $e');
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildDrawer(context), // Drawer for navigation
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenSize.height * 0.05),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Events Near You',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Recycle for a cause today!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EventsButtonPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: BorderSide(color: Colors.green[900]!, width: 2),
                        ),
                      ),
                      child: Text(
                        'Find Events',
                        style: TextStyle(
                          color: Colors.green[900]!,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Recent Events:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildEventCard(
                    'Eco-bridge Recycling Project',
                    'July 22, 2024',
                    'San Juan City',
                    context,
                  ),
                  _buildEventCard(
                    'Recyclable Plastic Boats',
                    'February 24, 2024',
                    'Manila City',
                    context,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RecentEventsPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: BorderSide(color: Colors.green[900]!, width: 2),
                        ),
                      ),
                      child: Text(
                        'Browse More',
                        style: TextStyle(
                          color: Colors.green[900]!,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.green[900]),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: 20,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.menu, color: Colors.green[900]),
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              children: [
                Image.asset(
                  'assets/Logooo.png',
                  height: 130,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.green[900]),
            title: Text('Home', style: TextStyle(color: Colors.green[900])),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                    profileImage: profileImage,
                    userName: userName,
                    email: email,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.event, color: Colors.green[900]),
            title: Text('Find Events', style: TextStyle(color: Colors.green[900])),
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.person, color: Colors.green[900]),
            title: Text('My Profile', style: TextStyle(color: Colors.green[900])),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyProfilePage(
                    profileImage: profileImage,
                    userName: userName,
                    email: email,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.green[900]),
            title: Text('Settings', style: TextStyle(color: Colors.green[900])),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    profileImage: profileImage,
                    userName: userName,
                    email: email,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(String title, String date, String location, BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.green[900]!, width: 2),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.event, color: Colors.green[900]),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date), // Display the event date
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.green[900], size: 16),
                const SizedBox(width: 5),
                Expanded(child: Text(location)),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          // Optional: Add navigation or other action on tap
        },
      ),
    );
  }
}
