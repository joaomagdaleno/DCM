import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dqcm/srcs/sca/sca_scanner.dart';

class ScaCommand extends Command {
  @override
  String get name => 'sca';

  @override
  String get description => 'Scans for vulnerabilities in project dependencies.';

  ScaCommand() {
    argParser.addOption(
      'directory',
      abbr: 'd',
      help: 'The directory to scan.',
      defaultsTo: '.',
    );
    argParser.addOption(
      'reporter',
      help: 'The reporter to use for the output.',
      allowed: ['console', 'json'],
      defaultsTo: 'console',
    );
    argParser.addOption(
      'fail-on-severity',
      help: 'The minimum severity to fail the command on.',
      allowed: ['low', 'medium', 'high', 'critical'],
    );
  }

  @override
  Future<void> run() async {
    final directoryPath = argResults!['directory'] as String;
    final scanner = ScaScanner();

    try {
      final vulnerabilities = await scanner.scanDirectory(directoryPath);
      _reportVulnerabilities(vulnerabilities);
      _handleFailure(vulnerabilities);
    } on ScaException catch (e) {
      stderr.writeln('Error: ${e.message}');
      exit(2);
    }
  }

  void _reportVulnerabilities(List<VulnerabilityInfo> vulnerabilities) {
    final reporterType = argResults!['reporter'] as String;
    if (reporterType == 'json') {
      _reportJson(vulnerabilities);
    } else {
      _reportConsole(vulnerabilities);
    }
  }

  void _reportJson(List<VulnerabilityInfo> vulnerabilities) {
    final report = {
      'vulnerabilities': vulnerabilities.expand((v) => v.vulns).toList(),
    };
    print(jsonEncode(report));
  }

  void _reportConsole(List<VulnerabilityInfo> vulnerabilities) {
    if (vulnerabilities.isEmpty) {
      print('No vulnerabilities found.');
      return;
    }

    print('Found ${vulnerabilities.length} vulnerabilities:');
    for (final vulnerability in vulnerabilities) {
      for (final vuln in vulnerability.vulns) {
        print('- ID: ${vuln['id']}');
        print('  Details: ${vuln['details']}');
      }
    }
  }

  void _handleFailure(List<VulnerabilityInfo> vulnerabilities) {
    final failOnSeverity = argResults?['fail-on-severity'] as String?;
    if (failOnSeverity == null || vulnerabilities.isEmpty) {
      return;
    }

    final severityMap = {
      'low': 1,
      'medium': 2,
      'high': 3,
      'critical': 4,
    };

    final minSeverity = severityMap[failOnSeverity] ?? 0;

    for (final vulnerability in vulnerabilities) {
      for (final vuln in vulnerability.vulns) {
        final severity = _getSeverity(vuln);
        if (severity >= minSeverity) {
          stderr.writeln(
            'Failing build due to vulnerability ${vuln['id']} with severity >= $failOnSeverity',
          );
          exit(2);
        }
      }
    }
  }

  int _getSeverity(Map<String, dynamic> vuln) {
    // This is a simplified severity mapping. A real implementation might
    // need to be more sophisticated based on CVSS scores.
    if (vuln.containsKey('severity')) {
      final severity = vuln['severity'] as List<dynamic>;
      if (severity.isNotEmpty) {
        final type = severity[0]['type'] as String;
        if (type == 'CVSS_V3') {
          final score = double.parse(severity[0]['score'] as String);
          if (score >= 9.0) return 4; // Critical
          if (score >= 7.0) return 3; // High
          if (score >= 4.0) return 2; // Medium
          if (score > 0) return 1; // Low
        }
      }
    }
    // Fallback if no CVSS score is available
    final details = (vuln['details'] as String).toLowerCase();
    if (details.contains('critical')) return 4;
    if (details.contains('high')) return 3;
    if (details.contains('medium')) return 2;
    return 1; // Low
  }
}
