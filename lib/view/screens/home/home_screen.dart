import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_providers.dart';
import 'package:buzz_app/view/widgets/appbar/custom_app_bar_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: CustomAppBarTitle(title: "Modos de Juego"),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  ref.read(BuzzerProviders.data.notifier).clear();
                },
                child: Text("Clear Buzzer Cache"),
              )
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GameMode(
              onTap: () => context.push('/game/responses'),
              name: "Respuestas",
              description: "Selecciona una de las respuestas disponibles.",
            ),
            // GameMode(
            //   onTap: () => context.push('/game/numbers'),
            //   name: "Cifras",
            //   description: "Elige una cifra como respuesta.",
            // ),
            GameMode(
              onTap: () => context.push('/game/buzzer'),
              name: "Pulsador",
              description: "Sé el primero en pulsarlo.",
            ),
          ],
        ),
      ),
    );
  }
}

class GameMode extends StatelessWidget {
  final String name, description;
  final VoidCallback onTap;

  const GameMode({super.key, required this.name, required this.description, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(description),
    );
  }
}
