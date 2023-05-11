import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class DisplayTH extends StatefulWidget {
  const DisplayTH({super.key, required this.value, required this.is_temp});
  final String value;
  final bool is_temp;

  @override
  State<DisplayTH> createState() => _DisplayTHState();
}

class _DisplayTHState extends State<DisplayTH> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = IntTween(begin: 0, end: int.parse(widget.value)).animate(_controller);
    _controller.forward();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DisplayTH oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != "0") {
      _animation = IntTween(
        begin: 0, end: int.parse(widget.value),
      ).animate(_controller);

      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 125,
      height: 125,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: widget.is_temp? const Color.fromARGB(129, 244, 67, 54): const Color.fromARGB(134, 33, 149, 243),
          border: Border.all(
            width: 1, 
            color: widget.is_temp? Colors.red.shade800: Colors.blue.shade800
          ),
          borderRadius: BorderRadius.circular(150)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.is_temp? const Icon(
                Icons.thermostat, 
                color: Colors.red
              )
              :const Icon(
                Icons.water_drop,
                color: Colors.blue
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child){
                  return widget.is_temp? Text("${_animation.value}°C"): Text("${_animation.value}%");
                }
              )
            ],
          ),
          widget.is_temp? const Text("Temperature"): const Text("Humidity")
        ],
      ),
    );
  }
}
