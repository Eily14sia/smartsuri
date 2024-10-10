import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'events_button.dart'; // Import the EventsButtonPage
import 'add_event_page.dart'; // Import the AddEventPage
import 'my_profile_page.dart'; // Import MyProfilePage
import 'settings_page.dart'; // Import SettingsPage
import 'home_page.dart'; // Import HomePage
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'package:intl/intl.dart'; // Import the intl package

class FindEventsPage extends StatefulWidget {
  final String profileImage;
  final String userName;
  final String email;

  const FindEventsPage({
    super.key,
    required this.profileImage,
    required this.userName,
    required this.email,
  });

  @override
  _FindEventsPageState createState() => _FindEventsPageState();
}

class _FindEventsPageState extends State<FindEventsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedCity = 'All Cities';
  List<Map<String, dynamic>> events = [];
  bool isLoading = true;
  int itemsToShow = 10;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  // Add this helper method to format the date
  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat formatter = DateFormat('MMMM dd, yyyy'); // Desired format
    return formatter.format(parsedDate);
  }

 Future<void> _fetchEvents() async {
  final String apiUrl = dotenv.env['API_URL'] ?? ''; // Get API URL from env file

  if (apiUrl.isNotEmpty) {
    try {
      final response = await http.get(Uri.parse('$apiUrl/crud/event/getEvent'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> eventList = jsonResponse['events']; // Adjust this based on actual JSON structure
        setState(() {
          events = eventList.map((event) => {
            'id': event['id'],
            'name': event['name'],
            'date': _formatDate(event['date']),
            'location': event['location'],
            'details': event['details'],
          }).toList();
        });
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No Events Found')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load events with status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  } else {
    print('API URL not found');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API URL not found')),
    );
    setState(() {
      isLoading = false;
    });
  }
}

Widget build(BuildContext context) {
  final screenSize = MediaQuery.of(context).size;
  const buttonWidth = 250.0; // Adjust to match your button size

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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Find Events Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventsButtonPage(
                                events: events, // Pass the actual list of events from FindEventsPage
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            side: BorderSide(color: Colors.green[900]!, width: 2),
                          ),
                        ),
                        child: Text(
                          'Select Event',
                          style: TextStyle(
                            color: Colors.green[900]!,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Add Event Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEventPage(
                                onEventAdded: (newEvent) {
                                  setState(() {
                                    events.add(newEvent); // Add new event to list
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            side: BorderSide(color: Colors.green[900]!, width: 2),
                          ),
                        ),
                        child: Text(
                          'Add Event',
                          style: TextStyle(
                            color: Colors.green[900]!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Dropdown for City Filter
                Center(
                  child: SizedBox(
                    width: buttonWidth, // Set the dropdown width to match buttons
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.green[900]!, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      value: selectedCity,
                      items: [
                        'All Cities',
                        'Caloocan',
                        'Las Piñas',
                        'Makati',
                        'Malabon',
                        'Mandaluyong',
                        'Manila',
                        'Marikina',
                        'Muntinlupa',
                        'Navotas',
                        'Parañaque',
                        'Pasay',
                        'Pasig',
                        'Quezon City',
                        'San Juan',
                        'Taguig',
                        'Valenzuela',
                      ].map<DropdownMenuItem<String>>((String city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCity = newValue!;
                        });
                      },
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
                // Filtered Event Cards
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (events.isEmpty)
                  const Center(child: Text('No Events Available'))
                else
                  ..._buildFilteredEvents(),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        itemsToShow += 10;
                      });
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
                    userName: widget.userName,
                    profileImage: widget.profileImage,
                    email: widget.email,
                  ),
                ), // Ensure HomePage is properly implemented
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.event, color: Colors.green[900]),
            title: Text('Find Events', style: TextStyle(color: Colors.green[900])),
            onTap: () {
              Navigator.pop(context);
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
                    profileImage: widget.profileImage,
                    userName: widget.userName,
                    email: widget.email,
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
                    profileImage: widget.profileImage,
                    userName: widget.userName,
                    email: widget.email,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilteredEvents() {
    // Filter events based on the selected city
    List<Map<String, dynamic>> filteredEvents = selectedCity == 'All Cities'
        ? events
        : events.where((event) => event['location']?.contains(selectedCity) ?? false).toList();

    // Limit the number of events to show
    List<Map<String, dynamic>> eventsToDisplay = filteredEvents.take(itemsToShow).toList();

    return eventsToDisplay.map((event) {
      return _buildEventCard(event);
    }).toList();
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
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
          event['name'],
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event['date']), // Display the event date
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.green[900], size: 16),
                const SizedBox(width: 5),
                Expanded(child: Text(event['location'])),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          _showEventDetailsModal(event);
        },
      ),
    );
  }

  void _showEventDetailsModal(Map<String, dynamic> event) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        contentPadding: const EdgeInsets.all(16.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['name'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Date: ${event['date']}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Location: ${event['location']}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Details: ${event['details']}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Close',
              style: TextStyle(color: Colors.green[900]),
            ),
          ),
        ],
      );
    },
  );
}
}