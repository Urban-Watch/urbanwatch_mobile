import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color.fromARGB(255, 0, 0, 0);

    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF36597D),
            ),
            child: Text(
              'UrbanWatch',
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.report,
              color: textColor,
            ),
            title: Text(
              'Your Reports',
              style: GoogleFonts.roboto(
                color: textColor,
                fontSize: 16,
              ),
            ),
            onTap: () {
              // TODO: Navigate to the "Your Reports" screen
              // For now, just close the drawer
              Navigator.pop(context);
            },
          ),
          // Add other drawer items here
        ],
      ),
    );
  }
}
