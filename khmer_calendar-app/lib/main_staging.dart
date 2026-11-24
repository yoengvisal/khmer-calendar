import 'app/bootstrap.dart';
import 'app/config/app_config.dart';

/// Run: fvm flutter run --flavor staging -t lib/main_staging.dart \
///   --dart-define-from-file=config/staging.json
Future<void> main() => bootstrap(Flavor.staging);
