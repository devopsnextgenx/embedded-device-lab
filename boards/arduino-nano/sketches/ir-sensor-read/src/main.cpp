// IR Sensor Read - Arduino Nano
// Simple analog sensor reading sketch demonstrating ADC functionality
// See ../pin-layout.md for ADC pin assignments and ranges

#include <Arduino.h>
#include "sensor_config.h"
#include "version.h"

const unsigned long METADATA_INTERVAL_MS = 10000;
unsigned long lastMetadataMs = 0;

void printSketchMetadata() {
  Serial.print("Sketch: ");
  Serial.println(SKETCH_NAME);
  Serial.print("Version: ");
  Serial.println(SKETCH_VERSION);
  Serial.print("Author: ");
  Serial.println(SKETCH_AUTHOR);
  Serial.print("Date: ");
  Serial.println(SKETCH_DATE);
}

void setup() {
  Serial.begin(9600);
  delay(1000); // Allow serial monitor to connect

  printSketchMetadata();
  lastMetadataMs = millis();
  
  pinMode(SENSOR_PIN, INPUT);

  Serial.println("Sensor Read initialized on Arduino Nano");
  Serial.print("Sensor Pin: ");
  Serial.println(SENSOR_PIN);
  Serial.print("Threshold ADC: ");
  Serial.println(OBSTACLE_THRESHOLD_ADC);
}

void loop() {
  if (millis() - lastMetadataMs >= METADATA_INTERVAL_MS) {
    printSketchMetadata();
    lastMetadataMs = millis();
  }

  int rawValue = analogRead(SENSOR_PIN);
  float voltage = rawValue * (5.0 / 1023.0); // Convert to voltage (0-5V)
  bool obstacleActive = rawValue >= OBSTACLE_THRESHOLD_ADC;
  
  Serial.print("Raw ADC: ");
  Serial.print(rawValue);
  Serial.print(" | Voltage: ");
  Serial.print(voltage);
  Serial.println(" V");

  Serial.print("Obstacle: ");
  Serial.println(obstacleActive ? "ACTIVE" : "LOW");
  
  delay(SENSOR_INTERVAL);
}
