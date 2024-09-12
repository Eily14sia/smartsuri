import 'dart:typed_data';
import 'dart:convert'; // Import to use base64Decode
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // For launching URLs in mobile apps
import 'scan_page.dart';

class BrowseMorePage extends StatelessWidget {
  final String profileImage;
  final String userName;
  final String email;

  BrowseMorePage({super.key, 
    required this.profileImage,
    required this.userName,
    required this.email,
  });

  final List<Map<String, String>> recyclingIdeas = [
    {
      'title': 'Piggy Bank',
      'description': 'Learn how to recycle and save money at the same time!',
      'url': 'http://www.example.com/piggy-bank',
      'thumbnail': 'https://img.youtube.com/vi/[VIDEO_ID]/0.jpg',
    },
    {
      'title': 'Flower Pots',
      'description': 'An adornment for your plant’s home.',
      'url': 'http://www.example.com/flower-pots',
      'thumbnail': 'https://img.youtube.com/vi/[VIDEO_ID]/0.jpg',
    },
    {
      'title': 'Table Lamp',
      'description': 'An aesthetic fit for your home.',
      'url': 'http://www.example.com/table-lamp',
      'thumbnail': 'https://img.youtube.com/vi/[VIDEO_ID]/0.jpg',
    },
    {
      'title': 'Pencil Holder',
      'description': 'A container for your school essentials!',
      'url': 'http://www.example.com/pencil-holder',
      'thumbnail': 'https://img.youtube.com/vi/[VIDEO_ID]/0.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Decode Base64 string to Uint8List
    Uint8List? decodedImage;
    if (profileImage.isNotEmpty) {
      try {
        decodedImage = base64Decode(profileImage);
      } catch (e) {
        print('Error decoding Base64 image: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Best Innovation'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'A List of This Week\'s Best Crafts!!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: recyclingIdeas.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Image.network(
                        recyclingIdeas[index]['thumbnail']!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(recyclingIdeas[index]['title']!),
                      subtitle: Text(recyclingIdeas[index]['description']!),
                      trailing: IconButton(
                        icon: const Icon(Icons.link, color: Colors.green),
                        onPressed: () async {
                          final url = recyclingIdeas[index]['url']!;
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
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
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text('Find a Material'),
            ),
          ],
        ),
      ),
    );
  }
}
