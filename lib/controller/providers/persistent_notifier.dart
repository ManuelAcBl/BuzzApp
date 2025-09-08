import 'package:buzz_app/controller/providers/local_save.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class PersistentNotifier<T> extends Notifier<T?> {
  final T _value;
  final T Function(Map<String, dynamic> json) fromJson;
  final Map<String, dynamic>? Function(T? data) toJson;

  late final LocalSave<T> saver;

  PersistentNotifier({required String id, required T value, required this.fromJson, required this.toJson}) : _value = value {
    saver = LocalSave(
      id: id,
      value: _value,
      fromJson: fromJson,
      toJson: toJson,
    );
  }

  @override
  T? build() {
    Future(() async => state = await saver.load());

    return null;
  }

  void reset() => state = _value;

  @override
  bool updateShouldNotify(previous, next) {
    saver.save(next);

    return true;
  }
}
