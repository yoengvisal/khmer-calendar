import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/weather_report.dart';
import '../../domain/repositories/weather_repository.dart';

enum WeatherStatus { initial, loading, success, failure }

final class WeatherState extends Equatable {
  const WeatherState({
    this.status = WeatherStatus.initial,
    this.report,
    this.failure,
  });

  final WeatherStatus status;

  /// Kept while refreshing so the UI doesn't flash.
  final WeatherReport? report;
  final AppFailure? failure;

  @override
  List<Object?> get props => [status, report, failure];
}

/// Shared by the home weather card and the Weather tab.
class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit(this._repository) : super(const WeatherState());

  final WeatherRepository _repository;

  Future<void> load({bool forceRefresh = false}) async {
    emit(WeatherState(status: WeatherStatus.loading, report: state.report));
    final result = await _repository.getWeather(forceRefresh: forceRefresh);
    if (isClosed) return;
    emit(
      result.fold(
        (report) => WeatherState(status: WeatherStatus.success, report: report),
        (failure) => WeatherState(
          status: WeatherStatus.failure,
          report: state.report,
          failure: failure,
        ),
      ),
    );
  }
}
