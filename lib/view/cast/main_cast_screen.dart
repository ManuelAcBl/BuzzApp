import 'dart:convert';

import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_players_notifier.dart';
import 'package:buzz_app/view/screens/controller/controller_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MainCastScreen extends StatelessWidget {
  final StatefulNavigationShell shell;

  const MainCastScreen({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomSheet: BottomCastMainScreen(),
    );
  }
}

class BottomCastMainScreen extends StatefulWidget {
  const BottomCastMainScreen({super.key});

  @override
  State<BottomCastMainScreen> createState() => _BottomCastMainScreenState();
}

class _BottomCastMainScreenState extends State<BottomCastMainScreen> {
  final EventChannel _events = EventChannel('cast_events');


  @override
  void initState() {
    _events.receiveBroadcastStream().listen((data) {
      Map<String, dynamic> json = jsonDecode(data);

      MapEntry<String, dynamic> element = json.entries.first;

      print(data);
      main:
      switch (element.key) {
        case "data":
          element = element.value.entries.first;
          switch (element.key) {
            case "player":
              Player player = Player.fromJson(json);

              break main;
          }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class BottomCastMainScreenPlayer extends ConsumerWidget {
  final Player player;

  const BottomCastMainScreenPlayer({super.key, required this.player});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomPaint(
      painter: ControllerPainter(controller: player.controller),
    );
  }
}
