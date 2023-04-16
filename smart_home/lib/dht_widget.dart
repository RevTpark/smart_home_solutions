import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class DisplayTH extends StatelessWidget {
  const DisplayTH({super.key, required this.value, required this.is_temp});
  final String value;
  final bool is_temp;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 125,
      height: 125,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: is_temp? Color.fromARGB(129, 244, 67, 54): Color.fromARGB(134, 33, 149, 243),
          border: Border.all(
            width: 1, 
            color: is_temp? Colors.red.shade800: Colors.blue.shade800
          ),
          borderRadius: BorderRadius.circular(150)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              is_temp? Icon(
                Icons.thermostat, 
                color: Colors.red
              )
              :Icon(
                Icons.water_drop,
                color: Colors.blue
              ),
              is_temp? Text("$value°C"): Text("$value%"),
            ],
          ),
          is_temp? Text("Temperature"): Text("Humidity")
        ],
      ),
    );
  }
}
