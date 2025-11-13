import 'package:dqcm/src/rules/flutter/avoid_empty_setstate.dart';
import 'package:dqcm/src/rules/flutter/avoid_returning_widgets.dart';
import 'package:test/test.dart';
import 'rule_test_utils.dart';

void main() {
  group('AvoidReturningWidgetsRule', () {
    final rule = AvoidReturningWidgetsRule();

    test('should report issue when a function returns a widget', () async {
      final code = '''
        import 'package:flutter/widgets.dart';

        Widget build() {
          return Container();
        }
      ''';
      final issues = await testRule(rule, code);
      expect(issues.length, 1);
      expect(issues.first.rule.id, 'avoid-returning-widgets');
    });

    test('should not report issue for non-widget returning functions', () async {
      final code = '''
        int getNumber() {
          return 1;
        }
      ''';
      final issues = await testRule(rule, code);
      expect(issues.isEmpty, isTrue);
    });
  });

  group('AvoidEmptySetStateRule', () {
    final rule = AvoidEmptySetStateRule();

    test('should report issue for empty setState', () async {
      final code = '''
        import 'package:flutter/widgets.dart';

        class _MyState extends State<StatefulWidget> {
          void method() {
            setState(() {});
          }
        }
      ''';
      final issues = await testRule(rule, code);
      expect(issues.length, 1);
      expect(issues.first.rule.id, 'avoid-empty-setstate');
    });

    test('should not report issue for non-empty setState', () async {
      final code = '''
        import 'package:flutter/widgets.dart';

        class _MyState extends State<StatefulWidget> {
          int _counter = 0;
          void method() {
            setState(() {
              _counter++;
            });
          }
        }
      ''';
      final issues = await testRule(rule, code);
      expect(issues.isEmpty, isTrue);
    });
  });
}
