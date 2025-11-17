import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dqcm/src/rules/rule.dart';
import 'package:dqcm/src/services/metrics_service.dart';

class LongMethodRule extends Rule {
  final int threshold;
  final MetricsService metricsService;

  LongMethodRule({this.threshold = 50, required this.metricsService});

  @override
  String get id => 'long-method';

  @override
  String get message => 'This method is too long.';

  @override
  Iterable<Issue> check(ResolvedUnitResult result) {
    final visitor = _LongMethodVisitor(this, result, metricsService, threshold);
    result.unit.accept(visitor);
    return visitor.issues;
  }
}

class _LongMethodVisitor extends GeneralizingAstVisitor<void> {
  final LongMethodRule rule;
  final ResolvedUnitResult analysisResult;
  final MetricsService metricsService;
  final int threshold;
  final List<Issue> issues = [];

  _LongMethodVisitor(this.rule, this.analysisResult, this.metricsService, this.threshold);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _checkLinesOfCode(node, node.body);
    super.visitMethodDeclaration(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _checkLinesOfCode(node, node.functionExpression.body);
    super.visitFunctionDeclaration(node);
  }

  void _checkLinesOfCode(AstNode node, FunctionBody body) {
    final linesOfCode = metricsService.getLinesOfCode(analysisResult, body);
    if (linesOfCode > threshold) {
      issues.add(Issue(rule, node, analysisResult));
    }
  }
}
