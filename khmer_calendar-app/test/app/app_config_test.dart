import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/app/config/app_config.dart';
import 'package:khmer_calendar/app/config/app_version.dart';

void main() {
  group('AppConfig.parse', () {
    test('accepts a valid dev config and strips trailing slashes', () {
      final config = AppConfig.parse(
        expectedFlavor: Flavor.dev,
        appEnv: 'dev',
        apiBaseUrl: 'http://localhost:3000/api/v1/',
      );
      expect(config.flavor, Flavor.dev);
      expect(config.apiBaseUrl, 'http://localhost:3000/api/v1');
      expect(config.enableNetworkLogging, isTrue);
    });

    void expectInvalid(Flavor flavor, String env, String url, String hint) {
      expect(
        () => AppConfig.parse(
          expectedFlavor: flavor,
          appEnv: env,
          apiBaseUrl: url,
        ),
        throwsA(
          isA<ConfigException>().having(
            (e) => e.message,
            'message',
            contains(hint),
          ),
        ),
      );
    }

    test('rejects missing / invalid values with clear messages', () {
      expectInvalid(Flavor.dev, '', 'http://x', 'APP_ENV is missing');
      expectInvalid(Flavor.dev, 'qa', 'http://x', 'APP_ENV "qa" is invalid');
      expectInvalid(Flavor.production, 'dev', 'https://x', 'does not match');
      expectInvalid(Flavor.dev, 'dev', '', 'API_BASE_URL is missing');
      expectInvalid(Flavor.dev, 'dev', 'localhost:3000', 'absolute http(s)');
      expectInvalid(
        Flavor.production,
        'production',
        'http://api.example.com/api/v1',
        'must use https',
      );
    });

    test('every committed config/*.json is valid for its flavor', () {
      final files = {
        'dev.json': Flavor.dev,
        'dev.android-emulator.json': Flavor.dev,
        'staging.json': Flavor.staging,
        'production.json': Flavor.production,
      };
      for (final MapEntry(key: name, value: flavor) in files.entries) {
        final json = jsonDecode(
          File('config/$name').readAsStringSync(),
        ) as Map<String, dynamic>;
        final config = AppConfig.parse(
          expectedFlavor: flavor,
          appEnv: json['APP_ENV'] as String,
          apiBaseUrl: json['API_BASE_URL'] as String,
        );
        expect(config.flavor, flavor, reason: name);
      }
    });
  });

  test('appVersion matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version:\s*(\S+)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1);
    expect(appVersion, version);
  });
}
