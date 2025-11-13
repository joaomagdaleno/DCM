import 'package:dqcm/src/rules/rule.dart';

/// Uma interface para formatar e relatar problemas de análise.
abstract class Reporter {
  void report(Iterable<Issue> issues);
}
