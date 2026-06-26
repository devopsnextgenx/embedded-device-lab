# SKILL.md: Adding and Configuring a New Sketch

## Overview
This guide provides comprehensive instructions for creating and configuring a new sketch within the embedded-device-lab monorepo. Each sketch represents a specific hardware application or sensor test targeting a particular board. Follow this procedure to maintain modular, well-documented sketches that leverage shared code and inherit PlatformIO settings.

---

## Critical Requirements

**⚠️ MANDATORY: When writing sketches, the developer MUST reference the parent board's `pin-layout.md` and `pin-layout.png` to map hardware pins, sensors, and peripherals correctly.**

This ensures:
- Correct GPIO assignment avoiding pin conflicts
- Proper voltage level compatibility (3.3V vs 5V)
- Awareness of special-function pins (ADC, PWM, I2C, SPI, UART)
- Prevention of hardware damage due to incorrect pin usage

---

**⚠️ MANDATORY: Every sketch MUST have its own `include/version.h`, and `setup()` MUST print sketch name, version, author, and date to Serial before any other output.**

This allows dashboards and serial monitors to identify the running sketch automatically.

**Required output format (must appear at the very start of `setup()` after `Serial.begin()`):**

```cpp
Serial.print("Sketch: ");
Serial.println(SKETCH_NAME);     // defined in include/version.h (or optionally overridden via build flags)
Serial.print("Version: ");
Serial.println(SKETCH_VERSION);  // defined in include/version.h
Serial.print("Author: ");
Serial.println(SKETCH_AUTHOR);   // set to devopsnextgenx@gmail.com in include/version.h
Serial.print("Date: ");
Serial.println(SKETCH_DATE);     // set to YYYY-MM-DD in include/version.h
```

**Required `include/version.h` template (per sketch):**

```cpp
// Sketch metadata for [sketch_name]
#ifndef VERSION_H
#define VERSION_H

#ifndef SKETCH_NAME
  #define SKETCH_NAME "[sketch_name]"
#endif

#ifndef SKETCH_VERSION
  #define SKETCH_VERSION "1.0.0"
#endif

#ifndef SKETCH_AUTHOR
  #define SKETCH_AUTHOR "devopsnextgenx@gmail.com"
#endif

#ifndef SKETCH_DATE
  #define SKETCH_DATE "YYYY-MM-DD"
#endif

#endif // VERSION_H
```

> Keep one `version.h` per sketch so metadata is sketch-local and easy to track.

**Why this matters:**
- Processing dashboards and serial monitors parse `Sketch:` / `Version:` / `Author:` / `Date:` lines to populate status panels
- Makes it immediately clear which firmware is running without checking source code
- Assists debugging when multiple sketches share the same board

---

## Prerequisites

- Board already configured (see [boards/SKILL.md](../boards/SKILL.md))
- Access to the board's `pin-layout.md` documentation
- PlatformIO CLI installed
- Understanding of the target application/sensor requirements

---

## Step 1: Understand the Sketch Directory Structure

### 1.1 Sketch Anatomy

Each sketch follows this structure:

```
boards/[board-name]/sketches/[sketch-name]/          # Directories: kebab-case
├── src/
│   └── main.cpp                    # C/C++ files: snake_case
├── include/
│   ├── version.h                   # Sketch metadata (name, version, author, date)
│   └── [sketch_name]_config.h      # C/C++ header files: snake_case
├── dashboard/                       # (Optional) Processing UI code
│   ├── dashboard.pde               # Processing sketch for visualization
│   └── data/                        # Assets (images, fonts)
├── docs/
│   └── README.md                   # Sketch-specific documentation
├── CHANGELOG.md                    # Sketch-specific change history
├── platformio.ini                  # Sketch-level PlatformIO configuration
└── readme.md                       # Quick reference (mirror of docs/README.md)
```

### 1.2 Sketch Categories

- **Sensor Tests:** Simple single-sensor reading (temperature, humidity, light, etc.)
- **Device Control:** GPIO-based control (LED, relay, buzzer, motor)
- **Communication Tests:** I2C, SPI, CAN bus communication examples
- **Full Projects:** Complex multi-sensor, multi-component applications
- **Dashboard Projects:** Sketches with Processing-based UI for real-time visualization

---

## Step 2: Create Sketch Directory Structure

### 2.1 Create Directories

```bash
BOARD_NAME="[your-board]"  # e.g., esp32-devkit
SKETCH_NAME="[your-sketch]"  # e.g., hello-world

mkdir -p "boards/${BOARD_NAME}/sketches/${SKETCH_NAME}/src"
mkdir -p "boards/${BOARD_NAME}/sketches/${SKETCH_NAME}/include"
mkdir -p "boards/${BOARD_NAME}/sketches/${SKETCH_NAME}/dashboard"
mkdir -p "boards/${BOARD_NAME}/sketches/${SKETCH_NAME}/docs"
```

### 2.2 Verify Structure

```bash
tree boards/${BOARD_NAME}/sketches/${SKETCH_NAME}/
```

---

## Step 3: Consult Board Pin Layout (CRITICAL STEP)

### 3.1 Reference the Board's Pin Documentation

**Before writing any code, review the board's pin-layout files:**

```bash
cat boards/[board-name]/pin-layout.md
# Review: Power pins, GPIO layout, ADC channels, special functions
# Study: pin-layout.png for visual reference
```

### 3.2 Document Your Pin Mapping

Create a quick reference in your sketch's `docs/` or directly in the config header:

**Example for ESP32 DHT sensor:**
```
From pin-layout.md: GPIO23 available, 3.3V rail confirmed
DHT sensor wiring:
  - GND → ESP32 GND
  - VCC → ESP32 3V3
  - DATA → ESP32 GPIO23 (with 10kΩ pull-up to 3V3)
```

---

## Step 4: Create Sketch Header File

### 4.1 Create `include/version.h` (REQUIRED)

This header centralizes sketch identity metadata and must exist for every sketch.

**Template:**

```cpp
// Sketch metadata for [sketch_name]

#ifndef VERSION_H
#define VERSION_H

#ifndef SKETCH_NAME
  #define SKETCH_NAME "[sketch_name]"
#endif

#ifndef SKETCH_VERSION
  #define SKETCH_VERSION "1.0.0"
#endif

#ifndef SKETCH_AUTHOR
  #define SKETCH_AUTHOR "devopsnextgenx@gmail.com"
#endif

#ifndef SKETCH_DATE
  #define SKETCH_DATE "YYYY-MM-DD"
#endif

#endif // VERSION_H
```

### 4.2 Create `include/[sketch_name]_config.h`

This header centralizes all pin definitions and sketch-level configuration.

**Note:** Directories use kebab-case (`sketch-name/`), but C/C++ files use snake_case (`[sketch_name]_config.h`).

**Template:**

```cpp
// [Sketch Name] Configuration Header
// Pin definitions and constants for the [sketch-name] sketch
// Refer to ../pin-layout.md for complete GPIO mapping

#ifndef [SKETCH_NAME_UPPER]_CONFIG_H  // Use underscore in macro (C convention)
#define [SKETCH_NAME_UPPER]_CONFIG_H

// ============================================================================
// PIN DEFINITIONS (Reference board's pin-layout.md)
// ============================================================================

#ifndef GPIO_SENSOR_PIN
  #define GPIO_SENSOR_PIN 23  // GPIO23 - See ../pin-layout.md
#endif

#ifndef GPIO_LED_PIN
  #define GPIO_LED_PIN 2      // GPIO2 - See ../pin-layout.md
#endif

#ifndef GPIO_BUTTON_PIN
  #define GPIO_BUTTON_PIN 15  // GPIO15 - See ../pin-layout.md
#endif

// I2C Pins (if using I2C - consult pin-layout.md for availability)
#ifndef I2C_SDA_PIN
  #define I2C_SDA_PIN 21      // GPIO21 - I2C Data
#endif

#ifndef I2C_SCL_PIN
  #define I2C_SCL_PIN 22      // GPIO22 - I2C Clock
#endif

// ============================================================================
// TIMING & SAMPLING CONFIGURATION
// ============================================================================

#define SENSOR_SAMPLE_INTERVAL 1000    // milliseconds between sensor reads
#define SENSOR_AVERAGES 10             // Number of samples to average
#define SERIAL_BAUD_RATE 115200

// ============================================================================
// SENSOR-SPECIFIC CONFIGURATION
// ============================================================================

#define DHT_SENSOR_TYPE DHT22          // DHT22 (or DHT11)
#define DHT_READ_INTERVAL 2000         // DHT needs 2s between reads

// ============================================================================
// OPTIONAL: FEATURE FLAGS
// ============================================================================

#define ENABLE_SERIAL_DEBUG 1          // 1 to enable detailed serial output
#define ENABLE_EEPROM_LOGGING 0        // 1 to log to EEPROM (if available)

// ============================================================================
// VALIDATION (Optional but recommended)
// ============================================================================

#ifdef BOARD_ESP32_DEVKIT
  #if GPIO_SENSOR_PIN > 39
    #error "GPIO_SENSOR_PIN out of range for ESP32"
  #endif
#elif defined(BOARD_ARDUINO_NANO)
  #if GPIO_SENSOR_PIN > 19
    #error "GPIO_SENSOR_PIN out of range for Arduino Nano"
  #endif
#endif

#endif // [SKETCH_NAME_UPPER]_CONFIG_H
```

**Key Points:**
- Use `#define` for all pin numbers (compile-time constants)
- Add comments referencing the board's `pin-layout.md` location
- Use guard macros (`#ifndef`) to allow runtime overrides
- Include optional feature flags for conditional compilation
- Add validation checks if ranges are known

---

## Step 5: Create Main Sketch Code

### 5.1 Create `src/main.cpp`

**Template:**

```cpp
// [Sketch Name]
// Description: [Brief description of what this sketch does]
// Board: [Target board name]
// See ../pin-layout.md for hardware pin assignments

#include <Arduino.h>
#include "[sketch_name]_config.h"
#include "version.h"

// Optional: Include shared utilities from embedded-device-lab/shared/
#include "shared_utils.h"
#include "shared_sensors.h"

// ============================================================================
// GLOBAL VARIABLES
// ============================================================================

unsigned long lastSampleTime = 0;
uint16_t sensorValue = 0;

// ============================================================================
// SETUP: Initialize hardware and peripherals
// ============================================================================

void setup() {
  // Initialize serial communication
  Serial.begin(SERIAL_BAUD_RATE);
  delay(1000);  // Allow serial monitor to connect

  // MANDATORY: Print sketch identity first (parsed by dashboards/monitors)
  Serial.print("Sketch: ");
  Serial.println(SKETCH_NAME);
  Serial.print("Version: ");
  Serial.println(SKETCH_VERSION);
  Serial.print("Author: ");
  Serial.println(SKETCH_AUTHOR);
  Serial.print("Date: ");
  Serial.println(SKETCH_DATE);
  
  // Print initialization message
  Serial.println("\n=== [Sketch Name] Initialized ===");
  Serial.println("[Board Name]");
  printPinConfiguration();
  
  // Configure GPIO pins
  pinMode(GPIO_LED_PIN, OUTPUT);
  pinMode(GPIO_SENSOR_PIN, INPUT);
  
  // Initialize peripherals (I2C, SPI, sensors, etc.)
  // Example: DHT sensor initialization would go here
  
  Serial.println("Setup complete. Starting loop...\n");
}

// ============================================================================
// LOOP: Main execution loop
// ============================================================================

void loop() {
  unsigned long currentTime = millis();
  
  // Sample at defined interval
  if (currentTime - lastSampleTime >= SENSOR_SAMPLE_INTERVAL) {
    lastSampleTime = currentTime;
    
    // Read sensor
    sensorValue = analogRead(GPIO_SENSOR_PIN);
    
    // Process reading
    float voltage = (sensorValue * 3.3) / 4095.0;  // 12-bit ADC on ESP32
    
    // Output to serial
    Serial.print("Sensor: ");
    Serial.print(sensorValue);
    Serial.print(" | Voltage: ");
    Serial.print(voltage);
    Serial.println(" V");
    
    // Toggle LED as heartbeat
    digitalWrite(GPIO_LED_PIN, !digitalRead(GPIO_LED_PIN));
  }
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * Print pin configuration to serial for verification
 */
void printPinConfiguration() {
  Serial.println("\n--- Pin Configuration ---");
  Serial.print("Sensor Pin: GPIO");
  Serial.println(GPIO_SENSOR_PIN);
  Serial.print("LED Pin: GPIO");
  Serial.println(GPIO_LED_PIN);
  Serial.print("Button Pin: GPIO");
  Serial.println(GPIO_BUTTON_PIN);
  Serial.println("");
}

/**
 * Example: Sensor reading with error handling
 */
uint16_t readSensorSafe() {
  if (!isValidPin(GPIO_SENSOR_PIN)) {
    Serial.println("ERROR: Invalid sensor pin");
    return 0;
  }
  return analogRead(GPIO_SENSOR_PIN);
}
```

**Code Organization:**
1. **Includes:** List all dependencies
2. **Configuration:** Include the sketch config header
3. **Global Variables:** State needed across functions
4. **Setup:** Initialize everything
5. **Loop:** Main execution (keep brief, avoid blocking)
6. **Helper Functions:** Modular, reusable code

---

## Step 6: Create PlatformIO Configuration for Sketch

### 6.1 Create `platformio.ini`

**Template:**

```ini
# [Sketch Name] - PlatformIO Configuration
# Extends board-level configuration

[platformio]
# Sketch-specific directories
src_dir = src
include_dir = include

; Extend the board environment
[env:[board-name]]
extends = env:[board-name]

; Sketch-specific build flags
build_flags = 
    ${env:[board-name].build_flags}
  ; Optional metadata overrides (normally set in include/version.h)
  ; -DSKETCH_NAME='"[sketch_name]"'
  ; -DSKETCH_VERSION='"1.0.0"'
  ; -DSKETCH_AUTHOR='"devopsnextgenx@gmail.com"'
  ; -DSKETCH_DATE='"YYYY-MM-DD"'

; Add sketch-specific libraries (beyond board defaults)
lib_deps = 
    ${env:[board-name].lib_deps}
    # Uncomment as needed:
    # adafruit/DHT sensor library@^1.4.2
    # Wire
    # SPI

; Sketch-specific monitor speed (can override board default)
monitor_speed = 115200
```

**Key Points:**
- `extends = env:[board-name]` pulls all board-level settings
- Sketch metadata defaults belong in `include/version.h` (per sketch)
- `build_flags` can optionally override metadata or add extra compile-time definitions
- `lib_deps` adds libraries beyond board defaults
- Can override timing and speed settings if needed

---

## Step 7: Create Sketch Documentation

### 7.1 Create `readme.md` (Quick Reference)

**Template:**

```markdown
# [Sketch Name]

## Purpose
Brief description of what this sketch does.

## Hardware Requirements
- **Board:** [Board Name]
- **Sensors/Peripherals:**
  - [Sensor 1] on GPIO[XX]
  - [Sensor 2] on I2C (SDA/SCL)

## Wiring Diagram
```
[Sensor] ─────── Nano/ESP32 Board
  GND ──────────→ GND
  VCC ──────────→ 3V3 or 5V
  DATA ─────────→ GPIO[XX]
  (Optional 10kΩ pull-up)
```

## Pin Configuration
- **Sensor Pin:** GPIO[XX] (see ../pin-layout.md)
- **LED Pin:** GPIO[XX]
- **Button Pin:** GPIO[XX]

Consult `../pin-layout.md` for complete GPIO layout and alternative pins.

## Expected Serial Output
```
=== [Sketch Name] Initialized ===
[Board Name]
--- Pin Configuration ---
Sensor Pin: GPIO23
LED Pin: GPIO2
Button Pin: GPIO15

Sensor: 512 | Voltage: 1.65 V
Sensor: 520 | Voltage: 1.72 V
...
```

## Configuration
Edit `include/[sketch_name]_config.h` to:
- Change `GPIO_SENSOR_PIN` to a different GPIO
- Modify `SENSOR_SAMPLE_INTERVAL` for sampling frequency
- Enable/disable debug output with `ENABLE_SERIAL_DEBUG`

## Building & Uploading
```bash
cd boards/[board-name]/sketches/[sketch-name]
pio run                    # Build
pio run --target upload    # Upload
pio device monitor         # Monitor serial output
```

Or use the master script:
```bash
bash scripts/lab-manager.sh  # Interactive menu
```

## Serial Settings
- **Baud Rate:** 115200 (configurable in config.h)
- **Data Bits:** 8
- **Stop Bits:** 1
- **Parity:** None

## Known Issues
- [Issue 1 if any]

## References
- Board documentation: `../pin-layout.md`
- Datasheet: [Link if applicable]
```

### 7.2 Create `CHANGELOG.md` (REQUIRED)

Every sketch must include a `CHANGELOG.md` in the sketch root. Update it for every meaningful change to keep sketch history traceable.

**Template:**

```markdown
# Changelog

All notable changes to this sketch are documented in this file.

## YYYY-MM-DD

### Added
- [New files, features, metadata, or integrations]

### Changed
- [Behavior updates, refactors, config changes]

### Fixed
- [Bug fixes]
```

**Rules:**
- Append newest entries at the top (descending by date).
- Use one date section per update session.
- Keep entries concise and specific to files/behavior changed.
- Update `CHANGELOG.md` in the same commit as code changes.

---

## Step 8: Create Dashboard (Optional)

### 8.1 Create Processing Dashboard (For Visual Feedback)

If your sketch streams data, create a Processing UI for real-time visualization:

**`dashboard/dashboard.pde`:**

```processing
// [Sketch Name] Dashboard
// Processing sketch for visualizing sensor data from Arduino/ESP32

import processing.serial.*;

Serial myPort;
int sensorValue = 0;
ArrayList<Integer> dataHistory;
final int MAX_HISTORY = 100;

void settings() {
  size(800, 600);
}

void setup() {
  // Initialize serial
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[0], 115200);  // Adjust index as needed
  myPort.bufferUntil('\n');
  
  dataHistory = new ArrayList<Integer>();
}

void draw() {
  background(20);
  
  // Draw title
  fill(255);
  textSize(24);
  text("Sensor Data Visualization", 20, 30);
  
  // Draw current value
  textSize(18);
  text("Current: " + sensorValue, 20, 70);
  
  // Draw history graph
  drawGraph();
}

void serialEvent(Serial p) {
  String inString = p.readStringUntil('\n');
  if (inString != null) {
    inString = trim(inString);
    try {
      sensorValue = int(inString);
      dataHistory.add(sensorValue);
      if (dataHistory.size() > MAX_HISTORY) {
        dataHistory.remove(0);
      }
    } catch (Exception e) {
      // Ignore non-numeric lines
    }
  }
}

void drawGraph() {
  stroke(100, 255, 100);
  strokeWeight(2);
  fill(0);
  rect(20, 100, 750, 450);
  
  if (dataHistory.size() < 2) return;
  
  stroke(100, 255, 100);
  float xStep = 750.0 / dataHistory.size();
  for (int i = 0; i < dataHistory.size() - 1; i++) {
    float x1 = 20 + i * xStep;
    float y1 = 550 - (dataHistory.get(i) / 4095.0) * 450;
    float x2 = 20 + (i + 1) * xStep;
    float y2 = 550 - (dataHistory.get(i + 1) / 4095.0) * 450;
    line(x1, y1, x2, y2);
  }
}
```

---

## Step 9: Test the Sketch

### 9.1 Compile & Build

```bash
cd boards/[board-name]/sketches/[sketch-name]  # Directories: kebab-case
pio run
```

Expected: Successful compilation with `.pio/build/` artifacts.

### 9.2 Upload to Hardware

```bash
pio run --target upload
```

Expected: Firmware uploaded, device reboots and runs sketch.

### 9.3 Monitor Serial Output

```bash
pio device monitor --baud 115200
```

Verify output matches expected results.

### 9.4 Test with Dashboard (if created)

```bash
cd dashboard
processing dashboard.pde  # Opens Processing IDE
# Run sketch (click Play button or Ctrl+R)
```

---

## Step 10: Document Completion

### 10.1 Final Checklist

- [ ] Header file created with all pin definitions
- [ ] `include/version.h` created (name, version, author, date)
- [ ] Main sketch code complete and tested
- [ ] Sketch compiles without errors
- [ ] Sketch uploads and runs on hardware
- [ ] Serial output verified
- [ ] `readme.md` documentation complete
- [ ] `CHANGELOG.md` created and updated for current changes
- [ ] Board `pin-layout.md` referenced in comments
- [ ] PlatformIO configuration (`platformio.ini`) created
- [ ] Optional: Processing dashboard created and tested
- [ ] Code follows modularity standards (headers separate from implementation)

### 10.2 Commit to Repository

```bash
git add boards/[board-name]/sketches/[sketch-name]/  # e.g., esp32-devkit/sketches/ir-sensor-read/
git commit -m "Add [sketch-name] sketch for [board-name]"
```

---

## Code Modularity Best Practices

### 11.1 Separate Headers from Implementation

**Good (Header + Impl):**
```cpp
// sensor_reader.h
uint16_t readSensorValue(uint8_t pin);
float convertToVoltage(uint16_t raw);

// sensor_reader.cpp
uint16_t readSensorValue(uint8_t pin) {
  return analogRead(pin);
}
```

**Avoid (Everything in main.cpp):**
```cpp
// main.cpp with all functions inline
// Hard to test, hard to reuse
```

### 11.2 Use Configuration Headers

**Good:**
```cpp
#include "my_sketch_config.h"
int pin = SENSOR_PIN;  // Compile-time constant
```

**Avoid:**
```cpp
int pin = 23;  // Magic number, hard-coded
```

### 11.3 Create Reusable Modules

For repeated tasks across sketches, add to `shared/include/`:
```cpp
// shared/include/sensor_reader.h
uint16_t readAnalogAverage(uint8_t pin, uint8_t samples);
```

Then include in your sketch:
```cpp
#include "sensor_reader.h"
```

---

## Troubleshooting

### Issue: "includes not found"
**Solution:** Verify `include_dir = include` in `platformio.ini` and header files are in the `include/` folder.

### Issue: "pin not defined"
**Solution:** Check `[sketch-name]_config.h` and ensure the pin exists on the board (reference `pin-layout.md`).

### Issue: "library not found"
**Solution:** Add to `lib_deps` in `platformio.ini` and run `pio lib install [library]`.

### Issue: "Serial output garbled"
**Solution:** Verify baud rate matches both code (`Serial.begin()`) and monitor (`pio device monitor --baud 115200`).

---

## Related Documentation

- **Boards SKILL:** [../boards/SKILL.md](../boards/SKILL.md)
- **Global PlatformIO Config:** [../../platformio.ini](../../platformio.ini)
- **Master Script:** [../../scripts/lab-manager.sh](../../scripts/lab-manager.sh)
- **Shared Utilities:** [../../shared/include/](../../shared/include/)

---

## Next Steps

1. Create additional sketches following this template
2. Expand `shared/` with common sensor drivers as needed
3. Share sketches with team for code review
4. Test on physical hardware before marking as stable
