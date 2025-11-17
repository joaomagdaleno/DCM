import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dqcm/src/rules/rule.dart';
import 'package:dqcm/src/services/metrics_service.dart';

class CognitiveComplexityRule extends Rule {
  final int threshold;
  final MetricsService metricsService;

  CognitiveComplexityRule({this.threshold = 15, required this.metricsService});

  @override
  String get id => 'cognitive-complexity';

  @override
  String get message => 'The cognitive complexity of this function is too high.';

  @override
  Iterable<Issue> check(ResolvedUnitResult result) {
    final visitor = _CognitiveComplexityVisitor(this, result, metricsService, threshold);
    result.unit.accept(visitor);
    return visitor.issues;
  }
}

class _CognitiveComplexityVisitor extends GeneralizingAstVisitor<void> {
  final CognitiveComplexityRule rule;
  final ResolvedUnitResult analysisResult;
  final MetricsService metricsService;
  final int threshold;
  final List<Issue> issues = [];

  _CognitiveComplexityVisitor(this.rule, this.analysisResult, this.metricsService, this.threshold);

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
    final complexity = metricsService.getCognitiveComplexity(body);
    if (complexity > threshold) {
      issues.add(Issue(rule, node, analysisResult));
    }
  }
}
