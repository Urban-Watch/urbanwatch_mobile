import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urbanwatch_mobile/main.dart';
import 'package:urbanwatch_mobile/models/report_model.dart';
import 'package:urbanwatch_mobile/screens/report_detail_screen.dart';
import 'package:urbanwatch_mobile/widgets/app_drawer.dart';
import 'package:urbanwatch_mobile/widgets/report_card.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- THIS IS THE FIX ---
    // Updated placeholder data to use the Report model
    final List<Report> reports = [
      Report(
        id: 1,
        title: 'Deep Pothole Near School',
        location: 'D130 RK hall of residence, IIT KGP, Kharagpur 721302',
        date: '20 August 2025',
        time: '9:56 AM',
        status: ReportStatus.Unresolved,
        imageUrl: 'https://placehold.co/600x400/cccccc/000000?text=Issue+Image',
        description: 'A large and dangerous pothole has formed on the main road just outside the school gate. It poses a significant risk to students and vehicles.',
        criticalityScore: 82,
      ),
      Report(
        id: 2,
        title: 'Broken Streetlight',
        location: 'Park Avenue',
        date: '17 August 2025',
        time: '11:00 PM',
        status: ReportStatus.InProgress,
        imageUrl: 'https://placehold.co/600x400/cccccc/000000?text=Issue+Image',
        description: 'The streetlight on the corner of Park Avenue has been out for three days, making the area very dark and unsafe at night.',
        criticalityScore: 65,
      ),
      Report(
        id: 3,
        title: 'Overflowing Dumpster',
        location: 'Oak Lane',
        date: '15 August 2025',
        time: '2:15 PM',
        status: ReportStatus.Resolved,
        imageUrl: 'https://placehold.co/600x400/cccccc/000000?text=Issue+Image',
        description: 'The public dumpster on Oak Lane is overflowing with trash, causing a foul smell and attracting pests.',
        criticalityScore: 70,
      ),
    ];

    const Color backgroundColor = Color.fromARGB(255, 252, 252, 252); // Using consistent background color
    const Color textColor = Color.fromARGB(255, 0, 0, 0);
    const Color buttonColor = Color(0xFF000000);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'My Reports',
          style: GoogleFonts.playfairDisplay(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: textColor),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  // --- THIS IS THE FIX ---
                  // Wrapped ReportCard with GestureDetector to make it clickable
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportDetailScreen(report: report),
                        ),
                      );
                    },
                    child: ReportCard(
                      index: report.id,
                      title: report.title,
                      location: report.location,
                      submissionDate: report.date,
                      submissionTime: report.time,
                      status: report.status,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
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
                    textStyle: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('Back'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
