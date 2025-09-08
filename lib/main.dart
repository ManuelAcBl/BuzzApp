import 'dart:async';
import 'dart:convert';

import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_providers.dart';
import 'package:buzz_app/controller/providers/controllers/cast/cast_providers.dart';
import 'package:buzz_app/routes.dart';
import 'package:buzz_app/view/cast/cast_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(ProviderScope(child: const App()));

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(BuzzerProviders.players, (_, __) {});
    ref.listen(CastProviders.displays, (_, __) {});

    return MaterialApp.router(
      routerConfig: Routes.router,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.itimTextTheme(),
      ),
    );
  }
}

void castMain() => runApp(ProviderScope(child: const CastApp()));

class CastApp extends StatefulWidget {
  const CastApp({super.key});

  @override
  State<CastApp> createState() => _CastAppState();
}

class CastData {
  static final EventChannel _events = EventChannel('cast_events');

  static StreamSubscription listen(String id, Function(dynamic) onData) {
    return _events.receiveBroadcastStream().listen((data) {
      Map<String, dynamic> json = jsonDecode(data);

      print(1);

      MapEntry<String, dynamic> element = json.entries.first;

      if (element.key != "data") return;

      print(2);

      element = element.value.entries.first;

      if (element.key != id) return;

      print(3);

      onData(element.value);
    });
  }
}

class _CastAppState extends State<CastApp> {
  //final EventChannel _events = EventChannel('cast_events');
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = CastRoutes.router();

    CastData.listen("route", (data) {
      String? path = data as String?;

      print("PATH ${_router.state.path}");

      if (path == null || path == "") {
        if (_router.state.path != "/waiting") context.push("/waiting");
        return;
      }

      CastRoutes.shell.currentState?.goBranch(CastRoutes.branches.indexWhere((branch) => branch.initialLocation == path));

      _router.pop();
      _router.pop();
      _router.pop();
    });

    // _events.receiveBroadcastStream().listen((data) {
    //   Map<String, dynamic> json = jsonDecode(data);
    //
    //   MapEntry<String, dynamic> element = json.entries.first;
    //
    //   print(data);
    //   main:
    //   switch (element.key) {
    //     case "data":
    //       element = element.value.entries.first;
    //       switch (element.key) {
    //         case "route":
    //           StatefulNavigationShellState? shell = CastRoutes.shell.currentState;
    //
    //           shell?.goBranch(CastRoutes.branches.indexWhere((branch) => branch.initialLocation == element.value));
    //           break main;
    //
    //         case "hide":
    //           bool hide = element.value;
    //
    //           if (hide) {
    //             _router.push("/waiting");
    //             break main;
    //           }
    //
    //           _router.pop();
    //           break main;
    //       }
    //   }
    //
    //   if (element.key == "data") {
    //     if (element.value["route"] == "route") {
    //       _router.go(element.value.value);
    //     }
    //   }
    // });

    Future.delayed(Duration(seconds: 1), () => _router.push("/waiting"));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'Buzz! App Cast Screen',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.itimTextTheme(),
      ),
    );
  }
}
