import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_controller_notifier.dart';
import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_players_data_notifier.dart';
import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_players_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BuzzerProviders {
  static final buzzers = NotifierProvider<BuzzerControllerNotifier, Map<int, BuzzerDevice>>(BuzzerControllerNotifier.new);
  static final data = NotifierProvider<BuzzerPlayerDataNotifier, Map<String, PlayerData>?>(BuzzerPlayerDataNotifier.new);
  static final players = NotifierProvider<BuzzerPlayersNotifier, List<Player>>(BuzzerPlayersNotifier.new);
}

class BuzzController extends Controller {
  final int deviceId;
  final String persistentId;

  BuzzController({
    required this.deviceId,
    required this.persistentId,
    required super.type,
    super.red = false,
    super.blue = false,
    super.orange = false,
    super.green = false,
    super.yellow = false,
    super.light = false,
  });

  @override
  BuzzController copyWith({bool? red, bool? blue, bool? orange, bool? green, bool? yellow, bool? light}) => BuzzController(
        deviceId: deviceId,
        persistentId: persistentId,
        type: type,
        red: red ?? this.red,
        blue: blue ?? this.blue,
        orange: orange ?? this.orange,
        green: green ?? this.green,
        yellow: yellow ?? this.yellow,
        light: light ?? this.light,
      );
}

class Controller {
  static const Color redColor = Colors.red;
  static const Color blueColor = Colors.blueAccent;
  static const Color orangeColor = Colors.deepOrangeAccent;
  static const Color greenColor = Colors.green;
  static const Color yellowColor = Colors.amber;

  final ControllerType type;
  final bool red, blue, orange, green, yellow, light;

  Controller({
    required this.type,
    this.red = false,
    this.blue = false,
    this.orange = false,
    this.green = false,
    this.yellow = false,
    this.light = false,
  });

  Controller copyWith({bool? red, bool? blue, bool? orange, bool? green, bool? yellow, bool? light}) => Controller(
        type: type,
        red: red ?? this.red,
        blue: blue ?? this.blue,
        orange: orange ?? this.orange,
        green: green ?? this.green,
        yellow: yellow ?? this.yellow,
        light: light ?? this.light,
      );

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'red': red,
        'blue': blue,
        'orange': orange,
        'green': green,
        'yellow': yellow,
        'light': light,
      };

  factory Controller.fromJson(Map<String, dynamic> json) => Controller(
        type: ControllerType.values.byName(json['type']),
        red: json['red'],
        blue: json['blue'],
        orange: json['orange'],
        green: json['green'],
        yellow: json['yellow'],
        light: json['light'],
      );
}
