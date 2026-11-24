# Khmer Calendar — mobile app (Flutter)

Khmer lunar calendar (ចន្ទគតិ / Chhankitek) for Android and iOS. Lunar dates are
computed **on the device** by a pure-Dart engine, so the calendar works
offline. Holidays and events come from the public API
(`GET /events?from&to`, see [`../docs/api-contract.md`](../docs/api-contract.md)).
The app has no login.

- **Calendar**: Sunday-first month grid with Gregorian and lunar day ("៥កើត" / "5 Kert"),
  holy-day (ថ្ងៃសីល) moon marker, event dots, red day-off holidays and a
  highlighted today. The header shows the lunar month span, animal year, sak and
  BE year. Prev/next buttons, horizontal swipe, and a "Today" button. Tap a day
  to see the full Khmer date ("ថ្ងៃអាទិត្យ ១០កើត ខែមិគសិរ ឆ្នាំមមី អដ្ឋស័ក ពុទ្ធសករាជ ២៥៧០")
  and that day's events.
- **Holidays**: published events for the selected year, grouped by month, with
  pull-to-refresh. Each year is cached on the device; when the network fails the
  app shows the saved copy with an "offline — showing saved data" banner.
- **Settings**: language (Khmer by default, English, or Simplified Chinese) and theme
  (system/light/dark). Both are saved on the device. Shows the app version, and
  on non-production builds also the environment.

## Bootstrap

Flutter is pinned with FVM in the **repo-root `.fvmrc` (Flutter 3.50.0)**. Always
use `fvm flutter …` / `fvm dart …`. FVM finds the root `.fvmrc` from inside this
directory.

```bash
cd khmer_calendar_app
fvm install                 # once per machine, if 3.50.0 is not cached yet
fvm flutter pub get         # also generates lib/l10n/generated (gen-l10n)
fvm flutter test
fvm flutter analyze
```

There is no `lib/main.dart`. You always pick a flavor entry point **and** a
config file. Without them the app shows a red "Configuration error" screen
that says what is missing.

## Flavors

| Flavor | Entry point | Config file | Android applicationId | iOS bundle id | App name | Env banner |
|---|---|---|---|---|---|---|
| `dev` | `lib/main_dev.dart` | `config/dev.json` (`http://localhost:3000/api/v1`) | `com.example.khmercalendar.dev` | `com.example.khmercalendar.dev` | Khmer Calendar Dev | green "DEV" |
| `staging` | `lib/main_staging.dart` | `config/staging.json` (`https://staging-api.example.com/api/v1`) | `com.example.khmercalendar.staging` | `com.example.khmercalendar.staging` | Khmer Calendar Stg | orange "STG" |
| `production` | `lib/main_prod.dart` | `config/production.json` (`https://api.example.com/api/v1`) | `com.example.khmercalendar` | `com.example.khmercalendar` | Khmer Calendar | none |

Each config file holds `APP_ENV` and `API_BASE_URL`. The values are read once,
in `lib/app/config/app_config.dart`, and checked at startup:

- `APP_ENV` must match the entry point.
- The URL must be an absolute http(s) URL.
- Staging and production must use https.

Plain HTTP (cleartext) is allowed **only in dev**:

- **Android**: `android/app/src/dev/AndroidManifest.xml` and
  `res/xml/network_security_config.xml` allow localhost, 127.0.0.1 and 10.0.2.2.
- **iOS**: the "Dev ATS exception" build phase adds `NSAllowsLocalNetworking`
  plus a `localhost` exception, only when `APP_ALLOW_LOCAL_HTTP = YES`.

### Run / build

```bash
# dev (iOS simulator / device, or desktop-hosted API reachable as localhost)
fvm flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=config/dev.json

# dev on the Android EMULATOR: the host machine is 10.0.2.2, not localhost
fvm flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=config/dev.android-emulator.json

# staging / production
fvm flutter run --flavor staging    -t lib/main_staging.dart --dart-define-from-file=config/staging.json
fvm flutter run --flavor production -t lib/main_prod.dart    --dart-define-from-file=config/production.json

# builds
fvm flutter build apk --flavor dev -t lib/main_dev.dart --debug --dart-define-from-file=config/dev.json
fvm flutter build ios --flavor dev -t lib/main_dev.dart --debug --no-codesign --dart-define-from-file=config/dev.json
fvm flutter build appbundle --flavor production -t lib/main_prod.dart --dart-define-from-file=config/production.json
```

On a physical Android device, use your machine's LAN IP in a local copy of the
dev config. If that IP is not in the network security config, add it there too.

### Changing the app id before store release

The base id is set in one place per platform:

- **Android**: `val baseApplicationId = "com.example.khmercalendar"` at the top of
  `android/app/build.gradle.kts`. Flavors add `.dev` or `.staging`. The Kotlin
  `namespace` (and the `MainActivity` package) is only the code package and does
  not need to change.
- **iOS**: `APP_BUNDLE_ID_BASE` in `ios/Flutter/AppIdentity.xcconfig`. Per-flavor
  suffixes and display names are in `ios/Flutter/Flavors/<flavor>.xcconfig`.
  `Info.plist` uses `$(APP_DISPLAY_NAME)`, and `PRODUCT_BUNDLE_IDENTIFIER` is
  `$(APP_BUNDLE_ID_BASE)$(APP_BUNDLE_ID_SUFFIX)`.

Android display names are set per flavor with `manifestPlaceholders["appLabel"]`
in `build.gradle.kts`.

### How the iOS flavors are set up

`tool/configure_ios_flavors.rb` makes all the Xcode project changes. It uses
Ruby and the `xcodeproj` gem that ships with CocoaPods. You can run it again
safely; it skips what is already done:

```bash
ruby tool/configure_ios_flavors.rb
```

The script does the following:

- Creates the xcconfig files if they are missing.
- Clones the `Debug`/`Release`/`Profile` build configurations into
  `Debug-<flavor>`, `Release-<flavor>` and `Profile-<flavor>`, then removes the
  configurations that have no flavor.
- Gives the project-level configurations `Flavors/<flavor>.xcconfig` as their
  base, so every target inherits it. The Runner target keeps Flutter's
  `Debug.xcconfig`/`Release.xcconfig`.
- Sets the bundle id and display name variables.
- Adds the dev-only ATS build phase.
- Writes the shared schemes `dev`, `staging` and `production`, and removes
  `Runner`.

Run it again after anything that regenerates `ios/` (for example
`flutter create .`). Plugins currently use Swift Package Manager. If a
CocoaPods-only plugin is added later, `pod install` needs per-configuration
`Pods-Runner.<config>.xcconfig` includes. Add `#include?` lines for them to
`ios/Flutter/Debug.xcconfig` and `Release.xcconfig`.

## Architecture

The code is organised by feature, with Clean Architecture layers inside each
feature:

```
lib/
  main_dev.dart / main_staging.dart / main_prod.dart  → bootstrap(Flavor)
  app/
    app.dart              MaterialApp.router, theme/locale from SettingsCubit, env banner
    bootstrap.dart        config → DI → error hooks → runApp
    config/               AppConfig (the ONLY String.fromEnvironment reads), version, error screen
    di/injection.dart     get_it composition root (the only place that registers anything)
    router/               go_router StatefulShellRoute (Calendar / Holidays / Settings)
  core/
    async/                CancelSignal (framework-free cancellation)
    date/                 CivilDate (timezone-free), Clock, month/weekday names
    errors/               sealed AppFailure + AppException, sealed Result<T, E>
    network/              dio_client.dart, api_client.dart (envelope unwrap), failure_mapper.dart,
                          interceptors/ (correlation id, dev-only sanitized logging, error normalization)
    storage/              KeyValueStore (shared_preferences + in-memory)
    logging/              AppLogger + redaction
    theme/                Material 3 theme, deep-red/gold palette, CalendarColors extension
    l10n/                 context.l10n, Khmer digits, date formatting, failure → message
    widgets/              InfoBanner / MessageView / FailureView
  l10n/arb/               app_km.arb, app_en.arb, app_zh.arb (gen-l10n → l10n/generated/)
  features/
    calendar/  domain/{lunar,entities,usecases}  presentation/{bloc,pages,widgets}
    events/    domain/{entities,repositories,usecases}  data/{models,datasources,repositories}
               presentation/{bloc,pages,widgets}
    settings/  domain/{entities,repositories}  data/repositories  presentation/{bloc,pages}
```

Rules the code follows:

- **The domain layer is pure Dart.** It has no Flutter, Dio or JSON imports.
  The lunar engine is in `features/calendar/domain/lunar/`.
  - It is a behaviour-identical port of
    `khmer-calendar-api/src/modules/lunar/domain/khmer-lunar-calendar.ts`. It
    copies JavaScript `Math.floor` and `%` semantics exactly.
  - `test/features/calendar/domain/lunar/khmer_lunar_calendar_test.dart` checks
    it against every row of `../shared/fixtures/khmer-lunar-golden.json` (8,789
    days and 201 new years). The same file also has the TS spec's real-world
    anchors and a 60-year continuity check.
- **Data flow**:
  - Pages and widgets talk to a BLoC or Cubit.
  - BLoCs call use cases.
  - Use cases call repository interfaces.
  - Repositories return `Result<T, AppFailure>`.
  - Only the data sources and `ApiClient` know about Dio. The UI never calls Dio.
- **Network**: there is a single `Dio` with timeouts of 15 s (connect) and 20 s
  (receive and send), and `Accept: application/json`.
  - Every request gets an `x-request-id`.
  - In dev only, requests are logged with authorization, cookie, token and
    password fields redacted.
  - Every error becomes a typed `AppFailure`: network, timeout, server (with the
    envelope `error.code`), validation, not found, cancelled, or unknown.
  - Users only see localized messages, never raw server text.
  - Requests from a screen take a `CancelSignal`, which becomes a Dio
    `CancelToken`. It is cancelled when a newer request supersedes it or the
    BLoC closes.
  - Requests are never retried automatically. Pull-to-refresh or Retry are the
    user's choice.
- **Offline**: `EventsRepositoryImpl` works like this:
  - It goes to the network first.
  - Each successful year is saved as JSON in shared_preferences.
  - If the network fails, it returns the saved copy (`isFromCache`).
  - It keeps fresh results in memory for the session, so swiping between months
    does not send repeated requests.
  - On the calendar, if events cannot be loaded, the lunar grid still renders
    and a banner offers a retry.
- **State and DI**:
  - Calendar uses a Bloc with events: `CalendarStarted`,
    `CalendarMonthShifted`, `CalendarTodayRequested` and
    `CalendarRefreshRequested`.
  - Holidays uses a Bloc with sealed states: initial, loading, success
    (`isStale` when from cache), empty and failure.
  - Settings uses a Cubit.
  - Dependencies use constructor injection everywhere. `sl<…>()` (get_it) is
    only called in `app/di/injection.dart` and where route-level
    `BlocProvider`s create blocs (`app/router/app_router.dart`) or the app
    creates the `SettingsCubit` (`bootstrap.dart`).

## Packages

| Package | Why |
|---|---|
| `material_ui` | In Flutter 3.50 `package:flutter/material.dart` is deprecated in favour of this package, which `flutter create` adds. Its `GlobalMaterialLocalizations.delegates` are used instead of the deprecated ones that gen-l10n references. |
| `flutter_bloc`, `bloc` | State management. The team switched from Riverpod to BLoC during this build: Cubit for simple screens, Bloc with events for calendar and holidays. |
| `equatable` | Value equality for BLoC states and events and for domain entities. It is pure Dart, so the domain layer can use it. |
| `get_it` | A small service locator, used only in the composition root and for route-level `BlocProvider` creation. |
| `go_router` | Declarative routing and the bottom-navigation shell (`StatefulShellRoute.indexedStack`). |
| `dio` | HTTP client with interceptors and cancellation. |
| `shared_preferences` | Saves settings and the per-year events cache (`SharedPreferencesWithCache`). |
| `intl`, `flutter_localizations` | gen-l10n ARB localizations (`km`, `en`, `zh`). |
| dev: `bloc_test`, `mocktail` | `blocTest` and `MockBloc` for BLoC and widget tests. |

There is no `package_info_plus`. The version shown in Settings is the constant
in `lib/app/config/app_version.dart`, and a test fails if it differs from
`pubspec.yaml`. No codegen and no `google_fonts`: the app uses system fonts,
which include Khmer on both platforms.

## Tests

`fvm flutter test` runs these tests:

- **Lunar engine**: full golden-file parity (days and new years), real-world
  anchors, continuity and the `formattedKm` formatter.
- **Data**: the events repository with a fake remote and a fake cache (success,
  network failure falling back to cache, failure with no cache, cancellation,
  memoization). Also the local cache round-trip and corruption handling, Dio and
  `ApiClient` URL building, `x-request-id`, envelope error-code mapping, and log
  redaction.
- **Domain**: the month-calendar use case. It checks that lunar and events are
  combined, that multi-day events cover every day including across months, and
  that lunar data still comes back when events fail.
- **BLoC** (`blocTest`): holidays success, stale cache, failure, empty, year
  navigation and refresh; calendar next, previous and today, including a
  rapid-navigation race; the settings cubit with persistence.
- **Widget**:
  - Calendar page: loading then success, Khmer numerals, day-detail sheet,
    navigation, and the events-unavailable banner.
  - Holidays page (`MockBloc`): loading, empty, error, and stale states.
  - Settings page.
  - An app smoke test covering DI, the router and locale.
- **Config**: `AppConfig` validation, every `config/*.json`, and the app
  version matching the pubspec.

## Languages

| Code | Language | Notes |
|------|----------|-------|
| `km` | Khmer (default) | Khmer numerals, Khmer lunar terms (៥កើត, ខែមិគសិរ) |
| `en` | English | Romanized lunar terms (5 Kert, Migasir) |
| `zh` | Simplified Chinese | Lunar days as 初一…三十, months as 柬历一月…十二月 (Migasir = month 1, leap Asadh = 前八月/后八月), animal years 鼠…猪, 佛历 for BE. The sak (era) is not shown in Chinese. |

- UI strings: `lib/l10n/arb/app_<code>.arb` → `fvm flutter gen-l10n`.
- Date and lunar formatting: `core/l10n/l10n.dart` and `features/calendar/domain/lunar/khmer_lunar_formatter.dart` take a `UiLanguage`.
- Event titles: the API sends `titleKm`, `titleEn` and an optional `titleZh`; Chinese falls back to English when `titleZh` is empty.
- The language picker shows each language in its own script (ខ្មែរ · English · 中文) regardless of the current UI language.
- Have native speakers review `app_km.arb` and `app_zh.arb` before release.

