import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urbanwatch_mobile/screens/isssue_detail_screen.dart';
import 'package:urbanwatch_mobile/widgets/app_drawer.dart'; // 1. Import the AppDrawer

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Using Playfair Display as the default font family
        fontFamily: GoogleFonts.playfairDisplay().fontFamily,
        scaffoldBackgroundColor: Colors.white, // Neumorphic background
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const ReportLauncherScreen(),
    );
  }
}

class ReportLauncherScreen extends StatelessWidget {
  const ReportLauncherScreen({super.key});

  /// Shows a modal bottom sheet for picking an image from the gallery or camera.
  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF1F5F9),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF333742)),
                title: const Text('Photo Library'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickImage(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Color(0xFF333742)),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickImage(context, ImageSource.camera);
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
    const Color textColor = Color(0xFF333742); // A soft black for text

    return Scaffold(
      // The AppBar is replaced with a simple icon button for a cleaner look
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: textColor, size: 30),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      // --- THIS IS THE FIX ---
      // 2. Add the AppDrawer to the Scaffold
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Main Title
            Text(
              'Urban Watch',
              style: GoogleFonts.playfairDisplay(
                fontSize: 42,
                fontWeight: FontWeight.normal,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            // Subtitle
            Text(
              'Your City, Your voice',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Color(0xFF68839E), // Replaced withOpacity(0.8)
              ),
            ),
            const SizedBox(height: 80),
            // Neumorphic Camera Button
            GestureDetector(
              onTap: () => _showPicker(context),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                  shape: BoxShape.circle,
                  boxShadow: [
                    // Darker shadow on the bottom right
                    BoxShadow(
                      color: Color.fromARGB(255, 136, 164, 192).withAlpha(90), // Replaced withOpacity(0.15)
                      offset: const Offset(6, 6),
                      blurRadius: 24,
                    ),
                    // Lighter shadow on the top left for the highlight effect
                    BoxShadow(
                      color: Colors.white.withAlpha(230), // Replaced withOpacity(0.9)
                      offset: const Offset(-6, -6),
                      blurRadius: 32,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.photo_camera_outlined,
                  size: 60,
                  color: Color(0xFF68839E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
