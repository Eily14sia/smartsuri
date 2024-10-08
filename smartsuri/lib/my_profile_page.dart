import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'dart:typed_data';
import 'dart:convert'; // Import to use base64Decode
import 'package:shared_preferences/shared_preferences.dart';

class MyProfilePage extends StatefulWidget {
  final String profileImage;
  final String userName;
  final String email;

  MyProfilePage({
    super.key,
    required this.profileImage,
    required this.userName,
    required this.email,
  });

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final DateTime now = DateTime.now(); // Current date to compare with event dates
  List<Map<String, String>> upcomingEvents = [];
  List<Map<String, String>> pastEvents = [];

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }

  Future<void> _loadEventDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('event_'));
    final uniqueEvents = <String>{};

    for (var key in keys) {
      final parts = key.split('_');
      if (parts.length == 3) {
        final id = parts[1];
        final name = prefs.getString('event_${id}_name') ?? '';
        final date = prefs.getString('event_${id}_date') ?? '';
        final location = prefs.getString('event_${id}_location') ?? '';
        final eventIdentifier = '$name|$date|$location';

        if (!uniqueEvents.contains(eventIdentifier)) {
          uniqueEvents.add(eventIdentifier);
          final eventDate = DateTime.parse(date);
          if (eventDate.isBefore(now)) {
            pastEvents.add({'name': name, 'date': date, 'location': location});
          } else {
            upcomingEvents.add({'name': name, 'date': date, 'location': location});
          }
        }
      }
    }

    setState(() {
      // Trigger UI update
    });

    print('Loaded upcoming events: $upcomingEvents');
    print('Loaded past events: $pastEvents');
  }

  @override
  Widget build(BuildContext context) {
    // Decode Base64 string to Uint8List
    Uint8List? decodedImage;
    if (widget.profileImage.isNotEmpty) {
      try {
        decodedImage = base64Decode(widget.profileImage);
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
                        ? MemoryImage(decodedImage) // Display decoded Base64 image
                        : const AssetImage('assets/profile1.png') as ImageProvider, // Placeholder image if decoding fails
                      backgroundColor: Colors.green[200],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.userName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.email,
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
              ...upcomingEvents.map((event) => _buildEventTile(
                context,
                event['name']!,
                event['date']!,
                event['location']!,
                Icons.recycling,
                past: false,
              )).toList(),

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
              ...pastEvents.map((event) => _buildEventTile(
                context,
                event['name']!,
                event['date']!,
                event['location']!,
                Icons.history,
                past: true,
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build event tiles
  Widget _buildEventTile(BuildContext context, String title, String date, String location, IconData icon, {required bool past}) {
    DateTime eventDate = DateTime.parse(date); // Parse ISO 8601 date string
    String formattedDate = DateFormat('MMMM d, yyyy').format(eventDate); // Format to desired display format
    bool isPast = eventDate.isBefore(now);

    return ListTile(
      leading: Icon(
        icon,
        color: Colors.green[900],
      ),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle: Text('$formattedDate\n$location', style: const TextStyle(fontSize: 14)),
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