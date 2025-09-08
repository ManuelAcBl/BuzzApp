import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_controller_notifier.dart';
import 'package:buzz_app/controller/providers/controllers/buzzer/buzzer_providers.dart';
import 'package:flutter/material.dart';

class ControllerPainter extends CustomPainter {
  final Controller controller;

  ControllerPainter({super.repaint, required this.controller});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    canvas.drawRect(Rect.fromPoints(
      Offset.zero,
      Offset(size.width, size.width),
    ), paint..color = Colors.grey);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset.zero,
          Offset(size.width, size.width),
        ),
        Radius.circular(10),
      ),
      paint..color = Color.fromRGBO(25, 25, 25, 1),
    );

    // canvas.drawCircle(
    //   Offset(size.width / 2, size.height / 6),
    //   size.width / 2,
    //   paint..color = Colors.red.withAlpha(controller.red ? 255 : 128),
    // );

    //canvas.translate(0, size.height / 2);
    //ControllerButtonListPainter(controller: controller).paint(canvas, Size(size.width, size.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ControllerButtonListPainter extends CustomPainter {
  final Controller controller;

  ControllerButtonListPainter({super.repaint, required this.controller});

  @override
  void paint(Canvas canvas, Size size) {
    Size buttonSize = Size(size.width / 1.5, size.height / 6);

    ControllerButtonPainter(color: Colors.blue, active: controller.blue).paint(canvas, buttonSize);
    canvas.translate(0, size.height / 9);
    ControllerButtonPainter(color: Colors.deepOrange, active: controller.orange).paint(canvas, buttonSize);
    canvas.translate(0, size.height / 9);
    ControllerButtonPainter(color: Colors.green, active: controller.green).paint(canvas, buttonSize);
    canvas.translate(0, size.height / 9);
    ControllerButtonPainter(color: Colors.yellow, active: controller.yellow).paint(canvas, buttonSize);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ControllerButtonPainter extends CustomPainter {
  final Color color;
  final bool active;

  ControllerButtonPainter({super.repaint, required this.color, required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset.zero,
          Offset(size.width, size.width),
        ),
        Radius.circular(50),
      ),
      Paint()..color = color.withAlpha(active ? 255 : 128),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
