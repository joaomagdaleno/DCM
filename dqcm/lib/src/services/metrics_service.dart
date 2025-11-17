import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:dqcm/src/visitors/cognitive_complexity_visitor.dart';
import 'package:dqcm/src/visitors/cyclomatic_complexity_visitor.dart';

class MetricsService {
  int getParameterCount(FormalParameterList? parameters) {
    return parameters?.parameters.length ?? 0;
  }

  int getLinesOfCode(ResolvedUnitResult analysisResult, FunctionBody body) {
    final startLine = analysisResult.lineInfo.getLocation(body.offset).lineNumber;
    final endLine = analysisResult.lineInfo.getLocation(body.endToken.offset).lineNumber;
    return endLine - startLine;
  }

  int getCyclomaticComplexity(FunctionBody body) {
    final complexityVisitor = CyclomaticComplexityVisitor();
    body.accept(complexityVisitor);
    return complexityVisitor.complexity;
  }

  int getCognitiveComplexity(FunctionBody body) {
    final complexityVisitor = CognitiveComplexityVisitor();
    body.accept(complexityVisitor);
    return complexityVisitor.complexity;
  }
}
