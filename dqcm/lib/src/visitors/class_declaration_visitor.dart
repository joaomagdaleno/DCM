import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class ClassDeclarationVisitor extends GeneralizingAstVisitor<void> {
  final List<ClassDeclaration> classDeclarations = [];

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    classDeclarations.add(node);
    super.visitClassDeclaration(node);
  }
}
