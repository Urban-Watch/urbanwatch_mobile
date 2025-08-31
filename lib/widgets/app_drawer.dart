import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:urbanwatch_mobile/providers/auth_provider.dart';
import 'package:urbanwatch_mobile/screens/my_reports_screen.dart';
import 'package:urbanwatch_mobile/screens/login_screen.dart';

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
              Navigator.pop(context); // Close the drawer first
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyReportsScreen()),
              );
            },
          ),
          // Logout option
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text(
              'Logout',
              style: GoogleFonts.inter(
                color: Colors.red.shade700,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            leading: Icon(
              Icons.logout,
              color: Colors.red.shade700,
            ),
            onTap: () async {
              Navigator.pop(context); // Close the drawer first
              
              // Show confirmation dialog
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        print("Hello world Logout is pressed ");
                        Navigator.pop(context, true);
                      },
                      child: Text(
                        'Logout',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && context.mounted) {
                try {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.logout();
                  
                  // Debug logging
                  print('🔐 AUTH: Logout completed, navigating to login screen');
                  
                  // Force navigation to login screen
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                    );
                  }
                } catch (e) {
                  print('🔐 AUTH: Logout error: $e');
                  // Show error message to user
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Logout failed: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          ),
          // Add other drawer items here if needed
        ],
      ),
    );
  }
}
