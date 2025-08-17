import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 1. Import Supabase

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
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  bool _isAILoading = false;
  bool _isLocationLoading = false;
  bool _isSubmitting = false; // For the final submission loading state

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  /// Initializes the form fields automatically.
  Future<void> _initializeForm() async {
    final now = DateTime.now();
    _dateController.text = DateFormat.yMMMMd().format(now);
    _timeController.text = DateFormat.jm().format(now);
    _fetchAIDetails();
    if (widget.imageSource == ImageSource.camera) {
      _getCurrentLocation();
    }
  }

  /// Fetches title and description from the placeholder AI service.
  Future<void> _fetchAIDetails() async {
    setState(() => _isAILoading = true);
    final apiBaseUrl = dotenv.env['AI_API_BASE_URL'];
    if (apiBaseUrl == null || apiBaseUrl.isEmpty) {
      _titleController.text = "API URL not found";
      _descriptionController.text = "Please check your .env file setup.";
      setState(() => _isAILoading = false);
      return;
    }
    // Using a fake response for now
    await Future.delayed(const Duration(seconds: 2));
    _titleController.text = "Overflowing Public Bin";
    _descriptionController.text = "Public trash bin is full and needs to be emptied.";
    setState(() => _isAILoading = false);
  }

  /// Gets the current GPS location and autofills the location field.
  Future<void> _getCurrentLocation() async {
    setState(() => _isLocationLoading = true);
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _locationController.text = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lon: ${position.longitude.toStringAsFixed(4)}';
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
      final String fileName = 'public/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage.from('issues_bucket').upload(fileName, imageFile);
      final String publicUrl = supabase.storage.from('issues_bucket').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print("Error uploading image to Supabase: $e");
      return null;
    }
  }

  /// Handles the final submission of the report.
  Future<void> _submitFinalReport() async {
    // --- THIS IS THE FIX ---
    // Capture the context-dependent objects before the async gap.
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isSubmitting = true);

    final imageUrl = await _uploadImageToSupabase(widget.imageFile);

    // Now, use the captured objects. The 'mounted' check is still good practice.
    if (!mounted) return;

    if (imageUrl != null) {
      print('Image uploaded successfully! URL: $imageUrl');
      // TODO: Here you would save all the form data (title, description, location, imageUrl) to your database (e.g., Supabase database).
      
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Report submitted successfully!'), backgroundColor: Colors.green),
      );
      navigator.pop(); // Go back to the home screen
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Image upload failed. Please try again.'), backgroundColor: Colors.red),
      );
    }

    setState(() => _isSubmitting = false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Issue Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(widget.imageFile, height: 250, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 24),
            _buildTextField(controller: _titleController, label: 'Title', icon: Icons.title, isLoading: _isAILoading),
            const SizedBox(height: 16),
            _buildTextField(controller: _descriptionController, label: 'Description', icon: Icons.description, isLoading: _isAILoading, maxLines: 4),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _locationController,
              label: 'Location',
              icon: Icons.location_on,
              isLoading: _isLocationLoading,
              suffixIcon: widget.imageSource == ImageSource.gallery ? IconButton(icon: const Icon(Icons.my_location), onPressed: _getCurrentLocation) : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField(controller: _dateController, label: 'Date', icon: Icons.calendar_today, readOnly: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(controller: _timeController, label: 'Time', icon: Icons.access_time, readOnly: true)),
              ],
            ),
            const SizedBox(height: 32),
            if (_isSubmitting)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Submit Final Report'),
                onPressed: _submitFinalReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool isLoading = false, bool readOnly = false, int maxLines = 1, Widget? suffixIcon}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isLoading ? const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2)) : suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }
}
