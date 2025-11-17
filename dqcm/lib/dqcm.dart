import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:dqcm/src/config/config.dart';
import 'package:dqcm/src/rules/flutter/avoid_empty_setstate.dart';
import 'package:dqcm/src/rules/cognitive_complexity_rule.dart';
import 'package:dqcm/src/rules/cyclomatic_complexity_rule.dart';
import 'package:dqcm/src/rules/flutter/avoid_returning_widgets.dart';
import 'package:dqcm/src/rules/avoid_print_rule.dart';
import 'package:dqcm/src/rules/long_method_rule.dart';
import 'package:dqcm/src/rules/maximum_parameters_rule.dart';
import 'package:dqcm/src/reporters/console_reporter.dart';
import 'package:dqcm/src/reporters/html_reporter.dart';
import 'package:dqcm/src/reporters/json_reporter.dart';
import 'package:dqcm/src/services/metrics_service.dart';
import 'package:dqcm/src/reporters/reporter.dart';
import 'package:dqcm/src/rules/rule.dart';

// Este será o registro para todas as regras disponíveis na ferramenta.
List<Rule> _getAllRules(Config config) {
  return [
    AvoidReturningWidgetsRule(),
    AvoidEmptySetStateRule(),
    CyclomaticComplexityRule(
      metricsService: MetricsService(),
      threshold: config.ruleThresholds['cyclomatic-complexity'] ?? 10,
    ),
    CognitiveComplexityRule(
      metricsService: MetricsService(),
      threshold: config.ruleThresholds['cognitive-complexity'] ?? 15,
    ),
    MaximumParametersRule(
      metricsService: MetricsService(),
      threshold: config.ruleThresholds['maximum-parameters'] ?? 4,
    ),
    LongMethodRule(
      metricsService: MetricsService(),
      threshold: config.ruleThresholds['long-method'] ?? 50,
    ),
    AvoidPrintRule(),
  ];
}

Future<Iterable<Issue>> analyzeDirectory(
  String directoryPath, {
  required ResourceProvider resourceProvider,
}) async {
  final optionsFile = resourceProvider.getFile(p.join(directoryPath, 'analysis_options.yaml'));
  final config = Config.fromAnalysisOptions(optionsFile);
  final allRules = _getAllRules(config);

  final enabledRules = allRules.where((rule) => config.enabledRules.contains(rule.id)).toList();

  if (enabledRules.isEmpty) {
    print('No rules enabled. Add rules to `dqcm:` section in your analysis_options.yaml');
    return [];
  }

  print('Enabled rules: ${enabledRules.map((r) => r.id).join(', ')}');

  final collection = AnalysisContextCollection(
    includedPaths: [directoryPath],
    resourceProvider: resourceProvider,
  );

  final issues = <Issue>[];
  for (final context in collection.contexts) {
    for (final filePath in context.contextRoot.analyzedFiles()) {
      if (filePath.endsWith('.dart')) {
        final result = await context.currentSession.getResolvedUnit(filePath);
        if (result is ResolvedUnitResult) {
          for (final rule in enabledRules) {
            issues.addAll(rule.check(result));
          }
        }
      }
    }
  }

  return issues;
}

Reporter getReporter(String type) {
  if (type == 'json') {
    return JsonReporter();
  }
  if (type == 'html') {
    return HtmlReporter();
  }
  return ConsoleReporter();
}
