import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import 'package:dqcm/dqcm.dart';

class AnalyzeCommand extends Command<int> {
  @override
  final name = 'analyze';

  @override
  final description = 'Analyze the project for lint issues.';

  AnalyzeCommand() {
    argParser.addOption(
      'directory',
      abbr: 'd',
      help: 'The directory to analyze.',
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
  Future<int> run() async {
    final directoryPath = argResults?['directory'] as String?;
    if (directoryPath == null) {
      print('Please provide a directory to analyze with the --directory option.');
      return 1;
    }
    final reporterType = argResults?['reporter'] as String ?? 'console';
    final absolutePath = p.normalize(Directory(directoryPath).absolute.path);

    final issues = await analyzeDirectory(absolutePath);

    final reporter = getReporter(reporterType);
    reporter.report(issues);

    if (issues.isNotEmpty) {
      return 1;
    }

    return 0;
  }
}
