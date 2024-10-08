import 'package:flutter/material.dart';

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({super.key});

  @override
  _RecommendationPageState createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  String _result = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendations'),
        backgroundColor: Colors.green[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Text Field Input
              TextFormField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: 'Type a word',
                  hintText: 'Enter your search term here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.green[900]!, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a word';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Submit Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    setState(() {
                      _result = _textController.text; // Update result with the typed word
                    });
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
                child: Text(
                  'Search',
                  style: TextStyle(color: Colors.green[900]!),
                ),
              ),
              const SizedBox(height: 30),
              // Display Results
              if (_result.isNotEmpty)
                Text(
                  'Results for "$_result":',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
              const SizedBox(height: 10),
              if (_result.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: 5, // Example count, you can modify this as needed
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.green[900]!, width: 2),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Icon(Icons.star, color: Colors.green[900]),
                          title: Text('Result ${index + 1}'),
                          subtitle: Text('Related to "$_result"'),
                          onTap: () {
                            // Define the action when an item is tapped
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}