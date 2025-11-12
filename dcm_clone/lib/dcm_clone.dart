import 'dart:io';
import 'dart:convert';

Future<void> analyzeDirectory(String directoryPath) async {
  print('Analyzing directory: $directoryPath');
  final result = await Process.run(
    'dart',
    ['analyze', '.'],
    workingDirectory: directoryPath,
  );

  final output = result.stdout.toString() + result.stderr.toString();
  final lines = LineSplitter.split(output);

  final issues = lines.where((line) => !line.startsWith('Analyzing') && line.trim().isNotEmpty).toList();

  if (issues.isEmpty || (issues.length == 1 && issues.first.contains('No issues found!'))) {
    print('No analysis issues found.');
  } else {
    print('--- Found ${issues.length} issues ---');
    issues.forEach(print);
    print('------------------------');
  }
}
