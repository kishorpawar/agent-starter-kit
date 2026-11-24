// Test isolation: no test may reach a real service.
//
// `flutter test` runs `testExecutable` from this file automatically, around every
// test file in this directory and below. It replaces dart:io's HttpClient with one
// that throws, so a forgotten mock fails loudly instead of calling a real backend.
// Covers package:http (IOClient), dio and anything else built on dart:io.
// Inject a fake client in tests that need responses.
//
// Not covered: tests run on the web platform (--platform chrome), which use the
// browser's fetch. Mock the client there explicitly.

import 'dart:async';
import 'dart:io';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  HttpOverrides.global = _NoNetworkHttpOverrides();
  await testMain();
}

class _NoNetworkHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    throw StateError(
      'Tests must not make real HTTP calls. Inject a fake client '
      '(blocked by test/flutter_test_config.dart).',
    );
  }
}
