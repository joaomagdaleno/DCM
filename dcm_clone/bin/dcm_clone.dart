import 'package:args/args.dart';
import 'dart:io';
import 'package:dcm_clone/dcm_clone.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addCommand('analyze', ArgParser()
      ..addOption('directory', abbr: 'd', help: 'The directory to analyze.')
    );

  try {
    final results = parser.parse(arguments);

    if (results.command?.name == 'analyze') {
      final directoryPath = results.command?['directory'] as String?;
      if (directoryPath == null) {
        print('Please provide a directory to analyze with the --directory option.');
        exit(1);
      }
      final absoluteDirectoryPath = Directory(directoryPath).absolute.path;
      await analyzeDirectory(absoluteDirectoryPath);
    } else {
      print('Usage: dcm_clone analyze --directory <path>');
    }
  } on FormatException catch (e) {
    print(e.message);
    print('Usage: dcm_clone analyze --directory <path>');
    exit(1);
  }
}
