import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    ledstatus = false; 
    connected = false; 
    Future.delayed(Duration.zero, () async{
      channelConnect();
    });

    super.initState();
  }

  void channelConnect() {
    try{
      channel = IOWebSocketChannel.connect("ws://192.168.0.1:81");
      channel.stream.listen((message) {
        setState(() {
          if(message == "connected"){
            connected = true;
          }
          else if(message.substring(0, 6) == "{'temp"){
            message = message.replaceAll(RegExp("'"), '"'); 
            Map<String, dynamic> jsondata = json.decode(message);
            temperature = jsondata['temp'];
            humidity = jsondata['humidity'];
          }
          else if(message == "poweron:success"){
            ledstatus = true;
          }
          else if(message == "poweroff:success"){
            ledstatus = false;
          }
        });
      },
      onDone: (){
        print("Web Socket is disconnected");
        setState(() {
          connected = false;
        });
      },
      onError: (error){
        print(error.toString());
      }
      );
    }
    catch(_){
      print("Error connecting websocket");
    }
  }

  Future<void> sendCmd(String cmd) async{
    if(connected==true){
      if(ledstatus == false && cmd !="poweron" && cmd != "poweroff"){
        print("Send a valid Command");
      }
      else{
        channel.sink.add(cmd);
      }
    }
    else{
      channelConnect();
      print("Websocket is not connected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Smart Home"),
        backgroundColor: Color.fromRGBO(166, 137, 225, 1),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
                child: connected?
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.green.shade700),
                    borderRadius: BorderRadius.circular(15),
                    color: Color.fromARGB(132, 102, 187, 106),
                    
                  ),
                  child: Text("Connected to your Smart Home"),
                )
                :Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.red.shade700),
                    borderRadius: BorderRadius.circular(15),
                    color: Color.fromARGB(113, 239, 83, 80),
                  ),
                  child: Row(
                    children: [
                      Text("Disconnected from Smart Home"),
                      Container(
                        margin: EdgeInsets.only(left: 5),
                        padding: EdgeInsets.only(left: 5),
                        decoration: BoxDecoration(
                          border: Border(left: BorderSide(color: Colors.red.shade700, width: 2))
                        ),
                        child: GestureDetector(
                          onTap: (){
                            channelConnect();
                          },
                          child: Text(
                            "Connect",
                            style: TextStyle(color: Colors.blue.shade500),
                            )
                        ),
                      )
                    ],
                  )
                )
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(width: 1, color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(15)
              ),
              child: Column(
                children: [
                  Text(
                    "Current weather in Navi Mumbai",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DisplayTH(value: temperature, is_temp: true,),
                      DisplayTH(value: humidity, is_temp: false,)
                    ],
                  )
                ],
              )
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 170,
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Color.fromARGB(224, 253, 216, 53)),
                borderRadius: BorderRadius.circular(15)
              ),
              child: Column(
                children: [
                  Text(
                    "Light Switch",
                    style: TextStyle(fontSize: 20),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    margin: EdgeInsets.only(top:30),
                    child: TextButton(
                      child: ledstatus?
                      Icon(
                        CupertinoIcons.lightbulb_fill,
                        color: Colors.yellow,
                        size: 75,
                      )
                      :Icon(
                        CupertinoIcons.lightbulb,
                        color: Colors.grey,
                        size: 75
                      ),
                      onPressed: (){
                        if(ledstatus){
                          sendCmd("poweroff");
                          setState(() {
                            ledstatus = false;
                          });
                        }
                        else{
                          sendCmd("poweron");
                          setState(() {
                            ledstatus = true;                      
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}