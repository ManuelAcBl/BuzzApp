import 'package:buzz_app/view/widgets/appbar/custom_app_bar_title.dart';
import 'package:flutter/material.dart';

class NumbersScreen extends StatelessWidget {
  const NumbersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomAppBarTitle(title: "Cifras"),
      ),
      body: const Center(
        child: Text("Numbers"),
      ),
    );
  }
}
