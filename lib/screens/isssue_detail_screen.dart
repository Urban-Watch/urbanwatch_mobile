import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 1. Import the package
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
    // 1. Autofill Date and Time
    final now = DateTime.now();
    _dateController.text = DateFormat.yMMMMd().format(now);
    _timeController.text = DateFormat.jm().format(now);

    // 2. Fetch AI details for title and description
    _fetchAIDetails();

    // 3. Autofill location if the image was taken with the camera
    if (widget.imageSource == ImageSource.camera) {
      _getCurrentLocation();
    }
  }

  /// Fetches title and description from the placeholder AI service.
  Future<void> _fetchAIDetails() async {
    setState(() {
      _isAILoading = true;
    });

    // 2. Access the variable from the .env file
    final apiBaseUrl = dotenv.env['AI_API_BASE_URL'];

    // Check if the URL is null or empty, which would happen if the .env file is not set up correctly
    if (apiBaseUrl == null || apiBaseUrl.isEmpty) {
        _titleController.text = "API URL not found";
        _descriptionController.text = "Please check your .env file setup.";
        setState(() {
          _isAILoading = false;
        });
        return;
    }

    var uri = Uri.parse('$apiBaseUrl/analyze'); // 3. Use the variable here

    try {
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath(
          'image',
          widget.imageFile.path,
        ));

      // In a real scenario, you would await the response.
      // For this placeholder, we'll simulate a delay and a fake response.
      await Future.delayed(const Duration(seconds: 2));

      // --- FAKE AI RESPONSE ---
      // When your server is ready, you will replace this with the actual response.
      final fakeResponse = {
        "title": "Overflowing Public Bin",
        "description": "Public trash bin located near the park entrance is full and needs to be emptied. Debris is spilling onto the sidewalk."
      };
      
      _titleController.text = fakeResponse['title']!;
      _descriptionController.text = fakeResponse['description']!;

    } catch (e) {
      // In case of a real network error
      _titleController.text = "Error fetching title";
      _descriptionController.text = "Could not connect to AI service: $e";
    } finally {
      setState(() {
        _isAILoading = false;
      });
    }
  }

  /// Gets the current GPS location and autofills the location field.
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocationLoading = true;
    });
    
    try {
      // Permissions are assumed to be handled from the first screen, but a robust app would check again.
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      // For a real app, you would use a reverse geocoding service to get the address.
      // For now, we'll just use the coordinates.
      _locationController.text = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lon: ${position.longitude.toStringAsFixed(4)}';
    } catch (e) {
      _locationController.text = 'Could not get location: $e';
    } finally {
      setState(() {
        _isLocationLoading = false;
      });
    }
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
            // --- Image Preview ---
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                widget.imageFile,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),

            // --- Form Fields ---
            _buildTextField(
              controller: _titleController,
              label: 'Title',
              icon: Icons.title,
              isLoading: _isAILoading,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              icon: Icons.description,
              isLoading: _isAILoading,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _locationController,
              label: 'Location',
              icon: Icons.location_on,
              isLoading: _isLocationLoading,
              suffixIcon: widget.imageSource == ImageSource.gallery
                  ? IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: _getCurrentLocation,
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _dateController,
                    label: 'Date',
                    icon: Icons.calendar_today,
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _timeController,
                    label: 'Time',
                    icon: Icons.access_time,
                    readOnly: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- Submit Button ---
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('Submit Final Report'),
              onPressed: () {
                // TODO: Implement final submission logic
                print('Submitting final report...');
                Navigator.of(context).pop(); // Go back to the home screen
              },
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

  /// Helper widget for creating styled text fields.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isLoading = false,
    bool readOnly = false,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isLoading ? const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ) : suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
    );
  }
}
