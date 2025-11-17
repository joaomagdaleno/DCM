import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import 'package:dqcm/src/services/metrics_service.dart';

class MetricsCommand extends Command<int> {
  @override
  final name = 'metrics';

  @override
  final description = 'Calculate code metrics for the project.';

  MetricsCommand() {
    argParser.addOption(
      'directory',
      abbr: 'd',
      help: 'The directory to calculate metrics for.',
    );
  }

  @override
  Future<int> run() async {
    final directoryPath = argResults?['directory'] as String?;
    if (directoryPath == null) {
      print('Please provide a directory to calculate metrics for with the --directory option.');
      return 1;
    }
    final absolutePath = p.normalize(Directory(directoryPath).absolute.path);
    await _calculateMetrics(absolutePath);
    return 0;
  }

  Future<void> _calculateMetrics(String directoryPath) async {
    print('Calculating metrics for directory: $directoryPath');
    final collection = AnalysisContextCollection(
      includedPaths: [directoryPath],
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );

    for (final context in collection.contexts) {
      for (final filePath in context.contextRoot.analyzedFiles()) {
        if (filePath.endsWith('.dart')) {
          final result = await context.currentSession.getResolvedUnit(filePath);
          if (result is ResolvedUnitResult) {
            final visitor = _MetricsVisitor(result, MetricsService());
            result.unit.accept(visitor);
          }
        }
      }
    }
  }
}

class _MetricsVisitor extends GeneralizingAstVisitor<void> {
  final ResolvedUnitResult analysisResult;
  final MetricsService metricsService;

  _MetricsVisitor(this.analysisResult, this.metricsService);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _calculateMetricsForNode(node.name.lexeme, node.parameters, node.body);
    super.visitMethodDeclaration(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _calculateMetricsForNode(node.name.lexeme, node.functionExpression.parameters, node.functionExpression.body);
    super.visitFunctionDeclaration(node);
  }

  void _calculateMetricsForNode(String name, FormalParameterList? parameters, FunctionBody body) {
    final parameterCount = metricsService.getParameterCount(parameters);
    final linesOfCode = metricsService.getLinesOfCode(analysisResult, body);
    final cyclomaticComplexity = metricsService.getCyclomaticComplexity(body);

    print('Function/Method: $name');
    print('  - Lines of Code: $linesOfCode');
    print('  - Parameter Count: $parameterCount');
    print('  - Cyclomatic Complexity: $cyclomaticComplexity');
  }
}
