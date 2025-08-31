import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:urbanwatch_mobile/screens/isssue_detail_screen.dart';
import 'package:urbanwatch_mobile/screens/login_screen.dart';
import 'package:urbanwatch_mobile/providers/auth_provider.dart';
import 'package:urbanwatch_mobile/providers/reports_provider.dart';
import 'package:urbanwatch_mobile/providers/location_provider.dart';
import 'package:urbanwatch_mobile/services/location_service.dart';
import 'package:urbanwatch_mobile/config/app_config.dart';
import 'package:urbanwatch_mobile/widgets/app_drawer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Log app configuration
  AppConfig.logConfig();

  runApp(const UrbanWatchApp());
}

class UrbanWatchApp extends StatelessWidget {
  const UrbanWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ReportsProvider()),
        ChangeNotifierProvider(create: (context) => LocationProvider()),
      ],
      child: MaterialApp(
        title: 'UrbanWatch',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Using Playfair Display as the default font family
          fontFamily: GoogleFonts.playfairDisplay().fontFamily,
          scaffoldBackgroundColor: Colors.white, // Neumorphic background
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            // Show loading screen while checking authentication status
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            // Add debug logging for authentication state
            if (kDebugMode) {
              print('🔐 AUTH: isLoggedIn=${authProvider.isLoggedIn}, user=${authProvider.user?.name ?? 'null'}');
            }
            
            // Navigate based on authentication status
            return authProvider.isLoggedIn 
                ? const ReportLauncherScreen()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}

class ReportLauncherScreen extends StatefulWidget {
  const ReportLauncherScreen({super.key});

  @override
  State<ReportLauncherScreen> createState() => _ReportLauncherScreenState();
}

class _ReportLauncherScreenState extends State<ReportLauncherScreen> {
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize location when home screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      locationProvider.initializeLocation();
    });
  }

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
                  await _pickImageAndSubmit(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Color(0xFF333742)),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickImageAndSubmit(context, ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// One-click image picking and submission
  Future<void> _pickImageAndSubmit(BuildContext context, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    
    try {
      // Pick image
      final XFile? image = await picker.pickImage(source: source);
      if (image == null) return;

      setState(() => _isSubmitting = true);

      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Submitting your report...',
                  style: GoogleFonts.inter(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Getting location and uploading image',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final reportsProvider = Provider.of<ReportsProvider>(context, listen: false);
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      
      // Submit report with current location
      final success = await _submitReportWithLocation(File(image.path), reportsProvider, locationProvider);
      
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        if (success) {
          _showSuccessDialog();
        } else {
          _showErrorDialog(reportsProvider.error ?? 'Failed to submit report');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog if open
        _showErrorDialog('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<bool> _submitReportWithLocation(File imageFile, ReportsProvider reportsProvider, LocationProvider locationProvider) async {
    try {
      // Check if we have location from the provider
      LocationData? locationData = locationProvider.currentLocation;
      
      // If no location available, try to get it now
      if (locationData == null) {
        await locationProvider.getCurrentLocation();
        locationData = locationProvider.currentLocation;
        
        if (locationData == null) {
          throw Exception('Unable to get location. Please enable location services.');
        }
      }

      // Submit report
      return await reportsProvider.submitReport(
        imageFile: imageFile,
        lat: locationData.latitude,
        lon: locationData.longitude,
        address: locationData.address,
      );
    } catch (e) {
      throw Exception('Location error: ${e.toString()}');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle,
          color: Colors.green.shade600,
          size: 48,
        ),
        title: Text(
          'Report Submitted!',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Thank you for reporting. Your submission helps make the community better.',
          style: GoogleFonts.inter(),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.error,
          color: Colors.red.shade600,
          size: 48,
        ),
        title: Text(
          'Submission Failed',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          error,
          style: GoogleFonts.inter(),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Try Again',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
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
      // Add the AppDrawer to the Scaffold
      drawer: const AppDrawer(),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          return Column(
            children: [
              // Location display at the top
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: locationProvider.isLoading 
                          ? Colors.grey.shade400 
                          : (locationProvider.hasLocation ? Colors.green.shade600 : Colors.red.shade600),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: locationProvider.isLoading
                          ? Row(
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Getting location...',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              locationProvider.hasLocation
                                  ? locationProvider.currentLocation!.address
                                  : 'Location unavailable',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: locationProvider.hasLocation 
                                    ? Colors.grey.shade700
                                    : Colors.red.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                    if (!locationProvider.isLoading)
                      IconButton(
                        onPressed: () => locationProvider.refreshLocation(),
                        icon: Icon(
                          Icons.refresh,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
              // Main content
              Expanded(
                child: Center(
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
                          color: Color(0xFF68839E),
                        ),
                      ),
                      const SizedBox(height: 80),
                      // Neumorphic Camera Button
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          GestureDetector(
                            onTap: (_isSubmitting || locationProvider.isLoading || !locationProvider.hasLocation) 
                                ? null 
                                : () => _showPicker(context),
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                color: (_isSubmitting || locationProvider.isLoading || !locationProvider.hasLocation) 
                                    ? Colors.grey.shade300 
                                    : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  // Darker shadow on the bottom right
                                  BoxShadow(
                                    color: Color.fromARGB(255, 136, 164, 192).withAlpha(90),
                                    offset: const Offset(6, 6),
                                    blurRadius: 24,
                                  ),
                                  // Lighter shadow on the top left for the highlight effect
                                  BoxShadow(
                                    color: Colors.white.withAlpha(230),
                                    offset: const Offset(-6, -6),
                                    blurRadius: 32,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.photo_camera_outlined,
                                size: 60,
                                color: (_isSubmitting || locationProvider.isLoading || !locationProvider.hasLocation) 
                                    ? Colors.grey.shade600 
                                    : const Color(0xFF68839E),
                              ),
                            ),
                          ),
                          if (_isSubmitting)
                            const CircularProgressIndicator()
                          else if (locationProvider.isLoading)
                            SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        locationProvider.isLoading 
                            ? 'Getting your location...'
                            : !locationProvider.hasLocation
                                ? 'Location required to report'
                                : 'Tap to report an issue',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: (!locationProvider.hasLocation && !locationProvider.isLoading)
                              ? Colors.red.shade600
                              : textColor.withOpacity(0.7),
                        ),
                      ),
                      if (_isSubmitting)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Submitting report...',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      if (locationProvider.error != null && !locationProvider.isLoading)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            children: [
                              Text(
                                'Location error: ${locationProvider.error}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.red.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              TextButton(
                                onPressed: () => locationProvider.refreshLocation(),
                                child: Text(
                                  'Retry',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.blue.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
