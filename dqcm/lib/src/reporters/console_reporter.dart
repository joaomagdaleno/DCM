import 'package:dqcm/src/reporters/reporter.dart';
import 'package:dqcm/src/rules/rule.dart';

class ConsoleReporter implements Reporter {
  @override
  void report(Iterable<Issue> issues) {
    if (issues.isEmpty) {
      print('No issues found.');
    } else {
      print('Found ${issues.length} issues:');
      for (final issue in issues) {
        final lineInfo = issue.analysisResult.lineInfo.getLocation(issue.node.offset);
        final path = issue.analysisResult.path;
        final message = issue.rule.message;
        final ruleId = issue.rule.id;

        print(
          '$ruleId at $path:${lineInfo.lineNumber}:${lineInfo.columnNumber} - $message',
        );
      }
    }
  }
}
