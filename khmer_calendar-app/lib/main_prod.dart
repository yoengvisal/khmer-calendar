import 'app/bootstrap.dart';
import 'app/config/app_config.dart';

/// Run: fvm flutter run --flavor production -t lib/main_prod.dart \
///   --dart-define-from-file=config/production.json
Future<void> main() => bootstrap(Flavor.production);
