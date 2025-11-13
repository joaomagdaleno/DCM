import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dqcm/src/rules/rule.dart';

class AvoidEmptySetStateRule extends Rule {
  @override
  String get id => 'avoid-empty-setstate';

  @override
  String get message => 'Avoid calling setState with an empty callback.';

  @override
  Iterable<Issue> check(ResolvedUnitResult result) {
    final visitor = _Visitor();
    result.unit.accept(visitor);
    return visitor.nodes.map((node) => Issue(this, node, result));
  }
}

class _Visitor extends GeneralizingAstVisitor<void> {
  final _nodes = <AstNode>[];
  Iterable<AstNode> get nodes => _nodes;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'setState') {
      final argument = node.argumentList.arguments.firstOrNull;
      if (argument is FunctionExpression) {
        final body = argument.body;
        if (body is BlockFunctionBody && body.block.statements.isEmpty) {
          _nodes.add(node);
        }
      }
    }
    super.visitMethodInvocation(node);
  }
}
