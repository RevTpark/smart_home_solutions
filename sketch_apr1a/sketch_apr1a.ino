#include <dht11.h>

#define LED_PIN 11
#define LDR_PIN 13
#define DHT11_PIN 7
#define REL_PIN 12

dht11 DHT11;
const int SONAR_MAX_LIMIT = 688;
const int trigPin = 9;
const int echoPin = 10;
long duration;
int distance;
int ldr_value = 0;
int led_value;


void setup()
{
  pinMode(LED_PIN, OUTPUT);
  pinMode(LDR_PIN, INPUT);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(REL_PIN, OUTPUT);
  Serial.begin(9600);
}

// void loop(){ }
void loop(){
  ldr_value = analogRead(LDR_PIN);
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  
  duration = pulseIn(echoPin, HIGH);
  distance = duration * 0.034 / 2;
  // Serial.println("Distance: "+String(distance));
  if (distance < SONAR_MAX_LIMIT && distance != 0 ){

    // Send Temp and Humidity Values
    int chk = DHT11.read(DHT11_PIN); 
    Serial.println(String(DHT11.temperature) + "," + String(DHT11.humidity));

    if(DHT11.temperature > 25){
      digitalWrite(REL_PIN, LOW);
    }

    // Set LED value
    led_value = (ldr_value * 255) / 1023;
    analogWrite(LED_PIN, led_value);
  }
  else{
    digitalWrite(LED_PIN, LOW);
    digitalWrite(REL_PIN, HIGH);
  }
  delay(1000);
}
