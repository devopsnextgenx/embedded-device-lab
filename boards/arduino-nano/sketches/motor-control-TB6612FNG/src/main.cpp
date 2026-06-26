#include <Arduino.h>
#include "MotorControl.h"
#include "MotorPins.h"
#include "version.h"
#include "shared_version_utils.h"

void setup() {
  Serial.begin(9600);
  delay(100);

  printSketchMetadata();
  Serial.println(F("motor-control-TB6612FNG starting"));

  motorInitialize();
}

void loop() {
  motorRampSpeed(kMotorMinSpeed, kMotorMaxSpeed);
  motorRampSpeed(kMotorMaxSpeed, kMotorMinSpeed);
}
