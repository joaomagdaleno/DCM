import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dqcm/src/commands/analyze_command.dart';
import 'package:dqcm/src/commands/coverage_command.dart';
import 'package:dqcm/src/commands/metrics_command.dart';

Future<void> main(List<String> arguments) async {
  final runner = CommandRunner<int>('dqcm', 'Dart Quality Control Metrics')
    ..addCommand(AnalyzeCommand())
    ..addCommand(MetricsCommand())
    ..addCommand(CoverageCommand());

  try {
    final exitCode = await runner.run(arguments);
    exit(exitCode ?? 0);
  } catch (e) {
    print(e);
    exit(1);
  }
}
