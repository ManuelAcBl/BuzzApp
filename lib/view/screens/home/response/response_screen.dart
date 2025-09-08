import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_players_notifier.dart';
import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_providers.dart';
import 'package:buzz_app/view/widgets/appbar/custom_app_bar_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResponseScreen extends ConsumerStatefulWidget {
  final List<String> responses;

  const ResponseScreen({super.key, required this.responses});

  @override
  ConsumerState<ResponseScreen> createState() => _ResponseScreenState();
}

class _ResponseScreenState extends ConsumerState<ResponseScreen> {
  final colors = [Controller.blueColor, Controller.orangeColor, Controller.greenColor, Controller.yellowColor];

  Map<String, Response> responses = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Player> players = ref.read(BuzzerProviders.players);

    ref.listen(BuzzerProviders.players, (_, players) {
      main:
      for (Player player in players) {
        String id = player.id;
        Controller controller = player.controller;

        if (responses.containsKey(id)) continue;

        List<bool> buttons = [controller.blue, controller.orange, controller.green, controller.yellow];

        for (int index = 0; index < buttons.length; index++) {
          if (buttons[index]) {
            setState(
              () {
                responses[id] = Response(
                  text: widget.responses[index],
                  color: colors[index],
                  time: DateTime.now(),
                );

                responses = Map.fromEntries(responses.entries.toList()..sort((one, other) => one.value.time.compareTo(other.value.time)));
              },
            );

            continue main;
          }
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: CustomAppBarTitle(title: "Respuestas"),
        actions: [
          TextButton(
            onPressed: () => setState(() => responses = {}),
            child: Text("Reiniciar"),
          ),
          IconButton(
            onPressed: () => ref.read(BuzzerProviders.players.notifier).test(),
            icon: Icon(Icons.more_vert),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: responses.keys.map(
                (id) {
                  Player player = players.firstWhere((player) => player.id == id);

                  return PlayerResponseTile(
                    first: responses.entries.firstOrNull?.value.time,
                    player: player,
                    response: responses[player.id],
                  );
                },
              ).toList(),
            ),
            Column(
              children: players
                  .where((player) => !responses.containsKey(player.id))
                  .map(
                    (player) => PlayerResponseTile(
                      player: player,
                    ),
                  )
                  .toList(),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class PlayerResponseTile extends StatelessWidget {
  final DateTime? first;
  final Player player;
  final Response? response;

  const PlayerResponseTile({super.key, required this.player, this.response, this.first});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: response != null
          ? Text(
              response?.text ?? "",
              style: TextStyle(
                color: response?.color,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            )
          : SizedBox(),
      title: Row(
        children: [
          Icon(
            Icons.circle,
            color: Color(player.data.color),
          ),
          SizedBox(
            width: 20,
          ),
          Text(player.data.name),
        ],
      ),
      subtitle: response == null
          ? Text(
              "Esperando respuesta...",
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            )
          : SizedBox(),
      trailing: Builder(builder: (context) {
        if (first == null || response == null) return SizedBox();

        return Text(
          "${response!.time.difference(first!).inMilliseconds}ms",
          style: TextStyle(fontSize: 15),
        );
      }),
      selected: response?.time.compareTo(first!) == 0,
      selectedTileColor: Colors.green.withAlpha(48),
    );
  }
}

class WaitingIcon extends StatelessWidget {
  const WaitingIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(),
    );
  }
}

class Response {
  final String text;
  final Color color;
  final DateTime time;

  Response({required this.text, required this.color, required this.time});
}
