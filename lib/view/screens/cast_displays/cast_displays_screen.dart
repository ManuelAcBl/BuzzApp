import 'package:buzz_app/controller/providers/controllers/cast/cast_displays_notifier.dart';
import 'package:buzz_app/controller/providers/controllers/cast/cast_providers.dart';
import 'package:buzz_app/view/widgets/appbar/custom_app_bar_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CastDisplaysScreen extends ConsumerWidget {
  const CastDisplaysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Iterable<CastDisplay> displays = ref.watch(CastProviders.displays.select((displays) => displays.values));

    return Scaffold(
      appBar: AppBar(
        title: CustomAppBarTitle(title: "Pantallas"),
        actions: [
          IconButton(
            onPressed: ref.read(CastProviders.displays.notifier).settings,
            icon: Icon(Icons.settings),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: displays.map((display) => CastDisplayTile(display: display)).toList(),
        ),
      ),
    );
  }
}

class CastDisplayTile extends ConsumerWidget {
  final CastDisplay display;

  const CastDisplayTile({super.key, required this.display});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CastDisplaysNotifier notifier = ref.read(CastProviders.displays.notifier);

    bool active = display.active;

    return ListTile(
      onTap: () => active ? notifier.stop(display.id) : notifier.start(display.id),
      leading: Icon(active ? Icons.cast_connected : Icons.cast),
      title: Text(display.name),
      subtitle: Text("${display.width}x${display.height}"),
      selected: active,
      trailing: active ? Icon(Icons.check) : null,
    );
  }
}
