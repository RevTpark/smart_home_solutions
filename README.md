# Smart Home IOE Project
<div align="center">
  <img width="50%" src="https://user-images.githubusercontent.com/78678620/232232346-3f078a92-f522-4248-b83f-f16c2c4feaf0.jpg"></img>
</div>

## [Working Demo of the Project](https://youtu.be/2ngJKGps6E4)
The Smart Home Solutions project involves using sensors and controllers to create an automated system for a home. The system uses an ultrasonic sensor to detect motion in a room and turn on LED lights with their intensity based on the LDR sensor reading. It also has a DHT sensor that reads the temperature of the room and turns on a fan with its speed determined by the temperature reading. The system sends an email and WhatsApp message to the user when motion is detected for the first time, greeting the user and providing the current temperature and humidity reading of the room. Additionally, the system now has an app that allows the user to monitor the current temperature and humidity readings and control the lights remotely.

## Features
- **Motion Detection**: The project uses an ultrasonic sensor to detect motion in a room.

- **LED Intensity**: The intensity of the LED is controlled based on the reading from an LDR sensor.

- **Fan Control**: The project also controls a fan based on temperature readings from a DHT sensor.

- **Email and Whatsapp Notifications**: When motion is detected for the first time, the project sends an email and WhatsApp message to the user, greeting them and giving them the temperature and humidity readings of the room.

- **Mobile App**: The project now has its own mobile app that allows users to see the current temperature and humidity and control the lights via the app.

## Hardware
- Arduino UNO
- NodeMCU with ESP8266 Wifi Module
- Relay SPDT
- Temperature Sensor(DHT)
- Ultrasonic Sensor
- Photoresistor
- LED
- 12V CPU Fan
## Software
- Arduino IDE
- Python
- Flutter
