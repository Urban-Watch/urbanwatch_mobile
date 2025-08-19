import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urbanwatch_mobile/screens/my_reports_screen.dart'; // 1. Import the new screen

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color.fromARGB(255, 0, 0, 0);

    return Drawer(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Set a light background for the drawer body
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          // Updated DrawerHeader to match the new design
          Container(
            height: 150, // Give the header a fixed height
            color: Colors.black,
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            alignment: Alignment.bottomLeft,
            child: Text(
              'UrbanWatch',
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          // Updated ListTile for "Your Reports"
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text(
              'Your Reports',
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              // 2. Navigate to the "Your Reports" screen
              Navigator.pop(context); // Close the drawer first
              // Use pushReplacement to avoid stacking the same screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyReportsScreen()),
              );
            },
          ),
          // Add other drawer items here if needed
        ],
      ),
    );
  }
}
