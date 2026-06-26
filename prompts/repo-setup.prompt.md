Act as an expert Embedded Systems Architect and Devops Engineer. I need to bootstrap a specialized hardware/firmware monorepo named `embedded-device-lab`. This repository uses a single-repo structure to manage and deploy PlatformIO-based sketches across multiple diverse boards (e.g., Arduino, ESP32, Pi Zero) and features sensor testing, full-scale projects, and Processing-based UI dashboards.

Please generate the entire boilerplate structure, including a master interactive Bash orchestration script, structural templates, and two detailed guide files (`SKILL.md`).

Follow these strict requirements:

---

### 1. REPOSITORY ARCHITECTURE
Generate the following directory structure:
embedded-device-lab/
├── .github/
├── shared/                       # Global shared assets across all boards
│   ├── src/                      # Common source files (.cpp)
│   └── include/                  # Common header files (.h)
├── scripts/
│   └── lab-manager.sh            # The master interactive management script
├── boards/
│   └── [board-template-name]/    # e.g., esp32_devkit, arduino_nano
│       ├── docs/
│       ├── pin-layout.md         # Documented pin mappings and descriptions
│       ├── pin-layout.png        # Placeholder/instructions for board layout image
│       ├── platformio.ini        # Board configuration inheriting/extending settings
│       └── sketches/
│           └── [sketch-template-name]/
│               ├── docs/
│               ├── src/
│               │   └── main.cpp
│               ├── include/
│               ├── dashboard/     # Processing code for display/UI dashboards
│               ├── platformio.ini # Sketch configuration inheriting/extending settings
│               └── readme.md      # Documentation specific to this sketch/sensor test
├── platformio.ini                # Global configuration for shared variables/extends
└── README.md                     # Main repository overview

---

### 2. PLATFORMIO INHERITANCE HIERARCHY
- Create a global `platformio.ini` at the root containing common properties, common libraries, and build flags (e.g., sharing the `shared/include` and `shared/src` paths via `build_flags = -I../../shared/include`).
- Create a template `platformio.ini` for individual boards that utilizes PlatformIO's `extends` feature to pull properties from the root configuration, while allowing fine-tuning of environment variables, specific board speeds, and local definitions.
- Create a template `platformio.ini` for individual sketches that utilizes PlatformIO's `extends` feature to pull properties from the root configuration, while allowing fine-tuning of environment variables, specific board speeds, and local definitions.

---

### 3. INTERACTIVE MASTER SCRIPT (`scripts/lab-manager.sh`)
Write a robust, production-grade Bash script that provides a CLI text menu system to handle everything. It must implement the following workflow and features:

*   **Step 1: Board Selection:** Scan the `boards/` directory and present a dynamic numbered list of available boards for the user to choose from.
*   **Step 2: Sketch Selection:** Once a board is selected, scan its `sketches/` folder and present a numbered list of available sketches.
*   **Step 3: Operations Menu:** After choosing a board and sketch, show an interactive loop menu with these exact options:
    1.  **Build (Compile):** Execute `pio run` inside the selected sketch directory.
    2.  **Upload:** Execute `pio run --target upload` for the selected sketch.
    3.  **Monitor:** Prompt the user to select/confirm a Baud Rate (list common ones: 9600, 115200, etc.) and launch `pio device monitor`.
    4.  **Hardware Diagnostics & USB Fix:** 
        - List currently connected USB serial devices (`lsusb` and `dmesg | grep tty`).
        - Check current read/write permissions on the active serial port (e.g., `/dev/ttyUSB0` or `/dev/ttyACM0`).
        - Offer an automated option to fix USB access permissions on the fly (`sudo chmod 666` or adding the user to the `dialout`/`plugdev` group).
    5.  **Configure Linux udev Rules:** 
        - Check for/generate a standard rule file for common microcontrollers (like CH340, CP210x, FTDI).
        - Provide an automated option to copy this file to `/etc/udev/rules.d/99-embedded-device-lab.rules` and reload the udev subsystem (`sudo udevadm control --reload-rules && sudo udevadm trigger`).
    6.  **Switch Sketch/Board:** Return to the initial setup steps.
    7.  **Exit**

---

### 4. DOCUMENTATION STANDARDS (`SKILL.md`)
Create two distinct Markdown skill guides to ensure seamless future expansion:

1.  **`.github/skills/boards/SKILL.md` (Adding and Configuring a New Board):**
    - Outline the exact steps to create a new board folder.
    - Add platformio.ini for board level configuration
    - Detail the necessity of establishing the `pin-layout.md` and adding a visual layout image (`pin-layout.png`/`jpg`).
    - Explain how to structure the nested `sketches/` folder.

2.  **`.github/skills/sketches/SKILL.md` (Adding and Configuring a New Sketch):**
    - Detail how to initialize a sketch folder (src, include, platformio.ini, dashboard).
    - Provide an explicit instruction stating: *"When writing sketches, the developer MUST reference the parent board's `pin-layout.md` and `pin-layout.png` to map hardware pins, sensors, and peripherals correctly."*
    - Explain how to configure the local `platformio.ini` to extend the global settings and tweak sketch-level environment variables.
    - Keep code moduler, allow headers defined separately, use header file for defining pins and variables

Please output the complete, copy-pasteable directory tree structure, the full script code with robust error handling, the ini configuration templates, and the markdown files.