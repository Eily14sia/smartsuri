import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EventsButtonPage extends StatefulWidget {
  final List<Map<String, dynamic>> events; // List of events passed to the page

  const EventsButtonPage({super.key, required this.events});

  @override
  _EventsButtonPageState createState() => _EventsButtonPageState();
}

class _EventsButtonPageState extends State<EventsButtonPage> {
  late String userName; // Replace with dynamically fetched user data
  late String userCity; // Replace with dynamically fetched user data
  late List<bool> eventAdded; // Track event addition status dynamically
  late List<Map<String, dynamic>> filteredEvents; // List of filtered events
  String selectedCity = 'All Cities'; // Default dropdown value

  final List<String> cities = [
    'All Cities',
    'Caloocan', 'Las Piñas', 'Makati', 'Malabon', 'Mandaluyong', 'Manila',
    'Marikina', 'Muntinlupa', 'Navotas', 'Parañaque', 'Pasay', 'Pasig',
    'Quezon City', 'San Juan', 'Taguig', 'Valenzuela'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadEventAddedState();
    filteredEvents = widget.events;
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Name';
      userCity = prefs.getString('userCity') ?? 'Manila City';
    });
  }

  Future<void> _loadEventAddedState() async {
    final prefs = await SharedPreferences.getInstance();
    final eventAddedList = prefs.getStringList('eventAdded') ?? [];
    setState(() {
      eventAdded = List<bool>.filled(widget.events.length, false);
      for (int i = 0; i < eventAddedList.length; i++) {
        eventAdded[i] = eventAddedList[i] == 'true';
      }
    });
  }

  Future<void> _saveEventAddedState() async {
    final prefs = await SharedPreferences.getInstance();
    final eventAddedList = eventAdded.map((e) => e.toString()).toList();
    await prefs.setStringList('eventAdded', eventAddedList);
  }

  // Method to call getEventByID API
  Future<void> _getEventByID(String eventID) async {
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('access_token');
    final String? email = prefs.getString('email');

    final String apiUrl = dotenv.env['API_URL'] ?? ''; // Get API URL from env file

    if (accessToken == null || email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Access token or email not found')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/crud/event/addEvent/$eventID'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        // Handle the response as needed
        print('Event details: $jsonResponse');
      } else {
        print('Failed to load event with status: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load event with status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  // Method to store event details in shared preferences
  Future<void> _storeEventDetails(String id, String name, String date, String location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('event_${id}_name', name);
    await prefs.setString('event_${id}_date', date);
    await prefs.setString('event_${id}_location', location);
  }

  // Method to filter events based on selected city
  void _filterEventsByCity(String city) {
    setState(() {
      if (city == 'All Cities') {
        filteredEvents = widget.events; // Show all events
      } else {
        filteredEvents = widget.events
            .where((event) => event['location'] == city)
            .toList(); // Filter events based on city
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.green[900]),
                  onPressed: () {
                    Navigator.pop(context); // Go back to the previous page
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Title: Events Near You
            Center(
              child: Column(
                children: [
                  const Text(
                    'Events Near You',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Hello $userName! Based on your city, we may suggest you to check the following events:',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // City Dropdown for filtering events
            DropdownButtonFormField<String>(
              value: selectedCity,
              items: cities.map((city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _filterEventsByCity(value);
                  setState(() {
                    selectedCity = value;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Filter by City',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.green[900]!),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Display the filtered list of events
            Expanded(
              child: ListView.builder(
                itemCount: filteredEvents.length,
                itemBuilder: (context, index) {
                  final event = filteredEvents[index];
                  return _buildEventCard(
                    context,
                    event['id'].toString(),
                    event['name']!,
                    event['date']!,
                    event['location']!,
                    index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, String id, String title, String date, String location, int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.green[900]!, width: 2), // Green border for events
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.event, color: Colors.green[900]), // Updated icon color
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align city name with location icon
          children: [
            Text(date),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.green[900], size: 16), // Add location icon
                const SizedBox(width: 5),
                Flexible(
                  child: Text(location), // Ensure the text is flexible to avoid overflow
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: ElevatedButton(
          onPressed: () {
            if (!eventAdded[index]) {
              _getEventByID(id); // Call the getEventByID API with the event ID
              _showConfirmationDialog(context, title, date, location, index, id); // Show confirmation dialog with event ID
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: eventAdded[index] ? Colors.green[900] : Colors.white,
            side: BorderSide(color: Colors.green[900]!, width: 2), // Green outline
          ),
          child: Text(
            eventAdded[index] ? 'Event Added' : 'Add Event',
            style: TextStyle(color: eventAdded[index] ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, String title, String date, String location, int index, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.green[900]!, width: 2),
          ),
          title: const Text('Do you want to join this event?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center, // Center-align the contents
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(date),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center-align the location row
                children: [
                  Icon(Icons.location_on, color: Colors.green[900], size: 16),
                  const SizedBox(width: 5),
                  Text(location),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  eventAdded[index] = true;
                });
                _saveEventAddedState();
                Navigator.of(context).pop(); // Close dialog
                _showEventJoinedDialog(context, title, date, location, index, id); // Show event joined confirmation
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showEventJoinedDialog(BuildContext context, String title, String date, String location, int index, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.green[900]!, width: 2),
          ),
          title: const Text('Event Joined!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center, // Center-align the contents
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(date),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center-align the location row
                children: [
                  Icon(Icons.location_on, color: Colors.green[900], size: 16),
                  const SizedBox(width: 5),
                  Text(location),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'We look forward to seeing you! Thank you for your advanced participation!',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  eventAdded[index] = true; // Update the button text
                });
                _storeEventDetails(id, title, date, location); // Store event details in shared preferences
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}