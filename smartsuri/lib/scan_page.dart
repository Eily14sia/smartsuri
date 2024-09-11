import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'find_events_page.dart';
import 'my_profile_page.dart';
import 'settings_page.dart';

class ScanPage extends StatefulWidget {
  final String profileImage;
  final String userName;
  final String email;

  const ScanPage({super.key, required this.profileImage, required this.userName, required this.email});

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  bool _isCameraError = false;
  String? _cameraErrorMessage;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _cameraController = CameraController(
          cameras![0],
          ResolutionPreset.medium,
        );
        await _cameraController!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      } else {
        setState(() {
          _isCameraError = true;
          _cameraErrorMessage = 'No camera found on this device.';
        });
      }
    } catch (e) {
      setState(() {
        _isCameraError = true;
        _cameraErrorMessage = 'Error initializing camera: $e';
      });
    }
  }

  Future<String> _saveImage(XFile image) async {
    final directory = await getApplicationDocumentsDirectory();
    final String path = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
    final File newImage = File(path);
    return newImage.writeAsBytes(await image.readAsBytes()).then((_) => path);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildDrawer(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenSize.height * 0.05),
                Image.asset(
                  'assets/Logooo.png',
                  height: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  'SCAN YOUR MATERIAL',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                if (_isCameraInitialized)
                  AspectRatio(
                    aspectRatio: _cameraController!.value.aspectRatio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                if (_isCameraError)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        _cameraErrorMessage ?? 'Unknown error initializing camera.',
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt, color: Colors.black),
                  label: const Text('Capture', style: TextStyle(color: Colors.black)),
                  onPressed: _isCameraInitialized
                      ? () async {
                          if (_cameraController != null && _cameraController!.value.isInitialized) {
                            try {
                              XFile picture = await _cameraController!.takePicture();
                              String imagePath = await _saveImage(picture);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Picture saved at $imagePath')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error taking picture: $e')),
                              );
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[900],
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Hold steady to SCAN',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.green),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: 20,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.green),
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer() {
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
                  height: 120,
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
                          profileImage: widget.profileImage,
                          userName: widget.userName,
                          email: widget.email,
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
                          profileImage: widget.profileImage,
                          userName: widget.userName,
                          email: widget.email,
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
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
