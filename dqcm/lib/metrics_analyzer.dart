import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/file_system/physical_file_system.dart';

Future<void> calculateMetrics(String directoryPath) async {
  print('Calculating metrics for directory: $directoryPath');
  final collection = AnalysisContextCollection(
    includedPaths: [directoryPath],
    resourceProvider: PhysicalResourceProvider.INSTANCE,
  );

  for (final context in collection.contexts) {
    for (final filePath in context.contextRoot.analyzedFiles()) {
      if (filePath.endsWith('.dart')) {
        final result = await context.currentSession.getResolvedUnit(filePath);
        if (result is ResolvedUnitResult) {
          final visitor = _MetricsVisitor(result);
          result.unit.accept(visitor);
        }
      }
    }
  }
}

class _MetricsVisitor extends GeneralizingAstVisitor<void> {
  final ResolvedUnitResult analysisResult;

  _MetricsVisitor(this.analysisResult);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _calculateMetricsForNode(node.name.lexeme, node.parameters, node.body);
    super.visitMethodDeclaration(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _calculateMetricsForNode(node.name.lexeme, node.functionExpression.parameters, node.functionExpression.body);
    super.visitFunctionDeclaration(node);
  }

  void _calculateMetricsForNode(String name, FormalParameterList? parameters, FunctionBody body) {
    final parameterCount = parameters?.parameters.length ?? 0;

    final startLine = analysisResult.lineInfo.getLocation(body.offset).lineNumber;
    final endLine = analysisResult.lineInfo.getLocation(body.endToken.offset).lineNumber;
    final linesOfCode = endLine - startLine;

    final complexityVisitor = _CyclomaticComplexityVisitor();
    body.accept(complexityVisitor);
    final cyclomaticComplexity = complexityVisitor.complexity;

    print('Function/Method: $name');
    print('  - Lines of Code: $linesOfCode');
    print('  - Parameter Count: $parameterCount');
    print('  - Cyclomatic Complexity: $cyclomaticComplexity');
  }
}

class _CyclomaticComplexityVisitor extends GeneralizingAstVisitor<void> {
  int complexity = 1;

  @override
  void visitIfStatement(IfStatement node) {
    complexity++;
    super.visitIfStatement(node);
  }

  @override
  void visitForStatement(ForStatement node) {
    complexity++;
    super.visitForStatement(node);
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    complexity++;
    super.visitWhileStatement(node);
  }

  @override
  void visitDoStatement(DoStatement node) {
    complexity++;
    super.visitDoStatement(node);
  }

  @override
  void visitSwitchCase(SwitchCase node) {
    complexity++;
    super.visitSwitchCase(node);
  }

  @override
  void visitCatchClause(CatchClause node) {
    complexity++;
    super.visitCatchClause(node);
  }
}
