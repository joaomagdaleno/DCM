import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dqcm/src/rules/rule.dart';

class AvoidPrintRule extends Rule {
  @override
  String get id => 'avoid-print';

  @override
  String get message => 'Avoid using print() or debugPrint().';

  @override
  Iterable<Issue> check(ResolvedUnitResult result) {
    final visitor = _AvoidPrintVisitor(this, result);
    result.unit.accept(visitor);
    return visitor.issues;
  }
}

class _AvoidPrintVisitor extends GeneralizingAstVisitor<void> {
  final AvoidPrintRule rule;
  final ResolvedUnitResult analysisResult;
  final List<Issue> issues = [];

  _AvoidPrintVisitor(this.rule, this.analysisResult);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'print' || node.methodName.name == 'debugPrint') {
      issues.add(Issue(rule, node, analysisResult));
    }
    super.visitMethodInvocation(node);
  }
}
