import 'package:dqcm/src/rules/maximum_parameters_rule.dart';
import 'package:dqcm/src/services/metrics_service.dart';
import 'package:test/test.dart';

import '../rule_test_utils.dart';

void main() {
  group('MaximumParametersRule', () {
    test('should report issue when there are too many parameters', () async {
      final code = '''
        void function(int a, int b, int c, int d, int e) {}
      ''';
      final rule = MaximumParametersRule(
        metricsService: MetricsService(),
        threshold: 4,
      );
      final issues = await analyzeCode(code, rule);
      expect(issues, hasLength(1));
    });

    test('should not report issue when parameter count is acceptable', () async {
      final code = '''
        void function(int a, int b) {}
      ''';
      final rule = MaximumParametersRule(
        metricsService: MetricsService(),
        threshold: 4,
      );
      final issues = await analyzeCode(code, rule);
      expect(issues, isEmpty);
    });
  });
}
