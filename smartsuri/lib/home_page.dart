import 'package:flutter/material.dart';
import 'scan_page.dart'; // Import the ScanPage
import 'find_events_page.dart'; // Import the FindEventsPage
import 'my_profile_page.dart'; // Import the MyProfilePage
import 'settings_page.dart'; // Import the SettingsPage
import 'browse_more_page.dart'; // Import the BrowseMorePage

class HomePage extends StatelessWidget {
  final String profileImage;
  final String userName;
  final String email;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomePage({super.key, required this.profileImage, required this.userName, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: Drawer(
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
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.event, color: Colors.green[900]),
              title: Text('Find Events', style: TextStyle(color: Colors.green[900])),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FindEventsPage(
                            profileImage: profileImage,
                            userName: userName,
                            email: email,
                          )),
                );
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
                          )),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.green[900]),
              title: Text('Settings', style: TextStyle(color: Colors.green[900])),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.green[900],
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Welcome, $userName!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.menu, color: Colors.green[900]!),
                    onPressed: () {
                      _scaffoldKey.currentState?.openEndDrawer();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Make Something New!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Recycle for a cause today!',
                      style: TextStyle(color: Colors.grey[700], fontSize: 16),
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
                      MaterialPageRoute(
                        builder: (context) => ScanPage(
                          profileImage: profileImage,
                          userName: userName,
                          email: email,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(color: Colors.green[900]!, width: 2),
                    ),
                  ),
                  child: Text(
                    'Find a Material',
                    style: TextStyle(
                      color: Colors.green[900]!,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Recycled Items Trend:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[900]!),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(itemIndex: index),
                          ),
                        );
                      },
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Item $index',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Best Innovation:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[900]!),
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InnovationDetailPage(innovation: 'Table Glass Lamp'),
                        ),
                      );
                    },
                    child: buildInnovationCard(
                      'Table Glass Lamp',
                      'A new aesthetic fit for your home.',
                      'URL_to_image_of_table_lamp',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InnovationDetailPage(innovation: 'Tire to Table'),
                        ),
                      );
                    },
                    child: buildInnovationCard(
                      'Tire to Table',
                      'An unexpected yet beautiful furniture for your living room.',
                      'URL_to_image_of_tire_table',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BrowseMorePage(
                          profileImage: profileImage,
                          userName: userName,
                          email: email,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
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
    );
  }

  Widget buildInnovationCard(String title, String subtitle, String imageUrl) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(5),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final int itemIndex;

  const DetailPage({super.key, required this.itemIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Details for item $itemIndex'),
      ),
    );
  }
}

class InnovationDetailPage extends StatelessWidget {
  final String innovation;

  const InnovationDetailPage({super.key, required this.innovation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Details about $innovation'),
      ),
    );
  }
}
