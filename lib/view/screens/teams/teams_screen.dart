import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_controller_notifier.dart';
import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_players_notifier.dart';
import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_providers.dart';
import 'package:buzz_app/view/widgets/icons/custom_icons_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TeamsScreen extends ConsumerWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Jugadores"),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              // PopupMenuItem(
              //   onTap: ref.read(Providers.players.notifier).reset,
              //   child: Text("Resetear"),
              // ),
            ],
          ),
        ],
      ),
      body: TeamList(),
    );
  }
}

class TeamList extends ConsumerWidget {
  const TeamList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int? length = ref.watch(BuzzerProviders.players.select((teams) => teams.length));

    if (length == null) return Text("Cargando...");

    return Column(
      children: List.generate(length, (index) => TeamListTile(index: index)),
    );
  }
}

class TeamListTile extends ConsumerWidget {
  final int index;

  const TeamListTile({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Player? team = ref.watch(BuzzerProviders.players.select((teams) => (teams.length > index && teams.isNotEmpty) ? teams[index] : null));

    BuzzerControllerNotifier notifier = ref.read(BuzzerProviders.buzzers.notifier);

    if (team == null) return SizedBox();

    return ListTile(
      onTap: () => context.push("/team/edit", extra: index),
      //onTap: () => notifier.setLight((team.controller as BuzzController).deviceId, index, !team.controller.light),
      leading: Icon(
        Icons.circle,
        color: Color(team.data.color),
      ),
      title: Text(team.data.name),
      subtitle: Text("Mando ${index + 1}"),
      trailing: Badge(
        label: Text("${index + 1}"),
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          switch (team.controller.type) {
            ControllerType.wiredBuzzer => CustomIcons.wired_buzz_controller,
            ControllerType.wirelessBuzzer => CustomIcons.wireless_buzz_controller,
            ControllerType.smartphone => Icons.phone_android,
          },
        ),
      ),
      tileColor: team.controller.red ? Colors.red.withAlpha(64) : null,
    );
  }
}
