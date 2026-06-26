# TB6612FNG Motor Driver Layout & Configuration

This file provides a structured reference layout and pinout mapping for the TB6612FNG dual motor driver breakout board. It is designed to be placed in an workspace directory (e.g., `.github/` or project root) to provide context for GitHub Copilot when writing Arduino embedded firmware.

---

## Technical Specifications
* **VM (Motor Power):** Max 15V DC
* **VCC (Logic Power):** 2.7V – 5.5V DC (Compatible with 3.3V and 5V MCUs)
* **Output Current:** 1.2A continuous (3.2A peak per channel)

---

## Hardware Pinout Reference

### Left Side (Power & Motor Outputs)
| Pin Name | Type | Description | Connection Target |
| :--- | :--- | :--- | :--- |
| **VM** | Power | Motor Supply Power | External Battery / Power Source (15V max) |
| **VCC** | Power | Logic Supply Power | MCU VCC (3.3V or 5V) |
| **GND** | Ground | Common Ground | System Ground |
| **Aout1** | Output | Motor A Output 1 | Motor A Terminal 1 |
| **Aout2** | Output | Motor A Output 2 | Motor A Terminal 2 |
| **Bout1** | Output | Motor B Output 1 | Motor B Terminal 1 |
| **Bout2** | Output | Motor B Output 2 | Motor B Terminal 2 |
| **GND** | Ground | Common Ground | System Ground |

### Right Side (MCU Control Inputs)
| Pin Name | Type | Description | Connection Target |
| :--- | :--- | :--- | :--- |
| **PWMA** | Input | Speed Control for Motor A | MCU PWM Pin |
| **INA2** | Input | Direction Control 2 for Motor A | MCU Digital Pin |
| **INA1** | Input | Direction Control 1 for Motor A | MCU Digital Pin |
| **STNDBY** | Input | Standby/Shutdown Control | MCU Digital Pin (HIGH = Run, LOW = Standby) |
| **INB1** | Input | Direction Control 1 for Motor B | MCU Digital Pin |
| **INB2** | Input | Direction Control 2 for Motor B | MCU Digital Pin |
| **PWMB** | Input | Speed Control for Motor B | MCU PWM Pin |
| **GND** | Ground | Common Ground | System Ground |

---

## Control Logic Truth Table

The control logic applies identically to both Channel A (`INA1`, `INA2`, `PWMA`) and Channel B (`INB1`, `INB2`, `PWMB`).

| STNDBY | INx1 | INx2 | PWMx | Output (Out1, Out2) | Motor Mode |
| :---: | :---: | :---: | :---: | :---: | :--- |
| `LOW` | `X` | `X` | `X` | High-Z (Off) | **Standby** (Power-down) |
| `HIGH` | `HIGH` | `LOW` | `HIGH` | HIGH, LOW | **Forward / Clockwise** (Full Speed) |
| `HIGH` | `HIGH` | `LOW` | `PWM` | HIGH, LOW | **Forward / Clockwise** (Proportional Speed) |
| `HIGH` | `LOW` | `HIGH` | `HIGH` | LOW, HIGH | **Reverse / Counter-Clockwise** (Full Speed) |
| `HIGH` | `LOW` | `HIGH` | `PWM` | LOW, HIGH | **Reverse / Counter-Clockwise** (Proportional Speed) |
| `HIGH` | `LOW` | `LOW` | `X` | HIGH, HIGH | **Short Brake** |
| `HIGH` | `HIGH` | `HIGH` | `X` | LOW, LOW | **Short Brake** |

> **Note:**
> * `X` denotes a "Don't Care" state.
> * To turn the motors on, **STNDBY** must be pulled `HIGH`. 
> * Short Brake forces both output terminals to the same potential, causing the motor back-EMF to actively resist rotation.

---

## C++ Template Reference for Copilot

```cpp
// Suggested Pin Definition Architecture
struct MotorPins {
    const uint8_t pwm;
    const uint8_t in1;
    const uint8_t in2;
};

// TB6612FNG Pin Mapping Example
namespace Pins {
    constexpr uint8_t STNDBY = 4;
    
    constexpr MotorPins MotorA = { .pwm = 5, .in1 = 6, .in2 = 7 };
    constexpr MotorPins MotorB = { .pwm = 10, .in1 = 8, .in2 = 9 };
}
```