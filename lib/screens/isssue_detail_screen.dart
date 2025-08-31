import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:urbanwatch_mobile/providers/reports_provider.dart';
import 'package:urbanwatch_mobile/providers/location_provider.dart';
import 'package:urbanwatch_mobile/services/location_service.dart';
import 'package:urbanwatch_mobile/screens/confirmation_screen.dart';
import 'package:urbanwatch_mobile/widgets/app_drawer.dart';

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
    // Get location from the provider or auto-fetch if from camera
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    
    if (locationProvider.hasLocation) {
      // Use pre-loaded location
      _locationController.text = locationProvider.currentLocation!.address;
    } else if (widget.imageSource == ImageSource.camera) {
      // Auto-fetch location if the image was taken with the camera and no location available
      _getCurrentLocation();
    }
  }

  /// Gets the current GPS location and autofills the location field.
  Future<void> _getCurrentLocation() async {
    setState(() => _isLocationLoading = true);
    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      
      // Try to get location from provider first
      if (locationProvider.hasLocation) {
        _locationController.text = locationProvider.currentLocation!.address;
      } else {
        // Get fresh location
        await locationProvider.getCurrentLocation();
        if (locationProvider.hasLocation) {
          _locationController.text = locationProvider.currentLocation!.address;
        } else {
          _locationController.text = 'Could not get location';
        }
      }
    } catch (e) {
      _locationController.text = 'Could not get location: $e';
    } finally {
      setState(() => _isLocationLoading = false);
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
    final reportsProvider = Provider.of<ReportsProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    setState(() => _isSubmitting = true);

    try {
      // Get current location for the API
      LocationData? locationData = locationProvider.currentLocation;
      
      // If no location available, try to get it now
      if (locationData == null) {
        await locationProvider.getCurrentLocation();
        locationData = locationProvider.currentLocation;
        
        if (locationData == null) {
          // Use default coordinates if location fails
          debugPrint('Location error: No location available');
          locationData = LocationData(
            latitude: 22.3149, // Default to IIT KGP coordinates as fallback
            longitude: 87.3105,
            address: 'Default location',
          );
        }
      }

      // Submit report using the API service
      final success = await reportsProvider.submitReport(
        imageFile: widget.imageFile,
        lat: locationData.latitude,
        lon: locationData.longitude,
        address: locationData.address,
      );

      if (!mounted) return;

      if (success) {
        final now = DateTime.now();
        
        // Navigate to confirmation screen
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (context) => ConfirmationScreen(
              reportId: 'Submitted Successfully', // We'll get the actual ID from the API
              date: DateFormat.yMMMMd().format(now),
              time: DateFormat.jm().format(now),
            ),
          ),
        );
      } else {
        // Show error from the provider
        final errorMessage = reportsProvider.error ?? 'Failed to submit report';
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    // Updated Colors
    const Color backgroundColor = Color.fromARGB(255, 255, 255, 255);
    const Color textColor = Color.fromARGB(255, 0, 0, 0);
    const Color buttonColor = Color.fromARGB(255, 0, 0, 0);

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
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500, // Updated font weight
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
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500, // Updated font weight
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ), // Reduced padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.normal, // Updated font weight
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500, // Updated font weight
                      color: Colors.white,
                    ),
                  ),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
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
