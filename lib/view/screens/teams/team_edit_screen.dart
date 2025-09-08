import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_players_notifier.dart';
import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TeamEditScreen extends ConsumerStatefulWidget {
  final int index;

  const TeamEditScreen({super.key, required this.index});

  @override
  ConsumerState<TeamEditScreen> createState() => _TeamEditScreenState();
}

class _TeamEditScreenState extends ConsumerState<TeamEditScreen> {
  late final Player _team;

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late Color _color;

  @override
  void initState() {
    super.initState();

    _team = ref.read(BuzzerProviders.players.select((players) => players[widget.index]));

    _nameController = TextEditingController(text: _team.data.name);
    _color = Color(_team.data.color);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Equipo ${widget.index + 1}"),
        actions: [
          TextButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;

              ref.read(BuzzerProviders.data.notifier).set(
                    (_team.controller as BuzzController).persistentId,
                    name: _nameController.text,
                    color: _color.value,
                  );

              context.pop();
            },
            child: Text("Guardar"),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  setState(() {
                    _nameController.text = _team.data.name;
                    _color = Color(_team.data.color);
                  });
                },
                child: Text("Resetear"),
              ),
            ],
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
          child: Column(
            spacing: 20,
            children: [
              TextFormField(
                controller: _nameController,
                validator: (text) => text?.isEmpty == true ? "El jugador tiene que tener un nombre" : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Nombre",
                ),
              ),
              ListTile(
                tileColor: _color,
                onTap: () async {
                  Color? color = await context.push("/team/edit/color", extra: _color);

                  if (color != null) setState(() => _color = color);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ColorPickerScreen extends StatefulWidget {
  final Color color;

  const ColorPickerScreen({super.key, required this.color});

  @override
  State<ColorPickerScreen> createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen> {
  late Color _color;

  @override
  void initState() {
    super.initState();

    _color = widget.color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ColorPicker(
              pickerColor: _color,
              onColorChanged: (color) => setState(() => _color = color),
            ),
            FilledButton(
              onPressed: () => context.pop(_color),
              child: Text("Seleccionar"),
            ),
          ],
        ),
      ),
    );
  }
}
