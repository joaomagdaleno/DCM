import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';

/// Uma classe base abstrata para uma regra de lint.
abstract class Rule {
  /// O ID exclusivo da regra.
  String get id;

  /// A mensagem a ser exibida quando a regra é violada.
  String get message;

  /// Visita a unidade de compilação e retorna uma lista de problemas encontrados.
  Iterable<Issue> check(ResolvedUnitResult result);
}

/// Representa uma única instância de um problema de lint.
class Issue {
  /// A regra que foi violada.
  final Rule rule;

  /// O nó AST onde o problema ocorreu.
  final AstNode node;

  /// O resultado da análise que contém informações sobre a linha.
  final ResolvedUnitResult analysisResult;

  Issue(this.rule, this.node, this.analysisResult);

  @override
  String toString() {
    final lineInfo = analysisResult.lineInfo.getLocation(node.offset);
    return 'Issue: ${rule.id} at ${analysisResult.path}:${lineInfo.lineNumber}:${lineInfo.columnNumber} - ${rule.message}';
  }
}
