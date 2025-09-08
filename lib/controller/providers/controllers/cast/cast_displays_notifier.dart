import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CastDisplaysNotifier extends Notifier<Map<int, CastDisplay>> {
  final EventChannel _events = EventChannel('cast_events');
  final MethodChannel _methods = MethodChannel('cast_methods');

  @override
  Map<int, CastDisplay> build() {
    Future(() async {
      String response = (await _methods.invokeMethod("list"));

      List<CastDisplay> displays = CastDisplayList.fromJson(jsonDecode(response)).list;

      state = Map.fromEntries(displays.map((display) => MapEntry(display.id, display)));

      CastDisplay? display = displays.firstOrNull;

      if (display == null || display.active) return;

      _methods.invokeMethod("start", {'displayId': display.id});
    });

    _events.receiveBroadcastStream().listen((data) {
      print("LISTEN: $data");

      MapEntry<String, dynamic> json = jsonDecode(data).entries.first;

      switch (json.key) {
        case "add":
          _methods.invokeMethod("start", {'displayId': json.value['id']});
          break;

        case "remove":
          state = state..remove(json.value['id']);
          break;

        case "change":
          state = state..[json.value['id']] = CastDisplay.fromJson(json.value);
          break;
      }
    });

    return {};
  }

  void start(int displayId) => _methods.invokeMethod("start", {'displayId': displayId});

  void stop(int displayId) => _methods.invokeMethod("stop", {'displayId': displayId});

  void settings() => _methods.invokeMethod("settings");

  @override
  bool updateShouldNotify(previous, next) => true;
}

class CastDisplayList {
  final List<CastDisplay> list;

  CastDisplayList({required this.list});

  Map<String, dynamic> toJson() => {
        'list': list.map((display) => display.toJson()).toList(),
      };

  factory CastDisplayList.fromJson(Map<String, dynamic> json) => CastDisplayList(
        list: (json['list'] as List<dynamic>)
            .map(
              (item) => CastDisplay.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
      );
}

class CastDisplay {
  final int id;
  final String name;
  final int width, height;
  final bool active;

  CastDisplay({required this.id, required this.name, required this.width, required this.height, required this.active});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'width': width,
        'height': height,
        'active': active,
      };

  factory CastDisplay.fromJson(Map<String, dynamic> json) => CastDisplay(
        id: json['id'] as int,
        name: json['name'] as String,
        width: json['width'] as int,
        height: json['height'] as int,
        active: json['active'] as bool,
      );
}
