import 'package:args/args.dart';
import 'dart:io';
import 'package:dcm_clone/dcm_clone.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addCommand('analyze', ArgParser()
      ..addOption('directory', abbr: 'd', help: 'The directory to analyze.')
      ..addOption('reporter', abbr: 'r', help: 'The format to output results in.', allowed: ['console', 'json'], defaultsTo: 'console')
    );

  try {
    final results = parser.parse(arguments);

    if (results.command?.name == 'analyze') {
      final commandResults = results.command!;
      final directoryPath = commandResults['directory'] as String?;
      if (directoryPath == null) {
        print('Please provide a directory to analyze with the --directory option.');
        exit(1);
      }
      final reporter = commandResults['reporter'] as String;
      final absoluteDirectoryPath = Directory(directoryPath).absolute.path;
      await analyzeDirectory(absoluteDirectoryPath, reporter);
    } else {
      print('Usage: dcm_clone analyze --directory <path> [--reporter=console|json]');
    }
  } on FormatException catch (e) {
    print(e.message);
    print('Usage: dcm_clone analyze --directory <path>');
    exit(1);
  }
}
