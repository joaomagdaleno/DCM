import 'package:args/command_runner.dart';
import 'package:dqcm/src/commands/analyze_command.dart';
import 'package:dqcm/src/commands/metrics_command.dart';
import 'package:dqcm/src/commands/sca_command.dart';

Future<void> main(List<String> arguments) async {
  final runner = CommandRunner(
    'dqcm',
    'A Dart Quality Control Metrics tool.',
  )
    ..addCommand(AnalyzeCommand())
    ..addCommand(MetricsCommand())
    ..addCommand(ScaCommand());

  await runner.run(arguments);
}
