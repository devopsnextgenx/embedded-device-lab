# Board Documentation - ESP32 DevKit

This directory contains board-specific documentation and sketches for the **ESP32-DOIT DevKit v1**.

## Quick Links

- **Pin Layout:** [pin-layout.md](pin-layout.md) - Complete GPIO mapping and descriptions
- **Pin Diagram:** [pin-layout.png](pin-layout.png) - Visual board layout (optional)
- **Available Sketches:** See `sketches/` directory below

## Sketches

- **blink_test** - Simple LED blinking example (Hello World)
- *(Add more sketches here)*

## Getting Started

1. Review [pin-layout.md](pin-layout.md) to understand the board's pin assignments
2. Choose a sketch from the `sketches/` directory
3. Build with: `pio run` (from sketch directory)
4. Upload with: `pio run --target upload`
5. Monitor with: `pio device monitor --baud 115200`

Or use the master script: `bash scripts/lab-manager.sh`

## Board Specifications

| Property | Value |
|----------|-------|
| Processor | Xtensa dual-core 32-bit LX6 |
| Clock Speed | 160 MHz (adjustable to 240 MHz) |
| RAM | 520 KB SRAM |
| Flash | 4 MB (partitionable) |
| GPIO Pins | 34 (input only on some), 25 (input/output) |
| ADC | 12-bit, 18 channels |
| DAC | 2 channels (8-bit) |
| UART | 3 channels |
| SPI | 4 channels |
| I2C | 2 (configurable on any GPIO) |

## USB Connection

- **Port:** USB Micro-B
- **Bridge Chip:** CH340 or CP2102 (batch dependent)
- **Default Baud Rate:** 115200

## Resources

- Official Datasheet: [ESP32 Technical Reference Manual](https://www.espressif.com/sites/default/files/documentation/esp32_technical_reference_manual_en.pdf)
- Board Schematics: Available from manufacturer
- Community Wiki: [ESP32 Arduino GitHub](https://github.com/espressif/arduino-esp32)

## Next Steps

For adding a new sketch to this board, see [../../.github/skills/sketches/SKILL.md](../../.github/skills/sketches/SKILL.md)
