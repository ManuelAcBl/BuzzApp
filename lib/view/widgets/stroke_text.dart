import 'package:flutter/material.dart';

class StrokeText extends StatelessWidget {
  final Stroke stroke;
  final Text text;

  const StrokeText({super.key, required this.stroke, required this.text});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text.data!,
          style: (text.style ?? const TextStyle()).copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = stroke.width
                ..color = stroke.color),
          textAlign: text.textAlign,
          strutStyle: text.strutStyle,
          textDirection: text.textDirection,
          locale: text.locale,
          softWrap: text.softWrap,
          overflow: text.overflow,
          textScaleFactor: text.textScaleFactor,
          textScaler: text.textScaler,
          maxLines: text.maxLines,
          semanticsLabel: text.semanticsLabel,
          textWidthBasis: text.textWidthBasis,
          textHeightBehavior: text.textHeightBehavior,
          selectionColor: text.selectionColor,
        ),
        text
      ],
    );
  }
}

class Stroke {
  final Color color;
  final double width;

  Stroke({required this.color, required this.width});
}

// class StrokeText extends StatefulWidget {
//   const StrokeText(
//       {super.key,
//       this.width,
//       this.height,
//       this.text,
//       this.textSize,
//       this.textColor,
//       this.strokeColor,
//       this.letterSpacing,
//       this.strokeWidth,
//       this.textAlign});
//
//   final double? width;
//   final double? height;
//   final String? text;
//   final double? textSize;
//   final Color? textColor;
//   final Color? strokeColor;
//   final double? letterSpacing;
//   final double? strokeWidth;
//   final TextAlign? textAlign;
//
//   @override
//   State<StrokeText> createState() => _StrokeTextState();
// }
//
// class _StrokeTextState extends State<StrokeText> {
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // Implement the stroke
//         Text(
//           widget.text ?? '',
//           textAlign: widget.textAlign,
//           style: TextStyle(
//             height: widget.height,
//             fontSize: widget.textSize ?? 16,
//             letterSpacing: widget.letterSpacing ?? 0,
//             fontWeight: FontWeight.bold,
//             foreground: Paint()
//               ..style = PaintingStyle.stroke
//               ..strokeWidth = widget.strokeWidth ?? 4
//               ..color = widget.strokeColor ?? Colors.black,
//           ),
//         ),
//         // The text inside
//         Text(
//           widget.text ?? '',
//           textAlign: widget.textAlign,
//           style: TextStyle(
//             height: widget.height,
//             fontSize: widget.textSize ?? 16,
//             letterSpacing: widget.letterSpacing ?? 0,
//             fontWeight: FontWeight.bold,
//             color: widget.textColor ?? Colors.white,
//           ),
//         ),
//       ],
//     );
//   }
// }
