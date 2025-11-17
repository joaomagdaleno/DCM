import 'package:dqcm/src/rules/long_method_rule.dart';
import 'package:dqcm/src/services/metrics_service.dart';
import 'package:test/test.dart';

import '../rule_test_utils.dart';

void main() {
  group('LongMethodRule', () {
    test('should report issue when method is too long', () async {
      final code = '''
        void function() {
          print('');
          print('');
          print('');
          print('');
          print('');
          print('');
          print('');
          print('');
          print('');
          print('');
        }
      ''';
      final rule = LongMethodRule(
        metricsService: MetricsService(),
        threshold: 5,
      );
      final issues = await analyzeCode(code, rule);
      expect(issues, hasLength(1));
    });

    test('should not report issue when method length is acceptable', () async {
      final code = '''
        void function() {
          print('');
        }
      ''';
      final rule = LongMethodRule(
        metricsService: MetricsService(),
        threshold: 5,
      );
      final issues = await analyzeCode(code, rule);
      expect(issues, isEmpty);
    });
  });
}
