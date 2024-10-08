import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the date
import 'package:http/http.dart' as http;
import 'dart:convert'; // For encoding the request body
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:smartsuri/events_button.dart'; // For environment variables
import 'package:smartsuri/find_events_page.dart'; // For environment variables
import 'package:shared_preferences/shared_preferences.dart';


class AddEventPage extends StatefulWidget {
  final Function(Map<String, String>) onEventAdded;

  const AddEventPage({super.key, required this.onEventAdded});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  String _eventName = '';
  String _eventDate = '';
  String _selectedCity = '';

  final List<String> _cities = [
    'Caloocan', 'Las Piñas', 'Makati', 'Malabon', 'Mandaluyong', 'Manila',
    'Marikina', 'Muntinlupa', 'Navotas', 'Parañaque', 'Pasay', 'Pasig',
    'Quezon City', 'San Juan', 'Taguig', 'Valenzuela'
  ];

 Future<void> _sendEventToApi(Map<String, String> event) async {
  final String apiUrl = dotenv.env['API_URL'] ?? ''; // Get API URL from env file

  if (apiUrl.isNotEmpty) {
    try {
      var response = await http.post(
        Uri.parse('$apiUrl/crud/event/createEvent'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(event),
      );

      if (response.statusCode == 200) {
        // Successfully sent the event
        var jsonResponse = json.decode(response.body);
        print('Event added successfully: $jsonResponse');
        
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Event added successfully')),
            );
        
      } else {
        // Handle other errors
        print('Failed to add event with status: ${response.statusCode}');
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add event with status: ${response.statusCode}')),
          );
        } else {
          print('Context is null');
        }
      }
    } catch (e) {
      print('Error: $e');
      // Show error message to user (optional)
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      } else {
        print('Context is null');
      }
    }
  } else {
    print('API URL not found');
    // Show error message to user (optional)
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API URL not found')),
      );
    } else {
      print('Context is null');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.green[900]),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Add New Event',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              const SizedBox(height: 20),
              // Event Name Text Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green[900]!),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _eventName = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Event Date Picker
              TextFormField(
                readOnly: true, // Prevent manual input
                decoration: InputDecoration(
                  labelText: 'Event Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green[900]!),
                  ),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)), // Set initial date as tomorrow
                    firstDate: DateTime.now().add(const Duration(days: 1)), // Allow only dates from tomorrow
                    lastDate: DateTime(2101), // Set an upper bound for dates
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _eventDate = DateFormat('MMMM d, yyyy').format(pickedDate);
                    });
                  }
                },
                controller: TextEditingController(text: _eventDate),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an event date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Event Location Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Event Location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green[900]!),
                  ),
                ),
                value: _selectedCity.isNotEmpty ? _selectedCity : null,
                items: _cities.map((city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Save Event Button
            ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    Map<String, String> newEvent = {
                      'name': _eventName,
                      'date': _eventDate,
                      'location': _selectedCity,
                    };
                    await _sendEventToApi(newEvent); // Send the event to the API
                    widget.onEventAdded(newEvent);
                    // Show success message and then navigate to EventButtonPage
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Event added successfully')),
                    );
                    // Delay the navigation to ensure the SnackBar is shown
                    await Future.delayed(const Duration(seconds: 1));
                   if (mounted) {
                      // Retrieve the stored values from SharedPreferences
                      final prefs = await SharedPreferences.getInstance();
                      final profileImage = prefs.getString('profileImage') ?? '';
                      final userName = prefs.getString('userName') ?? '';
                      final email = prefs.getString('email') ?? '';

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FindEventsPage(
                            profileImage: profileImage, 
                            userName: userName,      
                            email: email,             
                          ),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    side: BorderSide(color: Colors.green[900]!, width: 2),
                  ),
                ),
                child: const Text('Save Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}