# Board Documentation - Arduino Nano

This directory contains board-specific documentation and sketches for the **Arduino Nano v3.x (ATmega328P)**.

## Quick Links

- **Pin Layout:** [pin-layout.md](pin-layout.md) - Complete GPIO mapping and descriptions
- **Pin Diagram:** [pin-layout.png](pin-layout.png) - Visual board layout (optional)
- **Available Sketches:** See `sketches/` directory below

## Sketches

- **sensor_read** - Analog sensor reading example (ADC demonstration)
- *(Add more sketches here)*

## Getting Started

1. Review [pin-layout.md](pin-layout.md) to understand the board's pin assignments
2. Choose a sketch from the `sketches/` directory
3. Build with: `pio run` (from sketch directory)
4. Upload with: `pio run --target upload`
5. Monitor with: `pio device monitor --baud 9600`

Or use the master script: `bash scripts/lab-manager.sh`

## Board Specifications

| Property | Value |
|----------|-------|
| Processor | ATmega328P (8-bit AVR) |
| Clock Speed | 16 MHz |
| RAM | 2 KB SRAM |
| Flash | 32 KB (2 KB bootloader) |
| EEPROM | 1 KB |
| GPIO Pins | 22 (14 digital, 8 analog) |
| PWM Pins | 6 (D3, D5, D6, D9, D10, D11) |
| ADC | 10-bit, 8 channels |
| UART | 1 channel (Serial) |
| SPI | Hardware (D10-D13) |
| I2C | 2 (SDA=A4, SCL=A5) |

## USB Connection

- **Port:** USB Mini-B or USB Micro-B (variant dependent)
- **Bridge Chip:** CH340G (newer) or FT232RL (older)
- **Default Baud Rate:** 9600

## Power Supply

- **Input:** 5V USB or 7-12V DC jack (regulated to 5V)
- **Output:** 5V @ ~500mA, 3.3V @ low-current

## Resources

- Official Schematics: [Arduino Nano Schematic](https://www.arduino.cc/en/uploads/Main/ArduinoNano30Schematic.pdf)
- Datasheet: [ATmega328P Datasheet](https://www.microchip.com/datasheet/ATmega328P)
- Community Wiki: [Arduino Nano](https://www.arduino.cc/en/Guide/ArduinoNano)

## Known Issues

- **Small Memory:** Only 2 KB RAM, limit library usage
- **USB Driver:** May need CH340 driver on Windows
- **Pin Labels:** Some boards have different silkscreen naming

## Tips & Tricks

1. Use `F()` macro for string literals to save SRAM:
   ```cpp
   Serial.println(F("This saves RAM"));  // Better than Serial.println("text");
   ```

2. Limited analog pins – plan carefully if using multiple sensors

3. Consider using external EEPROM if persistent storage is needed

## Next Steps

For adding a new sketch to this board, see [../../.github/skills/sketches/SKILL.md](../../.github/skills/sketches/SKILL.md)
