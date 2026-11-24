### Stack: Flutter / Dart

<!-- FILL: real commands, flavors, and how to point the app at a local backend. -->
```bash
flutter run --dart-define-from-file=env/dev.json   # run against dev
flutter test test/path/to/file_test.dart           # one test file (preferred)
dart analyze                                       # whole-package analysis — required before done
.agents/hooks/check-files.sh lib/path/file.dart    # format + analyze one file
dart run build_runner build --delete-conflicting-outputs  # after changing annotated models
```

- **Test isolation:** `test/flutter_test_config.dart` makes any real HTTP call throw.
  Inject fake clients; never weaken the override.
- **The server is the authority.** Hiding a button is UX, not authorization. Never
  decide permissions, prices, eligibility, or amounts on the device.
- **Nothing in the app binary is secret** — `--dart-define` values, assets and code
  can all be extracted. API keys that must stay secret live on the server.
- Tokens and personal data go in `flutter_secure_storage`, never
  `shared_preferences`. Never `print`/log personal data; use one logger that strips it
  in release builds.
- Every async screen renders loading, empty, error, and data states. Check `mounted`
  before using `BuildContext` after an `await`.
- Generated files (`*.g.dart`, `*.freezed.dart`) are never edited by hand; change the
  source and re-run build_runner.
- User-facing strings come from the localization files (`lib/l10n/`), never inline.
