import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/async/cancel_signal.dart';
import '../../../../core/date/civil_date.dart';
import '../../../../core/date/clock.dart';
import '../../../events/domain/entities/calendar_event.dart';
import '../../domain/entities/calendar_month.dart';
import '../../domain/entities/year_month.dart';
import '../../domain/usecases/get_month_calendar.dart';
import '../../domain/usecases/get_next_event.dart';

part 'calendar_bloc_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarBlocEvent, CalendarState> {
  CalendarBloc({
    required this._getMonthCalendar,
    this._getNextEvent,
    Clock clock = const Clock(),
  }) : _clock = clock,
       super(
         CalendarState(
           visibleMonth: YearMonth.of(clock.today()),
           today: clock.today(),
         ),
       ) {
    on<CalendarStarted>((_, emit) async {
      await _load(state.visibleMonth, emit);
      await _loadNextEvent(emit);
    });
    on<CalendarMonthShifted>(
      (event, emit) => _load(state.visibleMonth.addMonths(event.delta), emit),
    );
    on<CalendarMonthSelected>((event, emit) => _load(event.month, emit));
    on<CalendarTodayRequested>(
      (_, emit) => _load(YearMonth.of(_clock.today()), emit),
    );
    on<CalendarRefreshRequested>((_, emit) async {
      await _load(state.visibleMonth, emit);
      await _loadNextEvent(emit);
    });
  }

  final GetMonthCalendar _getMonthCalendar;
  final GetNextEvent? _getNextEvent;
  final Clock _clock;
  CancelSignal? _inFlight;

  Future<void> _load(YearMonth target, Emitter<CalendarState> emit) async {
    // Latest request wins: cancel the previous month's network call.
    _inFlight?.cancel();
    final signal = _inFlight = CancelSignal();

    emit(
      state.copyWith(
        visibleMonth: target,
        today: _clock.today(),
        status: CalendarStatus.loading,
        month: () => null,
      ),
    );

    final month = await _getMonthCalendar(
      target.year,
      target.month,
      cancelSignal: signal,
    );

    if (signal.isCancelled || state.visibleMonth != target) return;
    emit(state.copyWith(status: CalendarStatus.success, month: () => month));
  }

  /// Upcoming event for the "next holiday" card; failures just hide the card.
  Future<void> _loadNextEvent(Emitter<CalendarState> emit) async {
    final getNextEvent = _getNextEvent;
    if (getNextEvent == null) return;
    final next = await getNextEvent(_clock.today());
    if (!isClosed) emit(state.copyWith(nextEvent: () => next));
  }

  @override
  Future<void> close() {
    _inFlight?.cancel();
    return super.close();
  }
}
