import 'dart:convert';
import 'dart:math';

import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_controller_notifier.dart';
import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuzzerPlayerDataNotifier extends Notifier<Map<String, PlayerData>?> {
  static const String key = "buzz_player_data";

  @override
  Map<String, PlayerData>? build() {
    Future(() async => state = await _load() ?? {});

    ref.listen(BuzzerProviders.buzzers, (_, buzzers) {
      Map<String, PlayerData> add = {};

      int value = 0;

      for (MapEntry<int, BuzzerDevice> device in buzzers.entries) {
        for (int index = 0; index < 4; index++) {
          BuzzController controller = device.value.controllers[index]!;

          if (state?.containsKey(controller.persistentId) == true) continue;

          add[controller.persistentId] = PlayerData(
            name: "Equipo ${++value}",
            color: 0xFF000000 + Random().nextInt(0xFFFFFF),
          );
        }
      }

      state = state?..addAll(add);
    });

    return {
      'equipo1': PlayerData(name: "Equipo 1", color: 0xFF000000),
      'equipo2': PlayerData(name: "Equipo 2", color: 0x00FF0000),
      'equipo3': PlayerData(name: "Equipo 3", color: 0x0000FF00),
      'equipo4': PlayerData(name: "Equipo 4", color: 0xFF00FF00),
    };

    return null;
  }

  Future<Map<String, PlayerData>?> _load() async {
    SharedPreferences local = await SharedPreferences.getInstance();

    String? string = local.getString(key);

    if (string == null) return null;

    BuzzerPlayerDataSave? data;

    try {
      data = BuzzerPlayerDataSave.fromJson(jsonDecode(string));
    } catch (e) {
      print("JSON PARSE: $string");
    }

    return data?.players;
  }

  Future<void> _save() async {
    SharedPreferences local = await SharedPreferences.getInstance();

    if (state == null) {
      await local.remove(key);
      return;
    }

    await local.setString(
      key,
      jsonEncode(BuzzerPlayerDataSave(players: state!)),
    );
  }

  @override
  bool updateShouldNotify(previous, next) {
    print("--- DATA ---");

    state?.forEach((id, data) {
      print("$id: ${data.name}");
    });

    print("---------");

    _save();
    return true;
  }

  void set(String id, {String? name, int? color}) => state = state!..[id] = state![id]!.copyWith(name: name, color: color);

  void clear() => state = {};
}

class PlayerData {
  final String name;
  final int color;

  PlayerData({required this.name, required this.color});

  Map<String, dynamic> toJson() => {
        'name': name,
        'color': color,
      };

  factory PlayerData.fromJson(Map<String, dynamic> json) => PlayerData(
        name: json['name'] as String,
        color: json['color'] as int,
      );

  PlayerData copyWith({String? name, int? color}) => PlayerData(
        name: name ?? this.name,
        color: color ?? this.color,
      );
}

class BuzzerPlayerDataSave {
  final Map<String, PlayerData> players;

  BuzzerPlayerDataSave({required this.players});

  Map<String, dynamic> toJson() => {
        'players': players.map((key, player) => MapEntry(key, player.toJson())),
      };

  factory BuzzerPlayerDataSave.fromJson(Map<String, dynamic> json) => BuzzerPlayerDataSave(
        players: (json['players'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, PlayerData.fromJson(value as Map<String, dynamic>)),
        ),
      );
}
