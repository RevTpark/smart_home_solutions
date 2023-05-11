import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ConnectionHeaader extends StatelessWidget {
  const ConnectionHeaader({super.key, this.child, required this.width, required this.borderColor, required this.color});
  final child;
  final double width;
  final Color borderColor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(top: 5, bottom: 5),
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: borderColor),
          borderRadius: BorderRadius.circular(15),
          color: color,
        ),
        child: child
    );
  }
}