// Sensor Read - Arduino Nano
// Simple analog sensor reading sketch demonstrating ADC functionality
// See ../pin-layout.md for ADC pin assignments and ranges

#include <Arduino.h>
#include "sensor_config.h"
#include "version.h"

void setup() {
  Serial.begin(9600);
  delay(1000); // Allow serial monitor to connect

  Serial.print("Sketch: ");
  Serial.println(SKETCH_NAME);
  Serial.print("Version: ");
  Serial.println(SKETCH_VERSION);
  Serial.print("Author: ");
  Serial.println(SKETCH_AUTHOR);
  Serial.print("Date: ");
  Serial.println(SKETCH_DATE);
  
  pinMode(SENSOR_PIN, INPUT);
  Serial.println("Sensor Read initialized on Arduino Nano");
  Serial.print("Sensor Pin: ");
  Serial.println(SENSOR_PIN);
}

void loop() {
  int rawValue = analogRead(SENSOR_PIN);
  float voltage = rawValue * (5.0 / 1023.0); // Convert to voltage (0-5V)
  
  Serial.print("Raw ADC: ");
  Serial.print(rawValue);
  Serial.print(" | Voltage: ");
  Serial.print(voltage);
  Serial.println(" V");
  
  delay(SENSOR_INTERVAL);
}
