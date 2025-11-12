import 'dart:io';
import 'dart:convert';

Future<void> analyzeDirectory(String directoryPath, String reporter) async {
  if (reporter == 'console') {
    print('Analyzing directory: $directoryPath');
  }

  final args = ['analyze', '.', '--format=${reporter == 'json' ? 'json' : 'machine'}'];
  final result = await Process.run(
    'dart',
    args,
    workingDirectory: directoryPath,
  );

  final output = result.stdout.toString();

  if (reporter == 'json') {
    print(output);
    return;
  }

  final lines = LineSplitter.split(output);
  final issues = lines.where((line) => line.trim().isNotEmpty).toList();

  if (issues.isEmpty) {
    print('No analysis issues found.');
  } else {
    print('--- Found ${issues.length} issues ---');
    issues.forEach(print);
    print('------------------------');
  }
}
