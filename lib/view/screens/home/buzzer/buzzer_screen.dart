import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_players_notifier.dart';
import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_providers.dart';
import 'package:buzz_app/view/widgets/appbar/custom_app_bar_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BuzzerScreen extends ConsumerStatefulWidget {

  const BuzzerScreen({super.key});

  @override
  ConsumerState<BuzzerScreen> createState() => _ResponseScreenState();
}

class _ResponseScreenState extends ConsumerState<BuzzerScreen> {
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
      for (Player player in players) {
        String id = player.id;
        Controller controller = player.controller;

        if (responses.containsKey(id)) continue;

        if(controller.red) {
          setState(
                () {
              responses[id] = Response(
                text: "",
                color: colors[0],
                time: DateTime.now(),
              );

              responses = Map.fromEntries(responses.entries.toList()..sort((one, other) => one.value.time.compareTo(other.value.time)));
            },
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: CustomAppBarTitle(title: "Pulsador"),
        actions: [
          TextButton(
            onPressed: () => setState(() => responses = {}),
            child: Text("Reiniciar"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: responses.keys.map(
                (id) {
                  Player player = players.firstWhere((player) => player.id == id);

                  return PlayerPulsatorTile(
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
                    (player) => PlayerPulsatorTile(
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

class PlayerPulsatorTile extends StatelessWidget {
  final DateTime? first;
  final Player player;
  final Response? response;

  const PlayerPulsatorTile({super.key, required this.player, this.response, this.first});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: response != null ? Icon(Icons.check) : WaitingIcon(),
      title: Row(
        children: [
          Icon(
            Icons.circle,
            color: Color(player.data.color),
          ),
          Text(player.data.name),
        ],
      ),
      trailing: Builder(builder: (context) {
        if (first == null || response == null) return SizedBox();

        return Text("${response!.time.difference(first!).inMilliseconds}ms");
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
