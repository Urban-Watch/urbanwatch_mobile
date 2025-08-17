import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urbanwatch_mobile/screens/isssue_detail_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

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
                // --- THIS IS THE FIX ---
                onTap: () async {
                  Navigator.of(context).pop(); // 1. Close the sheet first
                  await _pickImage(context, ImageSource.gallery); // 2. Then await the result
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                // --- THIS IS THE FIX ---
                onTap: () async {
                  Navigator.of(context).pop(); // 1. Close the sheet first
                  await _pickImage(context, ImageSource.camera); // 2. Then await the result
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
