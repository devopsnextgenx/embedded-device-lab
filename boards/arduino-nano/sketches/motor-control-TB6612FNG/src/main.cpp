#include <Arduino.h>
#include "MotorControl.h"
#include "MotorPins.h"
#include "version.h"

static void printSketchMetadata() {
  Serial.print(F("Sketch: "));
  Serial.println(SKETCH_NAME);
  Serial.print(F("Version: "));
  Serial.println(SKETCH_VERSION);
  Serial.print(F("Author: "));
  Serial.println(SKETCH_AUTHOR);
  Serial.print(F("Date: "));
  Serial.println(SKETCH_DATE);
}

void setup() {
  Serial.begin(115200);
  delay(100);

  printSketchMetadata();
  Serial.println(F("motor-control-TB6612FNG starting"));

  motorInitialize();
}

void loop() {
  motorRampSpeed(kMotorMinSpeed, kMotorMaxSpeed);
  motorRampSpeed(kMotorMaxSpeed, kMotorMinSpeed);
}
