import 'package:flutter/material.dart';

class EventsButtonPage extends StatefulWidget {
  const EventsButtonPage({super.key});

  @override
  _EventsButtonPageState createState() => _EventsButtonPageState();
}

class _EventsButtonPageState extends State<EventsButtonPage> {
  final String userName = "Name"; // Replace with dynamically fetched user data
  final String userCity = "Manila City"; // Replace with dynamically fetched user data
  List<bool> eventAdded = [false, false, false]; // Track event addition status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center the text
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
            Expanded(
              child: ListView(
                children: [
                  _buildEventCard(
                    context,
                    'Plastic Clearing Project',
                    'August 19, 2024 10:00 AM',
                    userCity,
                    0,
                  ),
                  _buildEventCard(
                    context,
                    'Eco-bridge Recycling Project',
                    'August 27, 2024 6:00 AM',
                    userCity,
                    1,
                  ),
                  _buildEventCard(
                    context,
                    'Recyclable Plastic Boats',
                    'August 30, 2024 8:00 AM',
                    userCity,
                    2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, String title, String date, String location, int index) {
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
              _showConfirmationDialog(context, title, date, location, index);
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

  void _showConfirmationDialog(BuildContext context, String title, String date, String location, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.green[900]!, width: 2)),
          title: const Text('Do you want to join this event?'),
content: Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.center,  // Center-align the contents
  children: [
    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    Text(date),
    const SizedBox(height: 8),
    Row(
      mainAxisAlignment: MainAxisAlignment.center,  // Center-align the location row
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
      Navigator.of(context).pop();
    },
    child: const Text('No'),
  ),
  TextButton(
    onPressed: () {
      Navigator.of(context).pop(); // Close dialog, open joined event popup
      _showEventJoinedDialog(context, title, date, location, index);
    },
    child: const Text('Yes'),
  ),
],

        );
      },
    );
  }

  void _showEventJoinedDialog(BuildContext context, String title, String date, String location, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.green[900]!, width: 2)),
          title: const Text('Event Joined!'),
      content: Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.center,  // Center-align the contents
  children: [
    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    Text(date),
    const SizedBox(height: 8),
    Row(
      mainAxisAlignment: MainAxisAlignment.center,  // Center-align the location row
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
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
