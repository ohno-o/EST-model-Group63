//packages to allow communication with sensors over one wire
#include<OneWire.h>
#include<DallasTemperature.h>

// Pin connected to the DS18B20 data line

#define SensorTop_pin 2
#define SensorBottom_pin 3

OneWire oneWireTop(SensorTop_pin); 
DallasTemperature sensorTop(&oneWireTop) ;

OneWire oneWireBottom(SensorBottom_pin); 
DallasTemperature sensorBottom(&oneWireBottom) ;


DeviceAddress sensorAddresses[4];
unsigned long lastReadTime = 0;
int interval = 1000; // 1/1000 of a second
int timeIndex = 0;

void setup() {
  Serial.begin(9600);
  sensorTop.begin();
  sensorBottom.begin();
}

void loop() {
  unsigned long now = millis () ;
  if(now - lastReadTime >= interval) { ;

    sensorTop.requestTemperatures();
    sensorBottom.requestTemperatures();
    
    Serial.print("t=") ;
    Serial.print(timeIndex) ;
    Serial.print (",") ;
    Serial.print(sensorTop.getTempCByIndex(0));
    Serial.print (",") ;
    Serial.print(sensorBottom.getTempCByIndex(0));
    Serial.println();

    timeIndex += interval/1000;
    lastReadTime = now ;
  }
}