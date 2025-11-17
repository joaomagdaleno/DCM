import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dqcm/src/rules/rule.dart';
import 'package:dqcm/src/services/metrics_service.dart';

class CyclomaticComplexityRule extends Rule {
  final int threshold;
  final MetricsService metricsService;

  CyclomaticComplexityRule({this.threshold = 10, required this.metricsService});

  @override
  String get id => 'cyclomatic-complexity';

  @override
  String get message => 'The cyclomatic complexity of this function is too high.';

  @override
  Iterable<Issue> check(ResolvedUnitResult result) {
    final visitor = _CyclomaticComplexityVisitor(this, result, metricsService, threshold);
    result.unit.accept(visitor);
    return visitor.issues;
  }
}

class _CyclomaticComplexityVisitor extends GeneralizingAstVisitor<void> {
  final CyclomaticComplexityRule rule;
  final ResolvedUnitResult analysisResult;
  final MetricsService metricsService;
  final int threshold;
  final List<Issue> issues = [];

  _CyclomaticComplexityVisitor(this.rule, this.analysisResult, this.metricsService, this.threshold);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _checkComplexity(node, node.body);
    super.visitMethodDeclaration(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _checkComplexity(node, node.functionExpression.body);
    super.visitFunctionDeclaration(node);
  }

  void _checkComplexity(AstNode node, FunctionBody body) {
    final complexity = metricsService.getCyclomaticComplexity(body);
    if (complexity > threshold) {
      issues.add(Issue(rule, node, analysisResult));
    }
  }
}
