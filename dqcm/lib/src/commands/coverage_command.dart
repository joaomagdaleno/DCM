import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dqcm/src/reporters/console_coverage_reporter.dart';
import 'package:dqcm/src/services/coverage_service.dart';

class CoverageCommand extends Command<int> {
  @override
  final name = 'coverage';

  @override
  final description = 'Checks code coverage and enforces a quality gate.';

  CoverageCommand() {
    argParser.addOption(
      'file',
      abbr: 'f',
      help: 'The path to the lcov.info file.',
    );
    argParser.addOption(
      'fail-under',
      abbr: 'u',
      help: 'The minimum coverage percentage to pass the quality gate.',
      defaultsTo: '80',
    );
  }

  @override
  Future<int> run() async {
    String? coverageFilePath = argResults?['file'] as String?;

    if (coverageFilePath == null) {
      print('No lcov.info file provided, running "flutter test --coverage"...');
      final process = await Process.run(
        'flutter',
        ['test', '--coverage'],
        workingDirectory: 'dqcm',
      );

      if (process.exitCode != 0) {
        print('Error running "flutter test --coverage":');
        print(process.stderr);
        return 1;
      }

      coverageFilePath = 'dqcm/coverage/lcov.info';
      if (!File(coverageFilePath).existsSync()) {
        print('Could not find lcov.info file at $coverageFilePath');
        return 1;
      }
    } else {
      if (!File(coverageFilePath).existsSync()) {
        print('Could not find lcov.info file at $coverageFilePath');
        return 1;
      }
    }

    print('Analyzing coverage from: $coverageFilePath');

    final coverageService = CoverageService();
    final report = await coverageService.calculateCoverage(coverageFilePath);

    final reporter = ConsoleCoverageReporter();
    reporter.report(report);

    final failUnder = double.parse(argResults!['fail-under'] as String);
    if (report.percentage < failUnder) {
      print('\nCoverage of ${report.percentage.toStringAsFixed(2)}% is below the threshold of $failUnder%');
      return 1;
    }

    print('Coverage is above the threshold of $failUnder%');
    return 0;
  }
}
