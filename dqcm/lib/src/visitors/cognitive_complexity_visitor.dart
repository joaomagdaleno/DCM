import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class CognitiveComplexityVisitor extends GeneralizingAstVisitor<void> {
  int complexity = 0;
  int nesting = 0;

  @override
  void visitIfStatement(IfStatement node) {
    complexity++;
    nesting++;
    complexity += nesting;
    node.thenStatement.accept(this);
    nesting--;
    node.elseStatement?.accept(this);
  }

  @override
  void visitForStatement(ForStatement node) {
    complexity++;
    nesting++;
    complexity += nesting;
    node.body.accept(this);
    nesting--;
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    complexity++;
    nesting++;
    complexity += nesting;
    node.body.accept(this);
    nesting--;
  }

  @override
  void visitDoStatement(DoStatement node) {
    complexity++;
    nesting++;
    complexity += nesting;
    node.body.accept(this);
    nesting--;
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    complexity++;
    nesting++;
    complexity += nesting;
    node.members.forEach((member) => member.accept(this));
    nesting--;
  }

  @override
  void visitCatchClause(CatchClause node) {
    complexity++;
    nesting++;
    complexity += nesting;
    node.body.accept(this);
    nesting--;
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (node.operator.type.lexeme == '&&' || node.operator.type.lexeme == '||') {
      complexity++;
    }
    super.visitBinaryExpression(node);
  }
}
