import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urbanwatch_mobile/models/api_models.dart';
import 'package:urbanwatch_mobile/widgets/report_card.dart';

class ReportDetailScreen extends StatelessWidget {
  final Report report;

  const ReportDetailScreen({super.key, required this.report});

  // Helper method to get the color based on the status
  Color _getStatusColor() {
    switch (report.status) {
      case ReportStatus.unresolved:
        return const Color(0xFFF8D7DA); // Light Red
      case ReportStatus.inProgress:
        return const Color(0xFFFFF3CD); // Light Yellow
      case ReportStatus.resolved:
        return const Color(0xFFD4EDDA); // Light Green
    }
  }

  // Helper method to get the text color for the status
  Color _getStatusTextColor() {
    switch (report.status) {
      case ReportStatus.unresolved:
        return const Color(0xFFD7524D); // Dark Red
      case ReportStatus.inProgress:
        return const Color.fromARGB(255, 223, 174, 29); // Dark Yellow
      case ReportStatus.resolved:
        return const Color.fromARGB(255, 32, 182, 67); // Dark Green
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color.fromARGB(255, 255, 255, 255);
    const Color textColor = Color.fromARGB(255, 0, 0, 0);
    const Color buttonColor = Color(0xFF000000);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Report',
          style: GoogleFonts.playfairDisplay(
            color: textColor,
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: textColor),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Report Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      report.title,
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${report.date}, ${report.time}',
                                      style: GoogleFonts.inter(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  report.status.name,
                                  style: GoogleFonts.inter(
                                    color: _getStatusTextColor(),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Image
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade100,
                            ),
                            child: report.imageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      report.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey.shade300,
                                          child: const Center(child: Text('Image not available')),
                                        );
                                      },
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey.shade300,
                                    child: const Center(child: Text('Image not available')),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow('Location :', report.location.address),
                          const SizedBox(height: 12),
                          _buildDetailRow('Description :', 
                            report.description.trim().isNotEmpty ? report.description : 'No description available'),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          _buildCriticalityScore(report.criticalityScore),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Back button with proper spacing
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCriticalityScore(int score) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Criticality Score:',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red.shade600,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            score.toString(),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
