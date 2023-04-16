#include <ESP8266WiFi.h> 
#include <WebSocketsServer.h>
#include <Wire.h>

int led_status = 0; // 0 is Off and 1 is On

const char *ssid =  "nodemcu";
const char *pass =  "12345";

WebSocketsServer webSocket = WebSocketsServer(81);

void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {
//webscket event method
    String cmd = "";
    String res = "";
    switch(type) {
        case WStype_DISCONNECTED:
            Serial.println("Websocket is disconnected");
            //case when Websocket is disconnected
            break;
        case WStype_CONNECTED:{
            //wcase when websocket is connected
            Serial.println("Websocket is connected");
            Serial.println(webSocket.remoteIP(num).toString());
            webSocket.sendTXT(num, "connected");}
            break;
        case WStype_TEXT:
            cmd = "";
            for(int i = 0; i < length; i++) {
                cmd = cmd + (char) payload[i]; 
            } //merging payload to single string
            Serial.println(cmd);

            if(cmd == "poweron"){ //when command from app is "poweron"
                led_status = 1;
            }else if(cmd == "poweroff"){
                led_status = 0;
            }
            res = cmd+":success";
             webSocket.sendTXT(num, res);
             //send response to mobile, if command is "poweron" then response will be "poweron:success"
             //this response can be used to track down the success of command in mobile app.
            break;
        case WStype_FRAGMENT_TEXT_START:
            break;
        case WStype_FRAGMENT_BIN_START:
            break;
        case WStype_BIN:
            hexdump(payload, length);
            break;
        default:
            break;
    }
}

void setup() {
   Serial.begin(9600);

  // Integration to Arduino in Master Mode
   Wire.begin(D1, D2);

   // Websocket
   Serial.println("Connecting to wifi");
   
   IPAddress apIP(192, 168, 0, 1);   //Static IP for wifi gateway
   WiFi.softAPConfig(apIP, apIP, IPAddress(255, 255, 255, 0)); //set Static IP gateway on NodeMCU
   WiFi.softAP(ssid, pass); //turn on WIFI

   webSocket.begin(); 
   webSocket.onEvent(webSocketEvent); //set Event for websocket
   Serial.println("Websocket is started");

}

void loop() {
   webSocket.loop();

  delay(500);
  if(led_status == 0){
    Wire.beginTransmission(8); 
    Wire.write("F");
    Wire.endTransmission();    
  }
  else{
    Wire.beginTransmission(8); 
    Wire.write("O");
    Wire.endTransmission();    
  }

  Wire.requestFrom(8, 13); 
  while(Wire.available()){
    String temp = Wire.readStringUntil(',');
    String hum = Wire.readStringUntil('.');
    if(temp.toInt() != 0){
      String json = "{'temp':'" + String(temp) + "','humidity':'" + String(hum) + "'}";
      webSocket.broadcastTXT(json);
    }
  }

}
