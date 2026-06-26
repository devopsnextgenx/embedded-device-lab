# Shared Assets Documentation

This directory contains **reusable code and utilities shared across all boards and sketches** in the embedded-device-lab monorepo.

## Directory Structure

```
shared/
├── include/              # Shared header files (.h)
│   ├── shared_utils.h    # Common Arduino utilities
│   └── shared_sensors.h  # Sensor abstraction & helpers
└── src/                  # Shared implementation files (.cpp)
    └── (implementations can go here)
```

---

## Available Shared Headers

### `shared_utils.h`

General-purpose Arduino utilities for common tasks.

**Functions:**

- `bool isValidPin(uint8_t pin)` - Validate pin number for the platform
- `void initSerial(unsigned long baudrate)` - Initialize serial with timeout
- `void heartbeat(uint8_t pin, uint16_t interval)` - Blink LED for diagnostics

**Usage:**
```cpp
#include "shared_utils.h"

void setup() {
  initSerial(115200);
  pinMode(LED_PIN, OUTPUT);
  if (isValidPin(SENSOR_PIN)) {
    pinMode(SENSOR_PIN, INPUT);
  }
}

void loop() {
  heartbeat(LED_PIN, 500);  // Blink every 500ms
}
```

---

### `shared_sensors.h`

Sensor reading and conversion utilities.

**Functions:**

- `uint16_t readAnalogAverage(uint8_t pin, uint8_t samples)` - Read with averaging
- `float adcToVoltage(uint16_t adcValue)` - Convert 10-bit ADC to voltage (0-5V)
- `float adcToVoltage_ESP32(uint16_t adcValue)` - Convert 12-bit ADC to voltage (0-3.3V)

**Usage:**
```cpp
#include "shared_sensors.h"

void loop() {
  // Read sensor with 10 samples averaged
  uint16_t raw = readAnalogAverage(A0, 10);
  
  // Convert to voltage
  float voltage = adcToVoltage(raw);  // For Arduino (10-bit)
  // OR
  float voltage = adcToVoltage_ESP32(raw);  // For ESP32 (12-bit)
  
  Serial.println(voltage);
}
```

---

## Including Shared Headers in Your Sketch

### Method 1: Reference via Build Flags (Recommended)

The global `platformio.ini` already includes:
```ini
build_flags = -I${PROJECT_DIR}/../../shared/include
```

So in your sketch, simply:
```cpp
#include "shared_utils.h"
#include "shared_sensors.h"
```

### Method 2: Explicit Path (Less Common)

If not already configured, add to your sketch's `platformio.ini`:
```ini
build_flags = -I${PROJECT_DIR}/../../shared/include
```

---

## Adding New Shared Code

### Step 1: Create Header File

Create a new file in `shared/include/my_driver.h`:

```cpp
#ifndef MY_DRIVER_H
#define MY_DRIVER_H

#include <Arduino.h>

class MyDriver {
public:
  MyDriver(uint8_t pin);
  void init();
  uint16_t read();
  
private:
  uint8_t _pin;
};

#endif
```

### Step 2: (Optional) Create Implementation

If needed, create `shared/src/my_driver.cpp`:

```cpp
#include "my_driver.h"

MyDriver::MyDriver(uint8_t pin) : _pin(pin) {}

void MyDriver::init() {
  pinMode(_pin, INPUT);
}

uint16_t MyDriver::read() {
  return analogRead(_pin);
}
```

### Step 3: Add to Your Sketch

```cpp
#include "my_driver.h"

MyDriver sensor(A0);

void setup() {
  sensor.init();
}

void loop() {
  uint16_t val = sensor.read();
  Serial.println(val);
}
```

### Step 4: Update platformio.ini if Needed

If using `.cpp` implementations:
```ini
[env:esp32_devkit]
lib_extra_dirs = ${PROJECT_DIR}/../../shared/src
```

---

## Best Practices

### 1. Keep Shared Code Generic
Shared utilities should work across **all boards** (Arduino, ESP32, Teensy, etc.)

**Good:**
```cpp
// Works on any Arduino-compatible platform
uint16_t readAnalogAverage(uint8_t pin, uint8_t samples) {
  uint32_t sum = 0;
  for (uint8_t i = 0; i < samples; i++) {
    sum += analogRead(pin);
  }
  return sum / samples;
}
```

**Avoid:**
```cpp
// ESP32-specific, won't work on Arduino Nano
uint16_t readADC(uint8_t pin) {
  return adc1_get_raw(ADC1_CHANNEL_0);  // ESP32-specific API
}
```

### 2. Use Conditional Compilation for Platform Differences

```cpp
#ifdef BOARD_ESP32_DEVKIT
  #define VOLTAGE_REF 3.3
  #define ADC_RESOLUTION 4095
#elif defined(BOARD_ARDUINO_NANO)
  #define VOLTAGE_REF 5.0
  #define ADC_RESOLUTION 1023
#else
  #define VOLTAGE_REF 5.0
  #define ADC_RESOLUTION 1023
#endif

float adcToVoltage(uint16_t raw) {
  return (raw * VOLTAGE_REF) / ADC_RESOLUTION;
}
```

### 3. Document Clearly

Every shared header should include:
- Purpose and use cases
- Function signatures with descriptions
- Example usage
- Platform compatibility notes

```cpp
/**
 * Read analog sensor with averaging to reduce noise
 * 
 * @param pin Analog pin number (A0-A7 for Nano, GPIO 32-39 for ESP32)
 * @param samples Number of readings to average (default 10)
 * @return Averaged 10-bit (Nano) or 12-bit (ESP32) ADC value
 * 
 * Compatible with: Arduino Nano, ESP32, other Arduino-compatible boards
 */
uint16_t readAnalogAverage(uint8_t pin, uint8_t samples = 10);
```

### 4. Avoid Board-Specific Dependencies

Shared code should **NOT** require:
- Board-specific libraries (e.g., `WiFi.h` for ESP32 only)
- Platform-specific APIs (e.g., `ESP.getChipId()`)
- Assumptions about pin counts or capabilities

**Exception:** Conditional includes for platform-specific optimizations (documented clearly)

### 5. Keep It Modular

Shared code should be:
- **Small:** Single responsibility
- **Reusable:** Works in multiple sketches
- **Testable:** Can be tested independently
- **Documented:** Clear usage examples

---

## Examples in Repository

The repository includes these shared utilities:

- `shared/include/shared_utils.h` - General Arduino utilities
- `shared/include/shared_sensors.h` - ADC and sensor helpers

Study these examples before adding new shared code.

---

## Referencing Shared Code

All sketches in the repository use:
```cpp
#include <Arduino.h>
#include "shared_utils.h"
#include "shared_sensors.h"
```

You can extend this list by:
1. Adding your new header to `shared/include/`
2. Including it in your sketch
3. Ensuring it works across platforms

---

## Related Documentation

- [Global PlatformIO Config](../platformio.ini)
- [Sketches SKILL Guide](.github/skills/sketches/SKILL.md)
- [Example Sketches](boards/esp32_devkit/sketches/blink_test/)

---

## Questions?

Refer to the example sketches in the repository for real usage patterns:
- [blink_test](boards/esp32_devkit/sketches/blink_test/src/main.cpp)
- [sensor_read](boards/arduino_nano/sketches/sensor_read/src/main.cpp)
