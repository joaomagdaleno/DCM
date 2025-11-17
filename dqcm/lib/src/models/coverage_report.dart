import 'file_coverage.dart';

class CoverageReport {
  final List<FileCoverage> fileReports;

  CoverageReport({required this.fileReports});

  int get totalLines =>
      fileReports.fold(0, (sum, report) => sum + report.totalLines);

  int get hitLines =>
      fileReports.fold(0, (sum, report) => sum + report.hitLines);

  double get percentage => totalLines > 0 ? (hitLines / totalLines) * 100 : 0.0;
}
