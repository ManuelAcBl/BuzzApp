import 'dart:math';

import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_controller_notifier.dart';
import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_players_data_notifier.dart';
import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BuzzerPlayersNotifier extends Notifier<List<Player>> {
  @override
  List<Player> build() {
    Map<String, PlayerData>? data = ref.watch(BuzzerProviders.data);
    Map<int, BuzzerDevice> buzzers = ref.watch(BuzzerProviders.buzzers);

    if (data == null) return [];

    List<Player> players = [];

    for (MapEntry<int, BuzzerDevice> device in buzzers.entries) {
      players.addAll(
        List.generate(
          4,
          (index) {
            BuzzController controller = device.value.controllers[index]!;

            return Player(
              id: "${device.key}-$index",
              data: data[controller.persistentId] ?? PlayerData(name: "Cargando...", color: 0xFFFFFFFF),
              controller: controller,
            );
          },
        ),
      );
    }

    return players;
  }


  // TEST (REMOVE)
  void test() {
    int random = Random().nextInt(4);
    int random2 = Random().nextInt(5);

    state[random] = state[random].copyWith(
      controller: Controller(
        type: ControllerType.wirelessBuzzer,
        red: random2 == 0,
        blue: random2 == 1,
        green: random2 == 2,
        yellow: random2 == 3,
        orange: random2 == 4,
      ),
    );

    state = [...state];

    Future.delayed(
        Duration(seconds: 2),
        () {
           state[random] = state[random].copyWith(
              controller: Controller(
                type: ControllerType.wirelessBuzzer,
                red: false,
                blue: false,
                green: false,
                yellow: false,
                orange: false,
              ),
            );

          state = [...state];
        });
  }
}

class Player {
  final String id;
  final PlayerData data;
  final Controller controller;

  Player({required this.id, required this.data, required this.controller});

  Map<String, dynamic> toJson() => {
        'id': id,
        'data': data.toJson(),
        'controller': controller.toJson(),
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        data: PlayerData.fromJson(json['data'] as Map<String, dynamic>),
        controller: Controller.fromJson(json['controller'] as Map<String, dynamic>),
      );

  Player copyWith({PlayerData? data, Controller? controller}) => Player(
        id: id,
        data: data ?? this.data,
        controller: controller ?? this.controller,
      );
}
