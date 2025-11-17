import 'package:dqcm/src/models/coverage_report.dart';

class ConsoleCoverageReporter {
  void report(CoverageReport report) {
    _printLine();
    print('File                               | Coverage | Lines');
    _printLine();
    for (final fileReport in report.fileReports) {
      final percentage = fileReport.percentage.toStringAsFixed(2).padLeft(6);
      final lines =
          '${fileReport.hitLines}/${fileReport.totalLines}'.padLeft(8);
      final path = fileReport.path.padRight(32);
      print('$path | $percentage% | $lines');
    }
    _printLine();
    final totalPercentage = report.percentage.toStringAsFixed(2).padLeft(6);
    final totalLines = '${report.hitLines}/${report.totalLines}'.padLeft(8);
    print('Total                              | $totalPercentage% | $totalLines');
    _printLine();
  }

  void _printLine() {
    print('-' * 55);
  }
}
