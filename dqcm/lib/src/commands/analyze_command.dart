import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:dqcm/dqcm.dart';

class AnalyzeCommand extends Command {
  @override
  String get name => 'analyze';

  @override
  String get description => 'Analyze the project for lint issues.';

  AnalyzeCommand() {
    argParser.addOption(
      'directory',
      abbr: 'd',
      help: 'The directory to analyze.',
      defaultsTo: '.',
    );
    argParser.addOption(
      'reporter',
      abbr: 'r',
      help: 'The format to output results in.',
      allowed: ['console', 'json'],
      defaultsTo: 'console',
    );
  }

  @override
  Future<void> run() async {
    final directoryPath = argResults!['directory'] as String;
    final reporterType = argResults!['reporter'] as String;
    final absolutePath = p.normalize(Directory(directoryPath).absolute.path);

    final issues = await analyzeDirectory(absolutePath);

    final reporter = getReporter(reporterType);
    reporter.report(issues);

    if (issues.isNotEmpty) {
      exit(2); // Use a specific exit code for lint issues
    }
  }
}
