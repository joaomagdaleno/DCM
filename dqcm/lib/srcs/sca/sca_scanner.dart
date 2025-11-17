import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

class ScaScanner {
  final http.Client _client;

  ScaScanner({http.Client? client}) : _client = client ?? http.Client();

  Future<List<VulnerabilityInfo>> scanDirectory(String directoryPath) async {
    final lockFile = File('$directoryPath/pubspec.lock');

    if (!await lockFile.exists()) {
      throw ScaException('pubspec.lock not found in the specified directory.');
    }

    final lockFileContent = await lockFile.readAsString();
    final packages = parseLockFile(lockFileContent);
    final vulnerabilities = <VulnerabilityInfo>[];

    for (final package in packages) {
      final result = await queryOsvApi(package);
      if (result != null) {
        vulnerabilities.add(result);
      }
    }

    return vulnerabilities;
  }

  Future<VulnerabilityInfo?> queryOsvApi(PackageInfo package) async {
    final url = Uri.parse('https://api.osv.dev/v1/query');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'version': package.version,
        'package': {'name': package.name, 'ecosystem': 'Pub'}
      }),
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json.containsKey('vulns')) {
        return VulnerabilityInfo.fromJson(json);
      }
    }
    return null;
  }

  List<PackageInfo> parseLockFile(String content) {
    final packages = <PackageInfo>[];
    final doc = loadYaml(content) as YamlMap;
    final packagesMap = doc['packages'] as YamlMap;

    for (final entry in packagesMap.entries) {
      final packageName = entry.key as String;
      final packageInfo = entry.value as YamlMap;
      final version = packageInfo['version'] as String;
      packages.add(PackageInfo(name: packageName, version: version));
    }

    return packages;
  }
}

class PackageInfo {
  final String name;
  final String version;

  PackageInfo({required this.name, required this.version});
}

class VulnerabilityInfo {
  final List<dynamic> vulns;

  VulnerabilityInfo({required this.vulns});

  factory VulnerabilityInfo.fromJson(Map<String, dynamic> json) {
    return VulnerabilityInfo(vulns: json['vulns'] as List<dynamic>);
  }
}

class ScaException implements Exception {
  final String message;
  ScaException(this.message);
}
