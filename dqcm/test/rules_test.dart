import 'package:dqcm/src/rules/flutter/avoid_empty_setstate.dart';
import 'package:dqcm/src/rules/flutter/avoid_returning_widgets.dart';
import 'package:dqcm/src/rules/rule.dart';
import 'package:test/test.dart';

import 'rule_test_utils.dart';

void main() {
  group('AvoidReturningWidgetsRule', () {
    final rule = AvoidReturningWidgetsRule();

    test('should report issue when a function returns a widget', () async {
      final code = '''
import 'package:flutter/material.dart';

Widget good() => const Text('Good');
''';
      final issues = await analyzeCode(code, rule);
      expect(issues, hasLength(1));
    });

    test('should not report issue for non-widget returning functions',
        () async {
      final code = '''
int good() => 1;
''';
      final issues = await analyzeCode(code, rule);
      expect(issues, isEmpty);
    });
  });

  group('AvoidEmptySetStateRule', () {
    final rule = AvoidEmptySetStateRule();

    test('should report issue for empty setState', () async {
      final code = '''
import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {});
      },
    );
  }
}
''';
      final issues = await analyzeCode(code, rule);
      expect(issues, hasLength(1));
    });

    test('should not report issue for non-empty setState', () async {
      final code = '''
import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _counter++;
        });
      },
    );
  }
}
''';
      final issues = await analyzeCode(code, rule);
      expect(issues, isEmpty);
    });
  });
}
