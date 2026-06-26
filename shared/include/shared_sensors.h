// Shared Sensor Utilities
// Common sensor interface and helper functions

#ifndef SHARED_SENSORS_H
#define SHARED_SENSORS_H

#include <Arduino.h>

/**
 * Simple analog sensor reading with averaging
 * @param pin ADC pin to read from
 * @param samples Number of samples to average
 * @return Averaged raw ADC value
 */
uint16_t readAnalogAverage(uint8_t pin, uint8_t samples = 10) {
  uint32_t sum = 0;
  for (uint8_t i = 0; i < samples; i++) {
    sum += analogRead(pin);
    delayMicroseconds(100);
  }
  return sum / samples;
}

/**
 * Convert 10-bit ADC value to voltage (0-5V range)
 * @param adcValue Raw ADC reading (0-1023)
 * @return Voltage in volts (0.0-5.0)
 */
float adcToVoltage(uint16_t adcValue) {
  return (adcValue * 5.0) / 1023.0;
}

/**
 * Convert 12-bit ADC value to voltage (0-3.3V range, ESP32)
 * @param adcValue Raw ADC reading (0-4095)
 * @return Voltage in volts (0.0-3.3)
 */
float adcToVoltage_ESP32(uint16_t adcValue) {
  return (adcValue * 3.3) / 4095.0;
}

#endif // SHARED_SENSORS_H
