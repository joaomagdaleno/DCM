import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dqcm/src/rules/rule.dart';
import 'package:dqcm/src/services/metrics_service.dart';

class MaximumParametersRule extends Rule {
  final int threshold;
  final MetricsService metricsService;

  MaximumParametersRule({this.threshold = 4, required this.metricsService});

  @override
  String get id => 'maximum-parameters';

  @override
  String get message => 'This function has too many parameters.';

  @override
  Iterable<Issue> check(ResolvedUnitResult result) {
    final visitor = _MaximumParametersVisitor(this, result, metricsService, threshold);
    result.unit.accept(visitor);
    return visitor.issues;
  }
}

class _MaximumParametersVisitor extends GeneralizingAstVisitor<void> {
  final MaximumParametersRule rule;
  final ResolvedUnitResult analysisResult;
  final MetricsService metricsService;
  final int threshold;
  final List<Issue> issues = [];

  _MaximumParametersVisitor(this.rule, this.analysisResult, this.metricsService, this.threshold);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _checkParameters(node, node.parameters);
    super.visitMethodDeclaration(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _checkParameters(node, node.functionExpression.parameters);
    super.visitFunctionDeclaration(node);
  }

  void _checkParameters(AstNode node, FormalParameterList? parameters) {
    final parameterCount = metricsService.getParameterCount(parameters);
    if (parameterCount > threshold) {
      issues.add(Issue(rule, node, analysisResult));
    }
  }
}
