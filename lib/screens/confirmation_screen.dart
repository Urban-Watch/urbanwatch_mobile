import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urbanwatch_mobile/main.dart'; // Import your main.dart to access the home screen

class ConfirmationScreen extends StatelessWidget {
  final String reportId;
  final String date;
  final String time;

  const ConfirmationScreen({
    super.key,
    required this.reportId,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFF1F5F9);
    const Color textColor = Color.fromARGB(255, 0, 0, 0);
    const Color buttonColor = Color(0xFF36597D);
    const Color checkCircleColor = Color(0xFFB8CCE0);

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
        automaticallyImplyLeading: false, // Removes the default back button
      ),
      drawer: const Drawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              'Issue Reported!',
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.normal,
                color: textColor,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: checkCircleColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 70,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Thank you reporting.',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.normal,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You're making a real\ndifference in your community",
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                color: textColor.withAlpha(110),
              ),
            ),
            const Spacer(),
            _buildReportDetailRow('Report ID :', reportId),
            const SizedBox(height: 8),
            _buildReportDetailRow('Date :', date),
            const SizedBox(height: 8),
            _buildReportDetailRow('Time :', time),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the home screen and remove all previous routes
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const ReportLauncherScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReportDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 16,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ],
    );
  }
}
