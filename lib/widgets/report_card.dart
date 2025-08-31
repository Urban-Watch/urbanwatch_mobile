import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Enum to represent the status of a report
enum ReportStatus { 
  unresolved, 
  inProgress, 
  resolved;

  String get apiValue {
    switch (this) {
      case ReportStatus.unresolved:
        return 'waiting_for_attention';
      case ReportStatus.inProgress:
        return 'got_the_attention';
      case ReportStatus.resolved:
        return 'resolved';
    }
  }

  // For backward compatibility with existing UI
  String get name {
    switch (this) {
      case ReportStatus.unresolved:
        return 'Unresolved';
      case ReportStatus.inProgress:
        return 'InProgress';
      case ReportStatus.resolved:
        return 'Resolved';
    }
  }

  static ReportStatus fromString(String value) {
    switch (value) {
      case 'waiting_for_attention':
        return ReportStatus.unresolved;
      case 'got_the_attention':
        return ReportStatus.inProgress;
      case 'resolved':
        return ReportStatus.resolved;
      default:
        return ReportStatus.unresolved;
    }
  }
}

class ReportCard extends StatelessWidget {
  final int index;
  final String title;
  final String location;
  final String submissionDate;
  final String submissionTime;
  final ReportStatus status;

  const ReportCard({
    super.key,
    required this.index,
    required this.title,
    required this.location,
    required this.submissionDate,
    required this.submissionTime,
    required this.status,
  });

  // Helper method to get the text color for the status
  Color _getStatusTextColor() {
    switch (status) {
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Details section
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Column(
              children: [
                // --- THIS IS THE FIX ---
                // The status is now just a colored Text widget without the background container.
                _buildDetailRow(
                  'Status',
                  Text(
                    status.name, // e.g., "InProgress"
                    style: GoogleFonts.inter(
                      color: _getStatusTextColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                _buildDetailRow('Location', Text(location)),
                const SizedBox(height: 6),
                _buildDetailRow('Date', Text(submissionDate)),
                const SizedBox(height: 6),
                _buildDetailRow('Time', Text(submissionTime)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Updated to accept a Widget for the value, allowing for the status tag
  Widget _buildDetailRow(String label, Widget valueWidget) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120, // Fixed width for labels to ensure alignment
          child: Text(
            '$label : ',
            style: GoogleFonts.inter(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: DefaultTextStyle(
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 14,
            ),
            child: valueWidget,
          ),
        ),
      ],
    );
  }
}
