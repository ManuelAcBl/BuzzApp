import 'package:buzz_app/controller/providers/controllers/cast/cast_displays_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class CastProviders {
  static final displays = NotifierProvider<CastDisplaysNotifier, Map<int, CastDisplay>>(CastDisplaysNotifier.new);
}