import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urbanwatch_mobile/screens/confirmation_screen.dart';
import 'package:urbanwatch_mobile/widgets/app_drawer.dart'; // 1. Import the AppDrawer

class IssueDetailScreen extends StatefulWidget {
  final File imageFile;
  final ImageSource imageSource;

  const IssueDetailScreen({
    super.key,
    required this.imageFile,
    required this.imageSource,
  });

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isLocationLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// Initializes the form fields automatically.
  Future<void> _initializeForm() async {
    // Auto-fetch location if the image was taken with the camera
    if (widget.imageSource == ImageSource.camera) {
      _getCurrentLocation();
    }
  }

  /// Gets the current GPS location and autofills the location field.
  Future<void> _getCurrentLocation() async {
    setState(() => _isLocationLoading = true);
    try {
      // First, check for permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _locationController.text = 'Location permissions are denied.';
          setState(() => _isLocationLoading = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _locationController.text = 'Location permissions are permanently denied.';
        setState(() => _isLocationLoading = false);
        return;
      }

      // If permissions are granted, get the location
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _locationController.text =
          'Lat: ${position.latitude.toStringAsFixed(4)}, Lon: ${position.longitude.toStringAsFixed(4)}';
    } catch (e) {
      _locationController.text = 'Could not get location: $e';
    } finally {
      setState(() => _isLocationLoading = false);
    }
  }

  /// Uploads an image file to Supabase Storage and returns the public URL.
  Future<String?> _uploadImageToSupabase(File imageFile) async {
    try {
      final supabase = Supabase.instance.client;
      final String fileName =
          'public/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage.from('issues_bucket').upload(fileName, imageFile);
      final String publicUrl =
          supabase.storage.from('issues_bucket').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint("Error uploading image to Supabase: $e");
      return null;
    }
  }

  /// Handles the final submission of the report.
  Future<void> _submitFinalReport() async {
    if (_locationController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isSubmitting = true);

    final imageUrl = await _uploadImageToSupabase(widget.imageFile);

    if (!mounted) return;

    if (imageUrl != null) {
      // TODO: Save all data to your database and get the real Report ID
      debugPrint('Image uploaded successfully! URL: $imageUrl');
      
      final now = DateTime.now();

      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (context) => ConfirmationScreen(
            // Using placeholder data for now
            reportId: 'RE1234ABC256',
            date: DateFormat.yMMMMd().format(now),
            time: DateFormat.jm().format(now),
          ),
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
            content: Text('Image upload failed. Please try again.'),
            backgroundColor: Colors.red),
      );
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    // Updated Colors
    const Color backgroundColor = Color(0xFFF1F5F9);
    const Color textColor = Color.fromARGB(255, 0, 0, 0);
    const Color buttonColor = Color(0xFF36597D);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: textColor, size: 30),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: textColor, size: 30),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      // --- THIS IS THE FIX ---
      // 2. Add the AppDrawer to the Scaffold
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview - Reduced height
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  widget.imageFile,
                  height: 220, // Reduced height
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24), // Reduced spacing

            // Location Field
            Text(
              'Location',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.normal, // Updated font weight
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _locationController,
              hintText: 'Enter location or use GPS',
              isLoading: _isLocationLoading,
              suffixIcon: IconButton(
                icon: const Icon(Icons.my_location, color: textColor),
                onPressed: _getCurrentLocation,
              ),
            ),
            const SizedBox(height: 16), // Reduced spacing

            // Description Field
            Text(
              'Description',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.normal, // Updated font weight
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _descriptionController,
              hintText: 'Describe the issue...',
              maxLines: 4, // Reduced max lines slightly
            ),
            const SizedBox(height: 24), // Reduced spacing

            // Submit Button
            if (_isSubmitting)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitFinalReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16), // Reduced padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.normal, // Updated font weight
                    ),
                  ),
                  child: const Text('Submit'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isLoading = false,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      // Use a standard font for the input text, overriding the theme.
      style: GoogleFonts.roboto(color: const Color(0xFF333742)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: const Color(0xFF333742).withAlpha(150)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A6572), width: 2),
        ),
        suffixIcon: isLoading
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : suffixIcon,
      ),
    );
  }
}
