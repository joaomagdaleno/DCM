import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/overlay_file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:dqcm/src/rules/rule.dart';
import 'package:test/test.dart';

import 'dart:convert';
import 'dart:io';

Future<Iterable<Issue>> testRule(Rule rule, String source) async {
  final flutterVersionResult = await Process.run('flutter', ['--version', '--machine']);
  final versionJson = jsonDecode(flutterVersionResult.stdout as String) as Map<String, dynamic>;
  final flutterRoot = versionJson['flutterRoot'] as String;
  final sdkPath = '$flutterRoot/bin/cache/dart-sdk';

  final resourceProvider = OverlayResourceProvider(PhysicalResourceProvider.INSTANCE);
  const filePath = '/tmp/test.dart';
  resourceProvider.setOverlay(filePath, content: source, modificationStamp: 0);

  final collection = AnalysisContextCollection(
    includedPaths: [filePath],
    resourceProvider: resourceProvider,
    sdkPath: sdkPath,
  );

  final analysisSession = collection.contextFor(filePath).currentSession;
  final result = await analysisSession.getResolvedUnit(filePath);

  if (result is! ResolvedUnitResult) {
    fail('Failed to resolve source.');
  }

  return rule.check(result);
}
