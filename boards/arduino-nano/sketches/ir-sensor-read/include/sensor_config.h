// Sensor Configuration Header
// Define pins, timing, and constants for sensor_read sketch

#ifndef SENSOR_CONFIG_H
#define SENSOR_CONFIG_H

// Pin Definitions (refer to pin-layout.md for Arduino Nano pin details)
#ifndef SENSOR_PIN
  #define SENSOR_PIN A0  // Analog pin A0 - Change as needed per pin-layout.md
#endif

// Timing Constants
#define SENSOR_INTERVAL 1000  // Milliseconds between readings

// Obstacle detection threshold for analog IR sensors.
// If ADC >= threshold -> ACTIVE, else LOW.
#ifndef OBSTACLE_THRESHOLD_ADC
  #define OBSTACLE_THRESHOLD_ADC 500
#endif

#endif // SENSOR_CONFIG_H
