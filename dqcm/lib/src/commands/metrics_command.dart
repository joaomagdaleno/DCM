import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import 'package:dqcm/metrics_analyzer.dart';

class MetricsCommand extends Command<int> {
  @override
  final name = 'metrics';

  @override
  final description = 'Calculate code metrics for the project.';

  MetricsCommand() {
    argParser.addOption(
      'directory',
      abbr: 'd',
      help: 'The directory to calculate metrics for.',
    );
  }

  @override
  Future<int> run() async {
    final directoryPath = argResults?['directory'] as String?;
    if (directoryPath == null) {
      print('Please provide a directory to calculate metrics for with the --directory option.');
      return 1;
    }
    final absolutePath = p.normalize(Directory(directoryPath).absolute.path);
    await calculateMetrics(absolutePath);
    return 0;
  }
}
