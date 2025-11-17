import 'package:analyzer/file_system/file_system.dart';
import 'package:yaml/yaml.dart';

class Config {
  final List<String> enabledRules;
  final Map<String, int> ruleThresholds;

  Config(this.enabledRules, this.ruleThresholds);

  factory Config.fromAnalysisOptions(File optionsFile) {
    if (!optionsFile.exists) {
      return Config([], {});
    }

    final content = optionsFile.readAsStringSync();
    final yaml = loadYaml(content) as YamlMap?;

    final dqcmConfig = yaml?['dqcm'] as YamlMap?;
    if (dqcmConfig == null) {
      return Config([], {});
    }

    final rules = dqcmConfig['rules'] as YamlMap?;
    if (rules == null) {
      return Config([], {});
    }

    final enabledRules = <String>[];
    final ruleThresholds = <String, int>{};

    rules.forEach((key, value) {
      if (value is bool && value) {
        enabledRules.add(key as String);
      } else if (value is YamlMap) {
        enabledRules.add(key as String);
        final threshold = value['threshold'] as int?;
        if (threshold != null) {
          ruleThresholds[key as String] = threshold;
        }
      }
    });

    return Config(enabledRules, ruleThresholds);
  }
}
