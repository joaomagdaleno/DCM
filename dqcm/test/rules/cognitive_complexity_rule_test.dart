import 'package:dqcm/src/rules/cognitive_complexity_rule.dart';
import 'package:dqcm/src/services/metrics_service.dart';
import 'package:test/test.dart';

import '../rule_test_utils.dart';

void main() {
  group('CognitiveComplexityRule', () {
    test('should report issue when complexity is too high', () async {
      final code = '''
        void function() {
          if (true) {
            if (true) {
              if (true) {}
            }
          }
        }
      ''';
      final rule = CognitiveComplexityRule(
        metricsService: MetricsService(),
        threshold: 3,
      );
      final issues = await analyzeCode(code, rule);
      expect(issues, hasLength(1));
    });

    test('should not report issue when complexity is acceptable', () async {
      final code = '''
        void function() {
          if (true) {}
        }
      ''';
      final rule = CognitiveComplexityRule(
        metricsService: MetricsService(),
        threshold: 5,
      );
      final issues = await analyzeCode(code, rule);
      expect(issues, isEmpty);
    });
  });
}
