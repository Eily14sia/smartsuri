import 'package:flutter/material.dart';

class RecentEventsPage extends StatelessWidget {
  const RecentEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Events'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildEventDetailCard(
            'Eco-bridge Recycling Project',
            'July 22, 2024',
            'San Juan City',
            'Details about the Eco-bridge Recycling Project...',
          ),
          _buildEventDetailCard(
            'Recyclable Plastic Boats',
            'February 24, 2024',
            'Manila City',
            'Details about the Recyclable Plastic Boats...',
          ),
          // Add more events as needed
        ],
      ),
    );
  }

  Widget _buildEventDetailCard(
      String title, String date, String location, String description) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.event, color: Colors.green),
        title: Text(title),
        subtitle: Text('$date\n$location\n\n$description'),
        isThreeLine: true,
        onTap: () {
          // Handle tap on event detail
        },
      ),
    );
  }
}
