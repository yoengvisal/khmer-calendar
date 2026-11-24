import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/date/clock.dart';
import '../../core/logging/app_logger.dart';
import '../../core/network/api_client.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/key_value_store.dart';
import '../../features/calendar/domain/lunar/khmer_lunar_calendar.dart';
import '../../features/calendar/domain/usecases/get_month_calendar.dart';
import '../../features/calendar/domain/usecases/get_next_event.dart';
import '../../features/calendar/presentation/bloc/calendar_bloc.dart';
import '../../features/events/data/datasources/events_local_data_source.dart';
import '../../features/events/data/datasources/events_remote_data_source.dart';
import '../../features/events/data/repositories/events_repository_impl.dart';
import '../../features/events/domain/repositories/events_repository.dart';
import '../../features/events/domain/usecases/get_year_events.dart';
import '../../features/events/presentation/bloc/holidays_bloc.dart';
import '../../features/my_events/data/repositories/personal_events_repository_impl.dart';
import '../../features/my_events/domain/repositories/personal_events_repository.dart';
import '../../features/my_events/presentation/bloc/my_events_cubit.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/presentation/bloc/settings_cubit.dart';
import '../../features/weather/data/datasources/weather_remote_data_source.dart';
import '../../features/weather/data/repositories/weather_repository_impl.dart';
import '../../features/weather/domain/repositories/weather_repository.dart';
import '../../features/weather/presentation/bloc/weather_cubit.dart';
import '../config/app_config.dart';

/// Service locator. Only used here (composition root) and where route/page
/// level `BlocProvider`s create blocs. Domain/data classes use constructor
/// injection and never call [sl].
final GetIt sl = GetIt.instance;

/// Registers everything. [keyValueStore] and [eventsRemoteDataSource] can be
/// overridden (tests / tooling).
Future<void> configureDependencies(
  AppConfig config, {
  KeyValueStore? keyValueStore,
  EventsRemoteDataSource? eventsRemoteDataSource,
  WeatherRemoteDataSource? weatherRemoteDataSource,
  Clock clock = const Clock(),
}) async {
  await sl.reset();

  final logger = AppLogger(
    minLevel: config.flavor == Flavor.dev ? LogLevel.debug : LogLevel.info,
  );

  sl
    // Core
    ..registerSingleton<AppConfig>(config)
    ..registerSingleton<AppLogger>(logger)
    ..registerSingleton<Clock>(clock)
    ..registerSingleton<KeyValueStore>(
      keyValueStore ?? await SharedPreferencesStore.create(),
    )
    ..registerLazySingleton<Dio>(() => createDio(config, logger: logger))
    ..registerLazySingleton<ApiClient>(() => ApiClient(sl()))
    ..registerLazySingleton<KhmerLunarCalendar>(KhmerLunarCalendar.new)
    // Data sources
    ..registerLazySingleton<EventsRemoteDataSource>(
      () => eventsRemoteDataSource ?? ApiEventsRemoteDataSource(sl()),
    )
    ..registerLazySingleton<WeatherRemoteDataSource>(
      () => weatherRemoteDataSource ?? OpenMeteoDataSource(),
    )
    ..registerLazySingleton<EventsLocalDataSource>(
      () => PrefsEventsLocalDataSource(sl()),
    )
    // Repositories
    ..registerLazySingleton<EventsRepository>(
      () => EventsRepositoryImpl(
        remote: sl(),
        local: sl(),
        clock: sl(),
        logger: sl(),
      ),
    )
    ..registerLazySingleton<WeatherRepository>(
      () => WeatherRepositoryImpl(remote: sl(), store: sl(), clock: sl()),
    )
    ..registerLazySingleton<PersonalEventsRepository>(
      () => PersonalEventsRepositoryImpl(sl()),
    )
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(sl()),
    )
    // Use cases
    ..registerLazySingleton<GetYearEvents>(() => GetYearEvents(sl()))
    ..registerLazySingleton<GetMonthCalendar>(
      () => GetMonthCalendar(lunarCalendar: sl(), eventsRepository: sl()),
    )
    // Presentation (new instance per BlocProvider)
    ..registerFactory<CalendarBloc>(
      () => CalendarBloc(
        getMonthCalendar: sl(),
        getNextEvent: GetNextEvent(sl()),
        clock: sl(),
      ),
    )
    ..registerFactory<HolidaysBloc>(
      () => HolidaysBloc(getYearEvents: sl(), clock: sl()),
    )
    ..registerFactory<SettingsCubit>(() => SettingsCubit(sl()))
    ..registerFactory<WeatherCubit>(() => WeatherCubit(sl()))
    ..registerFactory<MyEventsCubit>(() => MyEventsCubit(sl()));
}
