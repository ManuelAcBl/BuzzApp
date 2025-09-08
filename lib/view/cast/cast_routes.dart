import 'package:buzz_app/view/cast/games/numbers/numbers_cast_screen.dart';
import 'package:buzz_app/view/cast/games/response/response_cast_screen.dart';
import 'package:buzz_app/view/cast/main_cast_screen.dart';
import 'package:buzz_app/view/cast/waiting_cast_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_transitions/go_transitions.dart';

abstract class CastRoutes {
  static GlobalKey<StatefulNavigationShellState> shell = GlobalKey();
  static List<StatefulShellBranch> branches = [];

  static GoRouter router() => GoRouter(
        observers: [
          Observer(),
        ],
        initialLocation: '/starting',
        routes: [
          StatefulShellRoute.indexedStack(
            key: shell,
            builder: (context, state, shell) => MainCastScreen(shell: shell),
            branches: branches = [
              StatefulShellBranch(
                initialLocation: "/starting",
                routes: [
                  GoRoute(
                    path: "/starting",
                    builder: (context, state) => ColoredBox(color: Colors.tealAccent),
                  ),
                ],
              ),
              StatefulShellBranch(
                initialLocation: "/game/responses",
                routes: [
                  GoRoute(
                    path: "/game/responses",
                    builder: (context, state) => ResponseCastScreen(),
                  ),
                  GoRoute(
                    path: "/game/responses/winner",
                    builder: (context, state) => ResponseCastScreen(),
                  ),
                ],
              ),
              StatefulShellBranch(
                initialLocation: "/game/numbers",
                routes: [
                  GoRoute(
                    path: "/game/numbers",
                    builder: (context, state) => NumbersCastScreen(),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: "/waiting",
            builder: (context, state) => WaitingCastScreen(),
            pageBuilder: GoTransitions.slide.toBottom.call,
          ),
        ],
      );
}

class Observer extends NavigatorObserver {
  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    String? path = topRoute.settings.name;

    print("PATH: $path");
  }
}
