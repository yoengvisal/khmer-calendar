import 'app/bootstrap.dart';
import 'app/config/app_config.dart';

/// Run: fvm flutter run --flavor dev -t lib/main_dev.dart \
///   --dart-define-from-file=config/dev.json
Future<void> main() => bootstrap(Flavor.dev);
