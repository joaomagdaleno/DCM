import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:dqcm/metrics_analyzer.dart';

class MetricsCommand extends Command {
  @override
  String get name => 'metrics';

  @override
  String get description => 'Calculate code metrics for the project.';

  MetricsCommand() {
    argParser.addOption(
      'directory',
      abbr: 'd',
      help: 'The directory to calculate metrics for.',
      defaultsTo: '.',
    );
  }

  @override
  Future<void> run() async {
    final directoryPath = argResults!['directory'] as String;
    final absolutePath = p.normalize(Directory(directoryPath).absolute.path);
    await calculateMetrics(absolutePath);
  }
}
