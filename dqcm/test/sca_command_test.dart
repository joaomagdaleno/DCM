import 'package:dqcm/srcs/sca/sca_scanner.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

void main() {
  group('ScaScanner', () {
    test('parses pubspec.lock correctly', () {
      final lockFileContent = '''
packages:
  args:
    dependency: "direct main"
    source: hosted
    version: "2.3.1"
  collection:
    dependency: "direct main"
    source: hosted
    version: "1.16.0"
sdks:
  dart: ">=2.17.0 <3.0.0"
''';
      final scanner = ScaScanner();
      final packages = scanner.parseLockFile(lockFileContent);
      expect(packages.length, 2);
      expect(packages[0].name, 'args');
      expect(packages[0].version, '2.3.1');
      expect(packages[1].name, 'collection');
      expect(packages[1].version, '1.16.0');
    });

    test('returns vulnerability when found', () async {
      final mockClient = MockClient((request) async {
        final response = {
          'vulns': [
            {'id': 'OSV-2021-1234', 'details': 'A critical vulnerability'}
          ]
        };
        return http.Response(jsonEncode(response), 200);
      });

      final scanner = ScaScanner(client: mockClient);
      final package = PackageInfo(name: 'test_package', version: '1.0.0');
      final result = await scanner.queryOsvApi(package);

      expect(result, isNotNull);
      expect(result!.vulns.length, 1);
      expect(result.vulns[0]['id'], 'OSV-2021-1234');
    });

    test('returns null when no vulnerability is found', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{}', 200);
      });

      final scanner = ScaScanner(client: mockClient);
      final package = PackageInfo(name: 'test_package', version: '1.0.0');
      final result = await scanner.queryOsvApi(package);

      expect(result, isNull);
    });
  });
}
