# SKILL.md: Adding and Configuring a New Board

## Overview
This guide provides step-by-step instructions for adding and configuring a new microcontroller board to the embedded-device-lab monorepo. Follow this procedure to integrate a new hardware platform while maintaining the repository's architecture and PlatformIO inheritance hierarchy.

---

## Prerequisites

- PlatformIO CLI installed (`pip install platformio`)
- Access to the embedded-device-lab repository root
- Knowledge of your target board's specifications (pin layout, processor, clock speed, flash size, etc.)
- Board support in PlatformIO's platform definitions (verify with `pio boards`)

---

## Step 1: Create Board Directory Structure

1. **Create the board folder:**
   ```bash
   mkdir -p boards/[board-name]/sketches
   mkdir -p boards/[board-name]/docs
   ```

   **Naming Convention:** Use lowercase with hyphens (kebab-case) for **directories**, following this format:
   - `[processor]-[variant-or-edition]`
   - Examples: `esp32-devkit`, `arduino-mega-2560`, `teensy-4-1`, `rpi-pico`
   
   **Note:** Inside C/C++ code, use snake_case for filenames (e.g., `blink_config.h`, `main.cpp`) for Linux compatibility.

2. **Verify the structure:**
   ```bash
   boards/[board-name]/
   ├── docs/
   ├── sketches/
   └── (platformio.ini will be created in Step 3)
   ```

---

## Step 2: Document Board Pin Layout

### 2.1 Create `pin-layout.md`

Create a comprehensive pin layout documentation file:

```bash
touch boards/[board-name]/pin-layout.md
```

**Required Sections in `pin-layout.md`:**

- **Board Overview:** Name, processor type, clock speed, RAM, flash memory, GPIO count
- **Pin Mapping Tables:** Organize pins by category:
  - Power & Ground
  - Serial Communication (UART)
  - General Purpose GPIO
  - Special Function Pins (PWM, ADC, I2C, SPI)
  - Analog Channels (if applicable)
  - External Interrupt Pins (if applicable)

- **Alternate Functions:** Document which pins can serve multiple purposes
- **Special Behavior:** Strapping pins, boot-time behaviors, conflicts (e.g., ADC2 with WiFi)
- **Common Peripheral Wiring:** Provide example wiring diagrams (in text or markdown) for:
  - Temperature/Humidity sensors (DHT)
  - I2C displays (OLED/LCD)
  - Relay modules
  - Motor drivers
  - OneWire temperature sensors
  
- **Developer Notes:** Voltage levels, power budgets, known issues, calibration needs

**Example Resources:**
- See `boards/esp32_devkit/pin-layout.md` and `boards/arduino_nano/pin-layout.md` for detailed examples

---

### 2.2 Add Board Layout Image (Optional but Recommended)

Create or add a visual schematic image:

```bash
touch boards/[board-name]/pin-layout.png
# or
touch boards/[board-name]/pin-layout.jpg
```

**Image Requirements:**
- Should show physical board layout with labeled pin numbers
- Include power pins, GPIO labels, and functional groupings (SPI, I2C, UART)
- Preferably a high-resolution PNG or SVG for clarity
- Place in the board's root directory alongside `pin-layout.md`

**Resources:**
- Use online board schematic tools or search for official datasheets
- Many boards have community-created visual pinouts on GitHub
- Embed references to these resources in `pin-layout.md`

---

## Step 3: Create Board-Level PlatformIO Configuration

### 3.1 Create `boards/[board-name]/platformio.ini`

This file extends the global `platformio.ini` while adding board-specific settings.

**Template:**
```ini
# [Board Name] Board Configuration
# This configuration extends the global platformio.ini and adds board-specific settings

[platformio]
# Board-specific source directory (if different from global)
src_dir = sketches/${SKETCH_NAME}/src
include_dir = sketches/${SKETCH_NAME}/include

[env:[env_name]]
extends = env:[env_name]
platform = [platform_id]
board = [board_id]
framework = arduino

; Board-specific settings
upload_speed = [speed]
upload_port = auto
monitor_speed = [speed]
monitor_port = auto

; Processor configuration
board_build.f_cpu = [frequency]

; Board-specific build flags
build_flags = 
    ${env.build_flags}
    -DBOARD_[BOARD_DEFINE]

; Board-specific libraries
lib_deps = 
    ${env.lib_deps}
```

**Key Steps:**

1. **Find PlatformIO board ID:**
   ```bash
   pio boards | grep -i "[board-name]"
   ```
   Example output: `teensy41 (Teensy 4.1)`

2. **Identify platform ID:**
   ```bash
   pio boards teensy41  # Shows platform: teensy
   ```

3. **Determine upload speed:**
   - ESP32: 921600
   - Arduino Nano: 57600
   - Arduino Uno: 115200
   - Most boards: 115200

**Note on File Naming:**
- Use kebab-case for board directory: `boards/esp32-devkit/`
- Use snake_case for C/C++ files inside: `platformio.ini`, `pin_layout.md`
- This ensures Linux/UNIX compatibility and follows C/C++ conventions

4. **Determine CPU frequency:**
   - ESP32: 160 MHz or 240 MHz
   - Arduino AVR: 16 MHz
   - Teensy 4.1: 600 MHz

5. **Fill in environment name:**
   - Typically: `[env:[board_name]]`
   - Must match the global `platformio.ini` if extending

**Example (STM32F103 - "blue-pill"):**
```ini
[env:stm32-f103]
extends = env:stm32-f103
platform = ststm32
board = bluepill_f103c8
framework = stm32cube
upload_protocol = stlink
upload_speed = 460800
build_flags = 
    ${env.build_flags}
    -DBOARD_STM32_F103
```

---

## Step 4: Configure Board Inheritance Chain

### 4.1 Update Global `platformio.ini` (If Adding New Platform)

If your board's platform isn't already in the global `platformio.ini`, add a new `[env:board_name]` section:

```ini
[env:[new_board]]
platform = [platform_id]
board = [board_id]
framework = arduino
upload_speed = [speed]
monitor_speed = [speed]
build_flags = 
    ${env.build_flags}
    -DBOARD_[NEW_BOARD]
```

Then update `default_envs` at the top if you want it built by default.

### 4.2 Verify Inheritance

Test the inheritance chain:
```bash
cd boards/[board-name]/  # e.g., boards/esp32-devkit/
pio project config  # Shows merged configuration
```

---

## Step 5: Create Template Sketch

### 5.1 Generate Initial Sketch Structure

```bash
mkdir -p boards/[board-name]/sketches/hello-world/{src,include,dashboard,docs}
```

### 5.2 Create Minimal Template

**`boards/[board-name]/sketches/hello-world/platformio.ini`:**
```ini
[env:[board-name]]
extends = env:[board-name]
build_flags = 
    ${env:[board_name].build_flags}
    -DSKETCH_NAME="hello_world"
```

**`boards/[board-name]/sketches/hello-world/src/main.cpp`:**
```cpp
#include <Arduino.h>

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("Hello World on [Board Name]!");
}

void loop() {
  delay(1000);
}
```

**`boards/[board-name]/sketches/hello-world/readme.md`:**
```markdown
# Hello World Sketch

Simple test sketch for [Board Name]. Outputs a message to serial every second.

## Expected Output
```
Hello World on [Board Name]!
Hello World on [Board Name]!
...
```

## Serial Settings
- Baud Rate: 115200
```

---

## Step 6: Document Board-Specific Considerations

### 6.1 Create `boards/[board-name]/docs/README.md`

Include board-specific notes:

```markdown
# [Board Name] Documentation

## Overview
- **Processor:** [Processor Name & Specs]
- **Flash:** [Size]
- **RAM:** [Size]
- **GPIO Pins:** [Count]
- **Special Features:** WiFi, Bluetooth, etc.

## Setup Instructions
1. Install drivers if necessary
2. Connect via USB
3. Verify with: `pio device list`

## Known Issues
- [Issue 1]
- [Issue 2]

## Resources
- Official Datasheet: [Link]
- Community Wiki: [Link]
```

---

## Step 7: Test the Board Configuration

### 7.1 Verify Build

```bash
cd boards/[board-name]/sketches/hello_world
pio run
```

Expected output: Compilation successful, `.pio/build/` created.

### 7.2 Test Upload (with hardware connected)

```bash
pio run --target upload
```

### 7.3 Test Monitor

```bash
pio device monitor --baud 115200
```

---

## Step 8: Add to Repository

### 8.1 Test Discover

Run the master script to verify auto-discovery:
```bash
bash scripts/lab-manager.sh
```

Your new board should appear in the board selection menu.

### 8.2 Commit

```bash
git add boards/[board-name]/  # e.g., boards/esp32-devkit/
git commit -m "Add [Board Name] board support"
```

---

## Troubleshooting

### Issue: "Board not found in platformio"
**Solution:** Verify the board ID:
```bash
pio boards | grep -i "[your-board]"
```

### Issue: "Platform not installed"
**Solution:** Install the platform:
```bash
pio platform install [platform_name]
```

### Issue: "USB device not detected"
**Solution:** Check udev rules or permissions:
```bash
bash scripts/lab-manager.sh  # Select "Configure Linux udev Rules"
```

### Issue: Compilation errors with "shared" includes
**Solution:** Verify build flags include:
```ini
-I../../shared/include
```

---

## Best Practices

1. **Pin Naming:** Always reference pins by their GPIO number, not Arduino-style names (when possible)
2. **Documentation:** Update `pin-layout.md` with any pin-specific quirks
3. **Voltage Levels:** Clearly document if the board is 5V or 3.3V tolerant
4. **Power Budget:** Include maximum current draw specifications
5. **Bootloader:** Document how to enter programming mode (if not automatic via USB)
6. **Conflict Resolution:** List any pins that can't be used simultaneously (e.g., ADC2 + WiFi on ESP32)

---

## Next Steps

Once your board is configured:
1. Create project sketches following the [Adding and Configuring a New Sketch](../sketches/SKILL.md) guide
2. Add board-specific sensor examples to `sketches/`
3. Share pin layout with team via documentation
4. Test all sketches on the physical hardware before committing

---

## Related Documentation

- **Sketches SKILL:** [../sketches/SKILL.md](../sketches/SKILL.md)
- **Global PlatformIO Config:** [../../platformio.ini](../../platformio.ini)
- **Master Script:** [../../scripts/lab-manager.sh](../../scripts/lab-manager.sh)
