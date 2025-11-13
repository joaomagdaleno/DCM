import 'dart:io';
import 'package:yaml/yaml.dart';

class Config {
  final List<String> enabledRules;

  Config(this.enabledRules);

  factory Config.fromAnalysisOptions(File optionsFile) {
    if (!optionsFile.existsSync()) {
      return Config([]);
    }

    final content = optionsFile.readAsStringSync();
    final yaml = loadYaml(content) as YamlMap?;

    final dqcmConfig = yaml?['dqcm'] as YamlMap?;
    if (dqcmConfig == null) {
      return Config([]);
    }

    final rules = dqcmConfig['rules'] as YamlList?;
    if (rules == null) {
      return Config([]);
    }

    return Config(rules.cast<String>().toList());
  }
}
