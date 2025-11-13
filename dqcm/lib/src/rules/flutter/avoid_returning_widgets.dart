import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dqcm/src/rules/rule.dart';

class AvoidReturningWidgetsRule extends Rule {
  @override
  String get id => 'avoid-returning-widgets';

  @override
  String get message => 'Avoid returning widgets from functions or methods.';

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
  void visitMethodDeclaration(MethodDeclaration node) {
    if (_isWidget(node.returnType)) {
      _nodes.add(node);
    }
    super.visitMethodDeclaration(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (_isWidget(node.returnType)) {
      _nodes.add(node);
    }
    super.visitFunctionDeclaration(node);
  }

  bool _isWidget(TypeAnnotation? type) {
    final typeName = type?.toString();
    return typeName == 'Widget' || typeName == 'StatelessWidget' || typeName == 'StatefulWidget';
  }
}
