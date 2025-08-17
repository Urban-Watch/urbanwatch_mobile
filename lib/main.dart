import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 1. Import the package
import 'package:image_picker/image_picker.dart';
import 'package:urbanwatch_mobile/screens/isssue_detail_screen.dart';

// 2. Make the main function async and load the .env file
Future<void> main() async {
  // Ensure that plugin services are initialized so that `dotenv.load()` can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();
  // Load the .env file
  await dotenv.load(fileName: ".env");
  runApp(const UrbanWatchApp());
}

class UrbanWatchApp extends StatelessWidget {
  const UrbanWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UrbanWatch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const ReportLauncherScreen(),
    );
  }
}

class ReportLauncherScreen extends StatelessWidget {
  const ReportLauncherScreen({super.key});

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  // Pass the context from the builder, which is always valid
                  _pickImage(bc, ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  // Pass the context from the builder
                  _pickImage(bc, ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Handles picking an image and navigating to the detail screen.
  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source);

      // After the 'await', check if the widget is still mounted before using its context.
      if (pickedFile != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IssueDetailScreen(
              imageFile: File(pickedFile.path),
              imageSource: source,
            ),
          ),
        );
      }
    } catch (e) {
      // Also check if the context is mounted before showing a SnackBar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UrbanWatch Reporter'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_a_photo, size: 28),
            label: const Text('Report New Issue'),
            onPressed: () => _showPicker(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
              textStyle: const TextStyle(fontSize: 22),
            ),
          ),
        ),
      ),
    );
  }
}
