import 'dart:io';

import 'package:dqcm/src/models/coverage_report.dart';
import 'package:dqcm/src/models/file_coverage.dart';

class CoverageService {
  Future<CoverageReport> calculateCoverage(String lcovPath) async {
    final file = File(lcovPath);
    if (!await file.exists()) {
      throw Exception('lcov.info file not found at $lcovPath');
    }

    final lines = await file.readAsLines();
    final fileReports = <FileCoverage>[];
    String currentFile = '';
    int totalLines = 0;
    int hitLines = 0;

    for (final line in lines) {
      if (line.startsWith('SF:')) {
        if (currentFile.isNotEmpty) {
          fileReports.add(FileCoverage(
            path: currentFile,
            totalLines: totalLines,
            hitLines: hitLines,
          ));
        }
        currentFile = line.substring(3);
        totalLines = 0;
        hitLines = 0;
      } else if (line.startsWith('DA:')) {
        totalLines++;
        final parts = line.substring(3).split(',');
        if (parts.length > 1 && int.tryParse(parts[1]) != 0) {
          hitLines++;
        }
      } else if (line == 'end_of_record') {
        if (currentFile.isNotEmpty) {
          fileReports.add(FileCoverage(
            path: currentFile,
            totalLines: totalLines,
            hitLines: hitLines,
          ));
        }
        currentFile = '';
      }
    }

    return CoverageReport(fileReports: fileReports);
  }
}
