import 'dart:async';
import 'dart:convert';

import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BuzzerControllerNotifier extends Notifier<Map<int, BuzzerDevice>> {
  // {deviceId: BuzzerDevice}
  static const EventChannel _events = EventChannel('usb_events');
  static const MethodChannel _methods = MethodChannel('usb_commands');

  BuzzerControllerNotifier() {
    _events.receiveBroadcastStream().listen((event) {
      print(event);

      MapEntry<String, dynamic> data = jsonDecode(event).entries.first;

      switch (data.key) {
        case 'attached':
          BuzzerModels? deviceData = BuzzerModels.search(
            vendorId: data.value['vendorId'],
            productId: data.value['productId'],
          );

          int id = data.value['id'];

          if (deviceData == null || state.containsKey(id)) return;

          state = state..[id] = BuzzerDevice(id: id, model: deviceData);
          print("ATTACHED");

          break;

        case 'detached':
          int id = data.value['id'];

          if (!state.containsKey(id)) return;

          state = state..remove(id);
          print("DETACHED");

          break;

        case 'input':
          int id = data.value['device'];

          BuzzerDevice? device = state[id];

          if (device == null) return;

          bool b(int index) => data.value['bytes'][index] == "1";

          state = state
            ..[id] = device.copyWith(
              controllers: device.controllers.map(
                (index, controller) => MapEntry(
                  index,
                  switch (index) {
                    0 => controller.copyWith(red: b(8), blue: b(4), orange: b(5), green: b(6), yellow: b(7)),
                    1 => controller.copyWith(red: b(13), blue: b(9), orange: b(10), green: b(11), yellow: b(12)),
                    2 => controller.copyWith(red: b(18), blue: b(14), orange: b(15), green: b(16), yellow: b(17)),
                    3 => controller.copyWith(red: b(23), blue: b(19), orange: b(20), green: b(21), yellow: b(22)),
                    int() => throw UnimplementedError(),
                  },
                ),
              ),
            );

          break;

        default:
          print("MENSAJE DESCONOCIDO: $data");
          break;
      }
    }, onError: (error) {
      print("ERROR GARRAFAL");
    });

    // TEST (REMOVE)
    Future(() => state = state..[1024] = BuzzerDevice(id: 1024, model: BuzzerModels.wireless));
  }

  void setLight(int deviceId, int index, bool on) {
    BuzzerDevice? device = state[deviceId];

    if (device == null) return;

    Uint8List bytes = Uint8List.fromList([0x00, ...List.generate(4, (index) => state[deviceId]!.controllers[index]!.light ? 0xFF : 0x00)]);

    bytes[index] = on ? 0xFF : 0x00;

    _methods.invokeMethod("output", {
      "id": deviceId,
      "bytes": bytes,
    });
  }

  @override
  bool updateShouldNotify(Map previous, Map next) => true;

  @override
  Map<int, BuzzerDevice> build() => {};
}

class BuzzerDevice {
  final int id;
  final BuzzerModels model;
  final Map<int, BuzzController> controllers;

  BuzzerDevice({required this.id, required this.model, Map<int, BuzzController>? controllers})
      : controllers = controllers ??
            Map.fromEntries(
              List.generate(
                4,
                (index) => MapEntry(
                  index,
                  BuzzController(
                    deviceId: id,
                    persistentId: "$id-$index",
                    type: switch (model) {
                      BuzzerModels.wireless => ControllerType.wirelessBuzzer,
                    },
                  ),
                ),
              ),
            );

  BuzzerDevice copyWith({Map<int, BuzzController>? controllers}) => BuzzerDevice(
        id: id,
        model: model,
        controllers: controllers ?? this.controllers,
      );
}

enum ControllerType {
  wiredBuzzer,
  wirelessBuzzer,
  smartphone;
}

enum BuzzerModels {
  wireless(vendorId: 1356, productId: 4096, name: "Mandos Buzz! Inalámbricos");

  final int vendorId, productId;
  final String name;

  const BuzzerModels({required this.vendorId, required this.productId, required this.name});

  static BuzzerModels? search({required int? vendorId, required int? productId}) {
    BuzzerModels? result;

    for (BuzzerModels device in BuzzerModels.values) {
      if (device.vendorId == vendorId && device.productId == productId) {
        result = device;

        break;
      }
    }

    return result;
  }
}
