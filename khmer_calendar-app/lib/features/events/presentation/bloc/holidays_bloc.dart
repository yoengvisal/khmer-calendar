import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/async/cancel_signal.dart';
import '../../../../core/date/civil_date.dart';
import '../../../../core/date/clock.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/usecases/get_year_events.dart';

part 'holidays_event.dart';
part 'holidays_state.dart';

class HolidaysBloc extends Bloc<HolidaysEvent, HolidaysState> {
  HolidaysBloc({required this._getYearEvents, Clock clock = const Clock()})
    : _clock = clock,
      super(HolidaysInitial(year: clock.today().year)) {
    on<HolidaysStarted>((_, emit) => _load(state.year, emit));
    on<HolidaysYearShifted>(
      (event, emit) => _load(state.year + event.delta, emit),
    );
    on<HolidaysRefreshRequested>((event, emit) async {
      try {
        await _load(state.year, emit, forceRefresh: true);
      } finally {
        event.completer?.complete();
      }
    });
  }

  final GetYearEvents _getYearEvents;
  final Clock _clock;
  CancelSignal? _inFlight;

  Future<void> _load(
    int year,
    Emitter<HolidaysState> emit, {
    bool forceRefresh = false,
  }) async {
    _inFlight?.cancel();
    final signal = _inFlight = CancelSignal();

    // A refresh keeps the current list on screen (RefreshIndicator shows
    // progress); everything else shows an explicit loading state.
    final keepContent =
        forceRefresh && year == state.year && state is HolidaysSuccess;
    if (!keepContent) emit(HolidaysLoading(year: year));

    final result = await _getYearEvents(
      year,
      forceRefresh: forceRefresh,
      cancelSignal: signal,
    );
    if (signal.isCancelled) return;

    emit(switch (result) {
      Ok(:final value) when value.events.isEmpty => HolidaysEmpty(
        year: year,
        isStale: value.isFromCache,
      ),
      Ok(:final value) => HolidaysSuccess(
        year: year,
        events: value.events,
        today: _clock.today(),
        isStale: value.isFromCache,
        savedAt: value.savedAt,
      ),
      Err(:final error) => HolidaysFailure(year: year, failure: error),
    });
  }

  @override
  Future<void> close() {
    _inFlight?.cancel();
    return super.close();
  }
}
