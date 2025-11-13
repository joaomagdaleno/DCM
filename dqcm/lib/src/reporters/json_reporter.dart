import 'dart:convert';
import 'package:dqcm/src/reporters/reporter.dart';
import 'package:dqcm/src/rules/rule.dart';

class JsonReporter implements Reporter {
  @override
  void report(Iterable<Issue> issues) {
    final reportData = {
      'version': 1,
      'diagnostics': issues.map((issue) {
        final lineInfo = issue.analysisResult.lineInfo.getLocation(issue.node.offset);
        return {
          'code': issue.rule.id,
          'severity': 'WARNING', // TODO: Tornar isso configurável
          'type': 'STATIC_WARNING',
          'location': {
            'file': issue.analysisResult.path,
            'range': {
              'start': {
                'offset': issue.node.offset,
                'line': lineInfo.lineNumber,
                'column': lineInfo.columnNumber,
              },
              'end': {
                'offset': issue.node.end,
                'line': issue.analysisResult.lineInfo.getLocation(issue.node.end).lineNumber,
                'column': issue.analysisResult.lineInfo.getLocation(issue.node.end).columnNumber,
              },
            },
          },
          'problemMessage': issue.rule.message,
        };
      }).toList(),
    };

    print(jsonEncode(reportData));
  }
}
