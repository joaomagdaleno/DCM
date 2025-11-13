import 'package:args/args.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:dqcm/dqcm.dart';
import 'package:dqcm/metrics_analyzer.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addCommand('analyze', ArgParser()
      ..addOption('directory', abbr: 'd', help: 'The directory to analyze.')
      ..addOption('reporter', abbr: 'r', help: 'The format to output results in.', allowed: ['console', 'json'], defaultsTo: 'console')
    )
    ..addCommand('metrics', ArgParser()
      ..addOption('directory', abbr: 'd', help: 'The directory to calculate metrics for.')
    );

  try {
    final results = parser.parse(arguments);
    final command = results.command;

    if (command?.name == 'analyze') {
      final directoryPath = command!['directory'] as String?;
      if (directoryPath == null) {
        print('Please provide a directory to analyze with the --directory option.');
        exit(1);
      }
      final reporterType = command['reporter'] as String;
      final absolutePath = p.normalize(Directory(directoryPath).absolute.path);

      final issues = await analyzeDirectory(absolutePath);

      final reporter = getReporter(reporterType);
      reporter.report(issues);

      if (issues.isNotEmpty) {
        exit(1);
      }
    } else if (command?.name == 'metrics') {
      final directoryPath = command!['directory'] as String?;
      if (directoryPath == null) {
        print('Please provide a directory to calculate metrics for with the --directory option.');
        exit(1);
      }
      final absolutePath = p.normalize(Directory(directoryPath).absolute.path);
      await calculateMetrics(absolutePath);
    } else {
      printUsage(parser);
    }
  } on FormatException catch (e) {
    print(e.message);
    printUsage(parser);
    exit(1);
  }
}

void printUsage(ArgParser parser) {
  print('Usage: dcm_clone <command> [options]');
  print('\nCommands:');
  print('  analyze    Analyze the project for lint issues.');
  print('  metrics    Calculate code metrics for the project.');
  print('\n${parser.usage}');
}
