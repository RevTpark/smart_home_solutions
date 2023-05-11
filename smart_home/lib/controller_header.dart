import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class SwitchHeader extends StatelessWidget {
  const SwitchHeader({super.key, required this.width, required this.connected, this.child, required this.name, required this.borderColor, required this.boxShadowColor});
  final double width;
  final bool connected;
  final child;
  final String name;
  final Color borderColor;
  final Color boxShadowColor;


  @override
  Widget build(BuildContext context) {
    return Container(
        width: width * 0.43,
        height: 200,
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            border: Border.all(
                width: 1, color: borderColor),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: boxShadowColor,
                  offset: Offset.fromDirection(20, 4))
            ],
            color: Colors.white),
        child: Column(children: [
          Text(
            "$name ${connected ? '' : '\n(Disabled)'}",
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.only(top: 30),
              child: child)
        ]));
  }
}
