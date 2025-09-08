import 'package:buzz_app/view/screens/cast_displays/cast_displays_screen.dart';
import 'package:buzz_app/view/screens/controller/controller_screen.dart';
import 'package:buzz_app/view/screens/home/buzzer/buzzer_screen.dart';
import 'package:buzz_app/view/screens/home/home_screen.dart';
import 'package:buzz_app/view/screens/home/numbers/numbers_screen.dart';
import 'package:buzz_app/view/screens/home/response/response_screen.dart';
import 'package:buzz_app/view/screens/main_screen.dart';
import 'package:buzz_app/view/screens/teams/team_edit_screen.dart';
import 'package:buzz_app/view/screens/teams/teams_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class Routes extends NavigatorObserver {
  final MethodChannel _methods = MethodChannel('cast_methods');

  static GoRouter router = GoRouter(
    observers: [
      Routes(),
    ],
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainScreen(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/home",
                builder: (context, state) => HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/teams",
                builder: (context, state) => TeamsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/controller",
                builder: (context, state) => ControllerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/cast_displays",
                builder: (context, state) => CastDisplaysScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: "/team/edit",
        builder: (context, state) => TeamEditScreen(index: state.extra as int),
      ),
      GoRoute(
        path: "/team/edit/color",
        builder: (context, state) => ColorPickerScreen(color: state.extra as Color),
      ),
      GoRoute(
        path: "/game/responses",
        builder: (context, state) => ResponseScreen(responses: ["A", "B", "C", "D"]),
      ),
      GoRoute(
        path: "/game/numbers",
        builder: (context, state) => NumbersScreen(),
      ),
      GoRoute(
        path: "/game/buzzer",
        builder: (context, state) => BuzzerScreen(),
      ),
    ],
  );

  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    String? path = topRoute.settings.name;

    if (path == null || !path.startsWith("/game/")) {
      _methods.invokeMethod("data", {"route": ""});
      return;
    }

    _methods.invokeMethod("data", {"route": path});
  }
}
