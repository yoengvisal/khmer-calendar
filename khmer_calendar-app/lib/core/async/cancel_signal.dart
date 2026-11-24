import 'dart:async';

/// Framework-free cancellation handle so domain/use-case signatures do not
/// depend on Dio. The data layer adapts it to a Dio `CancelToken`.
class CancelSignal {
  final Completer<void> _completer = Completer<void>();

  bool get isCancelled => _completer.isCompleted;

  Future<void> get whenCancelled => _completer.future;

  void cancel() {
    if (!_completer.isCompleted) _completer.complete();
  }
}
