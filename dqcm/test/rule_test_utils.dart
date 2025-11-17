import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/overlay_file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:dqcm/src/rules/rule.dart';
import 'package:test/test.dart';

import 'dart:convert';
import 'dart:io';

Future<Iterable<Issue>> analyzeCode(String source, Rule rule) async {
  return testRuleOnMultipleFiles({
    '/tmp/test.dart': source,
  }, rule);
}

Future<Iterable<Issue>> testRuleOnMultipleFiles(
  Map<String, String> sources,
  Rule rule,
) async {
  final flutterVersionResult = await Process.run(
    'flutter',
    ['--version', '--machine'],
  );
  final versionJson = jsonDecode(flutterVersionResult.stdout as String)
      as Map<String, dynamic>;
  final flutterRoot = versionJson['flutterRoot'] as String;
  final sdkPath = '$flutterRoot/bin/cache/dart-sdk';

  final resourceProvider =
      OverlayResourceProvider(PhysicalResourceProvider.INSTANCE);
  sources.forEach((path, content) {
    resourceProvider.setOverlay(path, content: content, modificationStamp: 0);
  });

  final collection = AnalysisContextCollection(
    includedPaths: sources.keys.toList(),
    resourceProvider: resourceProvider,
    sdkPath: sdkPath,
  );

  final issues = <Issue>[];
  for (final path in sources.keys) {
    final analysisSession = collection.contextFor(path).currentSession;
    final result = await analysisSession.getResolvedUnit(path);

    if (result is! ResolvedUnitResult) {
      fail('Failed to resolve source at $path');
    }

    issues.addAll(rule.check(result));
  }

  return issues;
}
