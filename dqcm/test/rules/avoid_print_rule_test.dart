import 'package:dqcm/src/rules/avoid_print_rule.dart';
import 'package:test/test.dart';

import '../rule_test_utils.dart';

void main() {
  group('AvoidPrintRule', () {
    test('should report issue for print()', () async {
      final code = '''
        void function() {
          print('hello');
        }
      ''';
      final rule = AvoidPrintRule();
      final issues = await analyzeCode(code, rule);
      expect(issues, hasLength(1));
    });

    test('should report issue for debugPrint()', () async {
      final code = '''
        void function() {
          debugPrint('hello');
        }
      ''';
      final rule = AvoidPrintRule();
      final issues = await analyzeCode(code, rule);
      expect(issues, hasLength(1));
    });

    test('should not report issue for other functions', () async {
      final code = '''
        void function() {
          otherFunction('hello');
        }
      ''';
      final rule = AvoidPrintRule();
      final issues = await analyzeCode(code, rule);
      expect(issues, isEmpty);
    });
  });
}
