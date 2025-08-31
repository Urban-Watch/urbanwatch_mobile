import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:urbanwatch_mobile/main.dart';
import 'package:urbanwatch_mobile/providers/reports_provider.dart';
import 'package:urbanwatch_mobile/screens/report_detail_screen.dart';
import 'package:urbanwatch_mobile/widgets/app_drawer.dart';
import 'package:urbanwatch_mobile/widgets/report_card.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch reports when the screen loads with force refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportsProvider>(context, listen: false).fetchReports(forceRefresh: true);
    });
  }

  // Add refresh method
  Future<void> _onRefresh() async {
    await Provider.of<ReportsProvider>(context, listen: false).fetchReports(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color.fromARGB(255, 252, 252, 252);
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Consumer<ReportsProvider>(
          builder: (context, reportsProvider, child) {
            if (reportsProvider.isLoading && reportsProvider.reports.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (reportsProvider.error != null && reportsProvider.reports.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading reports',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reportsProvider.error!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.red.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        reportsProvider.fetchReports();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (reportsProvider.reports.isEmpty) {
              return Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.report_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No reports yet',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start reporting issues in your community',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: textColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 40.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
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
              );
            }

            return Column(
              children: [
                const SizedBox(height: 16),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      itemCount: reportsProvider.reports.length + (reportsProvider.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == reportsProvider.reports.length) {
                          // Loading indicator at the bottom
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final report = reportsProvider.reports[index];
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
                            location: report.location.address,
                            submissionDate: report.date,
                            submissionTime: report.time,
                            status: report.status,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 40.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
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
            );
          },
        ),
        ),
      ),
    );
  }
}
