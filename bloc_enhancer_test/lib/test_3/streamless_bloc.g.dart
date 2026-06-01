// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streamless_bloc.dart';

// **************************************************************************
// BlocEnhancerGenerator
// **************************************************************************

class _StreamlessCounterBlocEvents {
  const _StreamlessCounterBlocEvents(this._bloc);

  final StreamlessCounterBloc _bloc;

  void increment() {
    if (_bloc.isClosed) return;
    _bloc.add(_Increment());
  }
}

extension $StreamlessCounterBlocEventsX on StreamlessCounterBloc {
  _StreamlessCounterBlocEvents get events => _StreamlessCounterBlocEvents(this);
}

/// Creates a new instance of [StreamlessEvent] with the given parameters
///
/// Intended to be used for **_TESTING_** purposes only.
class _$StreamlessEventCreator {
  const _$StreamlessEventCreator();

  _Increment increment() => _Increment();
}

extension $StreamlessStateTypingX on StreamlessState {
  bool get isInitial => this is _Initial;

  _Initial get asInitial => this as _Initial;

  _Initial? get asIfInitial => this is _Initial ? this as _Initial : null;

  bool get isReady => this is _Ready;

  _Ready get asReady => this as _Ready;

  _Ready? get asIfReady => this is _Ready ? this as _Ready : null;
}
