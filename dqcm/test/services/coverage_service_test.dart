import 'dart:io';

import 'package:dqcm/src/services/coverage_service.dart';
import 'package:test/test.dart';

void main() {
  group('CoverageService', () {
    test('calculateCoverage returns correct report for valid lcov file',
        () async {
      final lcovContent = """
SF:lib/src/commands/analyze_command.dart
DA:1,1
DA:3,1
DA:5,1
DA:7,1
DA:9,1
DA:11,1
DA:13,1
DA:15,1
DA:17,1
DA:20,1
DA:21,1
DA:22,1
DA:24,1
DA:26,1
DA:28,1
DA:30,1
DA:32,1
DA:34,1
end_of_record
SF:lib/src/commands/coverage_command.dart
DA:1,0
DA:3,0
DA:5,0
DA:7,0
DA:9,0
DA:11,0
DA:13,0
DA:15,0
DA:17,0
DA:20,0
DA:21,0
DA:23,0
DA:25,0
DA:27,0
DA:29,0
DA:31,0
DA:33,0
DA:35,0
DA:37,0
DA:39,0
DA:41,0
DA:43,0
DA:45,0
DA:47,0
DA:49,0
DA:51,0
DA:53,0
DA:55,0
DA:57,0
DA:59,0
DA:61,0
DA:63,0
DA:65,0
DA:67,0
end_of_record
""";
      final lcovFile = File('test/fixtures/lcov.info');
      await lcovFile.parent.create(recursive: true);
      await lcovFile.writeAsString(lcovContent);

      final service = CoverageService();
      final report = await service.calculateCoverage(lcovFile.path);

      expect(report.percentage, closeTo(34.61, 0.01));
      expect(report.fileReports.length, 2);
      expect(report.fileReports[0].path,
          'lib/src/commands/analyze_command.dart');
      expect(report.fileReports[0].percentage, 100.0);
      expect(report.fileReports[1].path,
          'lib/src/commands/coverage_command.dart');
      expect(report.fileReports[1].percentage, 0.0);

      await lcovFile.delete();
    });
  });
}
