import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:smart_home/connection_header.dart';
import 'package:smart_home/controller_header.dart';
import 'package:smart_home/dht_widget.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketConnectPage extends StatefulWidget {
  const WebSocketConnectPage({super.key});

  @override
  State<WebSocketConnectPage> createState() => _WebSocketConnectPageState();
}

class _WebSocketConnectPageState extends State<WebSocketConnectPage> {
  late bool ledstatus;
  late IOWebSocketChannel channel;
  late bool connected;
  String temperature = "0";
  String humidity = "0";
  String? currentAddress;
  Position? currentPosition;
  bool isLoadingWS = false;

  @override
  void initState() {
    ledstatus = false;
    connected = false;

    getCurrentPosition();
    Future.delayed(Duration.zero, () async {
      channelConnect();
    });

    super.initState();
  }

  void channelConnect() {
    try {
      channel = IOWebSocketChannel.connect("ws://192.168.0.1:81");
      channel.stream.listen((message) {
        setState(() {
          if (message == "connected") {
            isLoadingWS = false;
            connected = true;
          } else if (message.substring(0, 6) == "{'temp") {
            message = message.replaceAll(RegExp("'"), '"');
            Map<String, dynamic> jsondata = json.decode(message);
            temperature = jsondata['temp'];
            humidity = jsondata['humidity'];
          } else if (message == "poweron:success") {
            ledstatus = true;
          } else if (message == "poweroff:success") {
            ledstatus = false;
          }
        });
      }, onDone: () {
        print("Web Socket is disconnected");
        setState(() {
          connected = false;
        });
      }, onError: (error) {
        print(error.toString());
      });
    } catch (_) {
      setState(() {
        isLoadingWS = false;
      });
      print("Error connecting websocket");
    }
  }

  Future<void> sendCmd(String cmd) async {
    if (connected == true) {
      if (ledstatus == false && cmd != "poweron" && cmd != "poweroff") {
        print("Send a valid Command");
      } else {
        channel.sink.add(cmd);
      }
    } else {
      channelConnect();
      print("Websocket is not connected");
    }
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => currentPosition = position);
      getAddressFromLatLng(currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            currentPosition!.latitude, currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        currentAddress = '${place.subLocality},${place.locality}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('a').format(now);

    return Scaffold(
      appBar: AppBar(
        title: Text("Smart Home"),
        backgroundColor: Color.fromRGBO(166, 137, 225, 1),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 5, top: 5),
                child: Row(
                  children: [
                    Icon(
                      formattedDate == "AM" ? Icons.sunny : Icons.nightlight,
                      size: 25,
                    ),
                    Text(
                      formattedDate == "AM"
                          ? "Good Morning User,"
                          : "Good Evening User,",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ],
                ),
              ),
              Container(
                  child: connected
                      ? ConnectionHeaader(
                          width: width,
                          borderColor: Colors.green.shade700,
                          color: const Color.fromARGB(132, 102, 187, 106),
                          child: const Text("Connected to your Smart Home",
                              textAlign: TextAlign.center),
                        )
                      : ConnectionHeaader(
                          width: width,
                          borderColor: Colors.red.shade700,
                          color: const Color.fromARGB(113, 239, 83, 80),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Text("Disconnected from Smart Home"),
                              Container(
                                padding: const EdgeInsets.only(left: 5),
                                decoration: BoxDecoration(
                                    border: Border(
                                        left: BorderSide(
                                            color: Colors.red.shade700,
                                            width: 2))),
                                child: GestureDetector(
                                    onTap: isLoadingWS
                                        ? () {}
                                        : () {
                                            channelConnect();
                                            setState(() {
                                              isLoadingWS = true;
                                            });
                                          },
                                    child: Text(
                                      "Connect",
                                      style: TextStyle(
                                          color: Colors.blue.shade500),
                                    )),
                              )
                            ],
                          ))),
              Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(width: 1, color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    children: [
                      Text(
                        currentAddress != null
                            ? "Current weather in $currentAddress"
                            : "Fetching Location...",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          DisplayTH(
                            value: temperature,
                            is_temp: true,
                          ),
                          DisplayTH(
                            value: humidity,
                            is_temp: false,
                          )
                        ],
                      )
                    ],
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SwitchHeader(
                    width: width,
                    connected: connected,
                    borderColor: const Color.fromARGB(224, 253, 216, 53),
                    boxShadowColor: const Color.fromARGB(94, 253, 216, 53),
                    name: "Light Switch",
                    child: TextButton(
                      child: Icon(
                        ledstatus
                            ? CupertinoIcons.lightbulb_fill
                            : CupertinoIcons.lightbulb,
                        color: ledstatus ? Colors.yellow : Colors.grey,
                        size: 75,
                      ),
                      onPressed: () {
                        if (ledstatus) {
                          sendCmd("poweroff");
                          setState(() {
                            ledstatus = false;
                          });
                        } else {
                          sendCmd("poweron");
                          setState(() {
                            ledstatus = true;
                          });
                        }
                      },
                    ),
                  ),
                  SwitchHeader(
                    width: width,
                    connected: connected,
                    borderColor: const Color.fromARGB(224, 253, 216, 53),
                    boxShadowColor: const Color.fromARGB(94, 253, 216, 53),
                    name: "Fan Switch",
                    child: TextButton(
                      child: Icon(
                        ledstatus
                            ? CupertinoIcons.sun_max
                            : CupertinoIcons.sun_min,
                        color: ledstatus ? Colors.orange : Colors.grey,
                        size: 75,
                      ),
                      onPressed: () {
                        if (ledstatus) {
                          sendCmd("poweroff");
                          setState(() {
                            ledstatus = false;
                          });
                        } else {
                          sendCmd("poweron");
                          setState(() {
                            ledstatus = true;
                          });
                        }
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
