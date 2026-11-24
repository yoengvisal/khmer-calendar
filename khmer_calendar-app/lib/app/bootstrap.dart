import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../core/logging/app_logger.dart';
import 'app.dart';
import 'config/app_config.dart';
import 'config/config_error_app.dart';
import 'di/injection.dart';
import 'router/app_router.dart';

/// Shared startup for every flavor entry point (`main_<flavor>.dart`).
Future<void> bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppConfig config;
  try {
    config = AppConfig.fromEnvironment(expectedFlavor: flavor);
  } on ConfigException catch (e) {
    const AppLogger().error(e.message);
    runApp(ConfigErrorApp(message: e.message));
    return;
  }

  await configureDependencies(config);
  final logger = sl<AppLogger>()..info('Starting with $config');

  FlutterError.onError = (details) {
    logger.error('Flutter error', details.exception, details.stack);
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error('Uncaught error', error, stack);
    return true;
  };
  Bloc.observer = _LoggingBlocObserver(logger);

  runApp(
    KhmerCalendarApp(
      config: config,
      router: createAppRouter(),
      createSettingsCubit: sl.call,
    ),
  );
}

class _LoggingBlocObserver extends BlocObserver {
  const _LoggingBlocObserver(this._logger);

  final AppLogger _logger;

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _logger.error('${bloc.runtimeType} error', error, stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
