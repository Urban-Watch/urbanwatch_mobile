import 'package:urbanwatch_mobile/widgets/report_card.dart'; // We need this for the ReportStatus enum

class Report {
  final int id;
  final String title;
  final String location;
  final String date;
  final String time;
  final ReportStatus status;
  final String imageUrl;
  final String description;
  final int criticalityScore;

  Report({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.time,
    required this.status,
    required this.imageUrl,
    required this.description,
    required this.criticalityScore,
  });
}
