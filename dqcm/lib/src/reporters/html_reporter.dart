import 'dart:io';

import 'package:dqcm/src/reporters/reporter.dart';
import 'package:dqcm/src/rules/rule.dart';

class HtmlReporter extends Reporter {
  @override
  void report(Iterable<Issue> issues) {
    final html = StringBuffer();
    html.writeln('<!DOCTYPE html>');
    html.writeln('<html>');
    html.writeln('<head>');
    html.writeln('<title>DQCM Report</title>');
    html.writeln('<style>');
    html.writeln('body { font-family: sans-serif; }');
    html.writeln('table { border-collapse: collapse; width: 100%; }');
    html.writeln('th, td { border: 1px solid #ddd; padding: 8px; }');
    html.writeln('th { background-color: #f2f2f2; }');
    html.writeln('</style>');
    html.writeln('</head>');
    html.writeln('<body>');
    html.writeln('<h1>DQCM Report</h1>');
    html.writeln('<table>');
    html.writeln('<tr>');
    html.writeln('<th>Rule</th>');
    html.writeln('<th>File</th>');
    html.writeln('<th>Line</th>');
    html.writeln('<th>Column</th>');
    html.writeln('<th>Message</th>');
    html.writeln('</tr>');

    for (final issue in issues) {
      final lineInfo = issue.analysisResult.lineInfo.getLocation(issue.node.offset);
      html.writeln('<tr>');
      html.writeln('<td>${issue.rule.id}</td>');
      html.writeln('<td>${issue.analysisResult.path}</td>');
      html.writeln('<td>${lineInfo.lineNumber}</td>');
      html.writeln('<td>${lineInfo.columnNumber}</td>');
      html.writeln('<td>${issue.rule.message}</td>');
      html.writeln('</tr>');
    }

    html.writeln('</table>');
    html.writeln('</body>');
    html.writeln('</html>');

    final file = File('dqcm-report.html');
    file.writeAsStringSync(html.toString());
    print('HTML report generated at ${file.absolute.path}');
  }
}
