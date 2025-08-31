import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorUtils {
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static String getReadableErrorMessage(String error) {
    // Convert technical errors to user-friendly messages
    if (error.toLowerCase().contains('network')) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (error.toLowerCase().contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (error.toLowerCase().contains('unauthorized') || error.toLowerCase().contains('401')) {
      return 'Session expired. Please login again.';
    } else if (error.toLowerCase().contains('server') || error.toLowerCase().contains('500')) {
      return 'Server error. Please try again later.';
    } else if (error.toLowerCase().contains('not found') || error.toLowerCase().contains('404')) {
      return 'Service not found. Please try again later.';
    } else {
      return error;
    }
  }
}
