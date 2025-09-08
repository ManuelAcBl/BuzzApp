import 'package:buzz_app/view/widgets/icons/custom_icons_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell shell;

  const MainScreen({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: CustomBottomNavigationBar(
        shell: shell,
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final StatefulNavigationShell shell;

  const CustomBottomNavigationBar({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: shell.currentIndex,
      onDestinationSelected: shell.goBranch,
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: "Inicio",
        ),
        NavigationDestination(
          icon: Icon(Icons.people_alt_outlined),
          selectedIcon: Icon(Icons.people_alt),
          label: "Jugadores",
        ),
        NavigationDestination(
          icon: Icon(CustomIcons.buzz_controller),
          selectedIcon: Icon(CustomIcons.buzz_controller),
          label: "Mandos",
        ),
        NavigationDestination(
          icon: Icon(Icons.cast_outlined),
          selectedIcon: Icon(Icons.cast),
          label: "Pantallas",
        ),
      ],
    );
  }
}
