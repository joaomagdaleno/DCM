import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class ClassInstantiationVisitor extends GeneralizingAstVisitor<void> {
  final List<InstanceCreationExpression> classInstantiations = [];

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    classInstantiations.add(node);
    super.visitInstanceCreationExpression(node);
  }
}
