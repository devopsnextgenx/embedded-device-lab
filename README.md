# Embedded Device Lab

**A professional-grade hardware/firmware monorepo for managing multi-board PlatformIO projects with sensor testing, full-scale applications, and Processing-based UI dashboards.**

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Arduino%20%7C%20ESP32%20%7C%20AVR%20%7C%20ARM-success)

---

## 🎯 Purpose

Embedded Device Lab provides a **single-repository architecture** for managing diverse embedded systems projects targeting multiple microcontroller boards. It combines:

- ✅ **Board Support:** Unified configuration for Arduino, ESP32, Teensy, STM32, and more
- ✅ **Sketch Management:** Modular, reusable firmware applications with sensor testing capabilities
- ✅ **Shared Assets:** Common libraries, utilities, and configuration across all boards
- ✅ **PlatformIO Integration:** Hierarchical configuration inheritance (global → board → sketch)
- ✅ **Interactive CLI:** Master orchestration script for build, upload, monitor, and diagnostics
- ✅ **Hardware Diagnostics:** USB device detection, permission troubleshooting, udev rule automation
- ✅ **Dashboard Support:** Processing-based UI for real-time sensor visualization

---

## 📋 Repository Structure

```
embedded-device-lab/
├── .github/
│   ├── workflows/              # CI/CD pipelines (GitHub Actions)
│   └── skills/                 # Documentation & guides
│       ├── boards/SKILL.md     # Adding a new board
│       └── sketches/SKILL.md   # Creating a new sketch
│
├── shared/                     # Global shared assets across all boards
│   ├── src/                    # Shared C++ implementation files
│   │   └── (common utilities, drivers, etc.)
│   └── include/                # Shared header files (.h)
│       ├── shared_utils.h      # Common Arduino utilities
│       └── shared_sensors.h    # Sensor abstraction & helpers
│
├── scripts/
│   └── lab-manager.sh          # Master interactive management script
│
├── boards/                     # Hardware platform definitions
│   ├── esp32-devkit/           # ESP32 DevKit board (naming: kebab-case)
│   │   ├── platformio.ini      # Board-level PlatformIO config
│   │   ├── pin-layout.md       # GPIO & pin mapping documentation
│   │   ├── pin-layout.png      # Visual pin layout (optional)
│   │   ├── docs/               # Board-specific documentation
│   │   └── sketches/           # Applications for this board
│   │       ├── blink_test/     # Example: Simple LED blink
│   │       │   ├── src/main.cpp
│   │       │   ├── include/blink_config.h
│   │       │   ├── platformio.ini
│   │       │   └── readme.md
│   │       └── [other-sketches]/
│   │
│   ├── arduino_nano/           # Arduino Nano board
│   │   ├── platformio.ini
│   │   ├── pin-layout.md
│   │   └── sketches/
│   │       ├── sensor_read/    # Example: ADC sensor reading
│   │       └── [other-sketches]/
│   │
│   └── [other-boards]/         # Add more boards here
│
├── platformio.ini              # Global PlatformIO configuration (shared vars, common libs)
├── README.md                   # This file
└── .gitignore                  # Git ignore rules
```

---

## 🚀 Quick Start

### 1. Prerequisites

```bash
# Install PlatformIO CLI
pip install platformio

# Verify installation
pio --version
```

### 2. Clone & Navigate

```bash
git clone https://github.com/yourusername/embedded-device-lab.git
cd embedded-device-lab
```

### 3. Run Master Script

```bash
bash scripts/lab-manager.sh
```

**Interactive Menu:**
```
=== Available Boards ===
  1) esp32-devkit
  2) arduino-nano

Enter board number (1-2):
```

Select a board → Select a sketch → Choose operation (Build, Upload, Monitor, Diagnostics, etc.)

### 4. Build & Upload

```bash
cd boards/esp32_devkit/sketches/blink_test
pio run                    # Build
pio run --target upload    # Upload to device
pio device monitor         # Monitor serial output
```

---

## � Naming Conventions

To ensure consistency and Linux/UNIX compatibility:

### **Directories: Kebab-Case** (hyphens)
- Boards: `boards/esp32-devkit/`, `boards/arduino-nano/`
- Sketches: `sketches/blink-test/`, `sketches/ir-sensor-read/`

### **C/C++ Files: Snake_Case** (underscores)
- Headers: `blink_config.h`, `sensor_config.h`
- Includes in code: `#include "blink_config.h"`
- Config files: `platformio.ini`, `pin_layout.md`

This hybrid approach provides:
- ✅ Clean, organized directory structure (kebab-case)
- ✅ Full C/C++ compatibility (snake_case for code files)
- ✅ Linux/UNIX filesystem compatibility (underscores in filenames)

---

## �📖 Documentation

### For Adding a New Board
See [.github/skills/boards/SKILL.md](.github/skills/boards/SKILL.md)

**Quick Summary:**
1. Create `boards/[board-name]/` directory
2. Add `pin-layout.md` (GPIO documentation)
3. Create `platformio.ini` (inherits from root config)
4. Add template sketch for testing
5. Verify with master script

### For Creating a New Sketch
See [.github/skills/sketches/SKILL.md](.github/skills/sketches/SKILL.md)

**Quick Summary:**
1. Create sketch directory under `boards/[board]/sketches/[sketch-name]/`
2. Create header file with pin definitions (must reference `pin-layout.md`)
3. Write modular C++ code in `src/main.cpp`
4. Configure `platformio.ini` (inherits from board config)
5. Test with `pio run` and `pio run --target upload`

### Board Documentation
- [ESP32 DevKit Pin Layout](boards/esp32-devkit/pin-layout.md)
- [Arduino Nano Pin Layout](boards/arduino-nano/pin-layout.md)

### Example Sketches
- [Blink Test (ESP32)](boards/esp32-devkit/sketches/blink-test/readme.md)
- [IR Sensor Read (Arduino Nano)](boards/arduino-nano/sketches/ir-sensor-read/readme.md)

---

## 🛠️ Master Management Script Features

The `scripts/lab-manager.sh` provides:

### ✓ Dynamic Board Discovery
- Scans `boards/` directory
- Lists available boards with interactive selection

### ✓ Dynamic Sketch Discovery
- Scans sketches within selected board
- Lists available sketches with descriptions

### ✓ Operations Menu
1. **Build (Compile):** Execute `pio run`
2. **Upload:** Execute `pio run --target upload`
3. **Monitor:** Interactive serial console with configurable baud rates
4. **Hardware Diagnostics & USB Fix:**
   - List connected USB serial devices (`lsusb`, `dmesg`)
   - Check read/write permissions on serial ports
   - Automated fix: `chmod 666` or add to dialout/plugdev groups
5. **Configure Linux udev Rules:**
   - Generate rules for common USB-to-Serial adapters (CH340, CP210x, FTDI)
   - Automatically install to `/etc/udev/rules.d/`
   - Reload udev subsystem
6. **Switch Sketch/Board:** Return to board/sketch selection
7. **Exit**

### ✓ Robust Error Handling
- Validates PlatformIO installation
- Checks repository structure
- Handles missing devices gracefully
- Provides actionable error messages

---

## 📌 PlatformIO Configuration Hierarchy

```
Global Config (platformio.ini)
        ↓ extends
Board Config (boards/[board]/platformio.ini)
        ↓ extends
Sketch Config (boards/[board]/sketches/[sketch]/platformio.ini)
```

**Example: Build flags accumulate through hierarchy**
```ini
# Global: -DEMBEDDED_LAB_VERSION=1.0.0 -I../../shared/include
# + Board:  -DBOARD_ESP32
# + Sketch: -DSKETCH_NAME="blink_test" -DLED_PIN=2
# = Final: All flags combined for compilation
```

---

## 💡 Usage Examples

### Build a Sketch

**Option 1: Interactive Script**
```bash
bash scripts/lab-manager.sh
# Follow prompts → select board → select sketch → choose "Build"
```

**Option 2: Direct CLI**
```bash
cd boards/esp32_devkit/sketches/blink_test
pio run
```

### Upload to Device

```bash
# Interactive
bash scripts/lab-manager.sh
# → select board → select sketch → choose "Upload"

# Or direct
cd boards/esp32_devkit/sketches/blink_test
pio run --target upload
```

### Monitor Serial Output

```bash
bash scripts/lab-manager.sh
# → select board → select sketch → choose "Monitor"
# → select baud rate (115200 for ESP32, 9600 for Arduino Nano)
# → Press Ctrl+C to exit
```

### Fix USB Permission Issues

```bash
bash scripts/lab-manager.sh
# → select board → select sketch → choose "Hardware Diagnostics & USB Fix"
# → Script lists devices and permission issues
# → Choose automated fix (chmod or add to groups)
```

### Configure udev Rules

```bash
bash scripts/lab-manager.sh
# → select board → select sketch → choose "Configure Linux udev Rules"
# → Script generates and installs /etc/udev/rules.d/99-embedded-device-lab.rules
# → Auto-detection of CH340, CP210x, FTDI, Arduino boards
```

---

## 🔧 Configuration Files

### Global `platformio.ini`
Defines shared settings, libraries, and build flags used by all boards/sketches.

```ini
[platformio]
default_envs = esp32_devkit, arduino_nano

[env]
build_flags = 
    -I${PROJECT_DIR}/../../shared/include
lib_deps = 
    # Shared libraries across all projects
```

### Board-Level Config
Each board extends the global config with platform-specific settings.

```ini
[env:esp32_devkit]
extends = env:esp32_devkit
platform = espressif32
board = esp32doit-devkit-v1
upload_speed = 921600
build_flags = 
    ${env.build_flags}
    -DBOARD_ESP32
```

### Sketch-Level Config
Each sketch fine-tunes board settings for its specific needs.

```ini
[env:esp32_devkit]
extends = env:esp32_devkit
build_flags = 
    ${env:esp32_devkit.build_flags}
    -DLED_PIN=2
lib_deps = 
    ${env:esp32_devkit.lib_deps}
    # Sketch-specific libraries
```

---

## 📚 Shared Code Pattern

### Using Shared Headers

Any sketch can include shared utilities:

```cpp
#include <Arduino.h>
#include "shared_utils.h"
#include "shared_sensors.h"

void setup() {
  initSerial(115200);
  pinMode(LED_PIN, OUTPUT);
}

void loop() {
  uint16_t raw = readAnalogAverage(SENSOR_PIN, 10);
  float voltage = adcToVoltage_ESP32(raw);
  Serial.println(voltage);
  delay(1000);
}
```

### Adding Shared Code

1. Create file in `shared/include/` (for headers) or `shared/src/` (for implementation)
2. Reference in `platformio.ini`:
   ```ini
   build_flags = -I${PROJECT_DIR}/../../shared/include
   ```
3. Include in your sketch:
   ```cpp
   #include "my_shared_header.h"
   ```

---

## 🐛 Troubleshooting

### Issue: "pio: command not found"
**Solution:**
```bash
pip install platformio
# Add to PATH or use: python -m platformio
```

### Issue: USB Device Not Found
**Solution:**
1. Verify device is connected: `lsusb`
2. Check permissions:
   ```bash
   ls -la /dev/ttyUSB* /dev/ttyACM*
   ```
3. Fix permissions:
   ```bash
   bash scripts/lab-manager.sh
   # → Choose "Hardware Diagnostics & USB Fix"
   ```

### Issue: Upload Speed Timeout
**Solution:**
- Reduce upload speed in `platformio.ini`: `upload_speed = 460800`
- Or try: `upload_speed = 115200`

### Issue: Serial Output Garbled
**Solution:**
- Check baud rate matches in code and monitor
- Verify: `Serial.begin(115200)` matches `pio device monitor --baud 115200`

### Issue: Compilation Error on Includes
**Solution:**
- Verify `include_dir` in `platformio.ini`
- Check header files exist in `include/` directory
- Run `pio run -vv` for verbose output

---

## 🤝 Contributing

### Adding a New Board

Follow [.github/skills/boards/SKILL.md](.github/skills/boards/SKILL.md):
1. Create `boards/[board-name]/` structure
2. Document pin layout in `pin-layout.md`
3. Create board-level `platformio.ini`
4. Create template sketch
5. Test with master script
6. Commit with PR

### Adding a New Sketch

Follow [.github/skills/sketches/SKILL.md](.github/skills/sketches/SKILL.md):
1. Create sketch directory under `boards/[board]/sketches/[sketch]/`
2. Write modular code with separate headers
3. Reference parent board's `pin-layout.md`
4. Document in `readme.md`
5. Test before committing

### Sharing Utility Code

1. Add to `shared/include/` or `shared/src/`
2. Document usage with comments
3. Update all sketches' `platformio.ini` if needed
4. Test compilation across multiple boards

---

## 📦 Supported Boards

Currently configured boards (using kebab-case naming):
- ✅ **ESP32-DOIT DevKit v1** (`esp32-devkit`)
- ✅ **Arduino Nano v3** (`arduino-nano`)

Ready to add:
- [ ] Arduino Mega 2560
- [ ] Teensy 4.1
- [ ] STM32F103 (Blue Pill)
- [ ] Raspberry Pi Pico
- [ ] Other platforms on request

---

## 📜 License

This project is licensed under the **MIT License** – see [LICENSE](LICENSE) file for details.

---

## 🔗 Resources

- [PlatformIO Documentation](https://docs.platformio.org/)
- [Arduino Reference](https://www.arduino.cc/reference/en/)
- [ESP32 Documentation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/)
- [Processing Reference](https://processing.org/reference/)

---

## 📧 Support & Feedback

For issues, questions, or feature requests:
1. Check [troubleshooting section](#-troubleshooting) above
2. Review board-specific documentation in `pin-layout.md` files
3. Consult [.github/skills/](./github/skills/) guides
4. Open an issue on GitHub with:
   - Exact error message
   - Board name and sketch name
   - Output of `pio device list`

---

**Version:** 1.0.0  
**Last Updated:** June 2026  
**Maintainer:** Embedded Device Lab Team

---

## 🎓 Learning Path

**New to embedded systems?**
1. Start with [blink_test](boards/esp32_devkit/sketches/blink_test/) sketch
2. Read [ESP32 Pin Layout](boards/esp32_devkit/pin-layout.md)
3. Review [sketches/SKILL.md](.github/skills/sketches/SKILL.md)
4. Create your first sensor reading sketch

**New to the lab repository?**
1. Clone and run master script: `bash scripts/lab-manager.sh`
2. Build and upload the blink_test sketch
3. Open serial monitor and watch output
4. Review the sketch code and config files
5. Follow [boards/SKILL.md](.github/skills/boards/SKILL.md) to add a new board

**Adding custom code?**
1. Always reference parent board's `pin-layout.md` when assigning pins
2. Create header files for pin definitions (separate from main.cpp)
3. Add modular, reusable functions
4. Document with comments referencing hardware connections
