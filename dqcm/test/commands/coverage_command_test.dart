import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dqcm/src/commands/coverage_command.dart';
import 'package:test/test.dart';

void main() {
  group('CoverageCommand', () {
    test('quality gate fails when coverage is below the threshold', () async {
      final lcovContent = """
SF:lib/main.dart
DA:1,0
DA:2,0
end_of_record
""";
      final lcovFile = File('test/fixtures/lcov.info');
      await lcovFile.parent.create(recursive: true);
      await lcovFile.writeAsString(lcovContent);

      final runner = CommandRunner<int>('dqcm', 'Test')
        ..addCommand(CoverageCommand());
      final exitCode = await runner.run(['coverage', '--file', lcovFile.path, '--fail-under', '80']);
      expect(exitCode, 1);

      await lcovFile.delete();
    });

    test('quality gate passes when coverage is above the threshold', () async {
      final lcovContent = """
SF:lib/main.dart
DA:1,1
DA:2,1
end_of_record
""";
      final lcovFile = File('test/fixtures/lcov.info');
      await lcovFile.parent.create(recursive: true);
      await lcovFile.writeAsString(lcovContent);

      final runner = CommandRunner<int>('dqcm', 'Test')
        ..addCommand(CoverageCommand());
      final exitCode = await runner.run(['coverage', '--file', lcovFile.path, '--fail-under', '80']);
      expect(exitCode, 0);

      await lcovFile.delete();
    });
  });
}
