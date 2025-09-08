import 'package:buzz_app/controller/providers/Providers.dart';
import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_controller_notifier.dart';
import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ControllerScreen extends ConsumerWidget {
  const ControllerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mandos"),
      ),
      body: ControllerList(),
    );
  }
}

class ControllerList extends ConsumerWidget {
  const ControllerList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Iterable<BuzzerDevice> devices = ref.watch(BuzzerProviders.buzzers.select((devices) => devices.values));

    if (devices.isEmpty) {
      return Center(child: Text("No hay mandos conectados :("));
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(64),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 30,
        children: devices.map((device) => DeviceListElement(device: device)).toList(),
      ),
    );
  }
}

class DeviceListElement extends StatelessWidget {
  final BuzzerDevice device;

  const DeviceListElement({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    Map<int, Controller> controllers = device.controllers;

    return Column(
      children: [
        DeviceListTile(device: device),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            spacing: 10,
            children: [
              Flexible(child: ControllerWidget(number: 1, controller: controllers[0]!)),
              Flexible(child: ControllerWidget(number: 2, controller: controllers[1]!)),
              Flexible(child: ControllerWidget(number: 3, controller: controllers[2]!)),
              Flexible(child: ControllerWidget(number: 4, controller: controllers[3]!)),
            ],
          ),
        ),
      ],
    );
  }
}

class DeviceListTile extends StatelessWidget {
  final BuzzerDevice device;

  const DeviceListTile({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      title: Text(
        device.model.name,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: IconButton(
        onPressed: () => showModalBottomSheet(
          context: Scaffold.of(Scaffold.of(context).context).context,
          builder: (context) => DeviceDataBottomSheet(device: device),
        ),
        icon: Icon(Icons.info),
      ),
    );
  }
}

class DeviceDataBottomSheet extends StatelessWidget {
  final BuzzerDevice device;

  const DeviceDataBottomSheet({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {},
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            Text(
              device.model.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Device ID: ${device.id.toString()}",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Text(
              "Vendor ID: ${device.model.vendorId.toString()}",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Text(
              "Product ID: ${device.model.productId.toString()}",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ControllerWidget extends StatelessWidget {
  final int? number;
  final Controller controller;

  const ControllerWidget({super.key, required this.number, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2 / 5,
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(25, 25, 25, 1),
          borderRadius: BorderRadius.all(Radius.circular(75)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 40, left: 10, right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MainButtonWidget(number: number, active: controller.red),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ColorButtonWidget(color: Colors.blue, active: controller.blue),
                    ColorButtonWidget(color: Colors.deepOrangeAccent, active: controller.orange),
                    ColorButtonWidget(color: Colors.green, active: controller.green),
                    ColorButtonWidget(color: Colors.yellow, active: controller.yellow),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MainButtonWidget extends StatelessWidget {
  final int? number;
  final bool active;

  const MainButtonWidget({super.key, required this.number, required this.active});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1 / 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red.withAlpha(active ? 255 : 128),
          borderRadius: BorderRadius.all(Radius.circular(100)),
        ),
        child: Center(
          child: Text(
            number?.toString() ?? "",
            style: TextStyle(fontSize: 30),
          ),
        ),
      ),
    );
  }
}

class ColorButtonWidget extends StatelessWidget {
  final Color color;
  final bool active;

  const ColorButtonWidget({super.key, required this.color, required this.active});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 1,
      child: Container(
        decoration: BoxDecoration(
          color: color.withAlpha(active ? 255 : 128),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }
}
