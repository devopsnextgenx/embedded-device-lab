#!/bin/bash

#############################################################################
# Embedded Device Lab Master Management Script
# Purpose: Orchestrate PlatformIO build, upload, monitor, and diagnostics
#          for multi-board, multi-sketch embedded systems projects
#
# Author: Embedded Device Lab Team
# Version: 1.0.0
#
# Usage: ./lab-manager.sh
#
# Features:
#   - Dynamic board and sketch discovery
#   - Interactive build/upload/monitor workflow
#   - Hardware diagnostics and USB permission fixing
#   - udev rules generation and installation
#   - Robust error handling and logging
#############################################################################

set -o pipefail
IFS=$'\n\t'

# ANSI color codes for terminal output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Directories
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(dirname "${SCRIPT_DIR}")"
readonly BOARDS_DIR="${REPO_ROOT}/boards"
readonly UDEV_RULES_DIR="/etc/udev/rules.d"
readonly UDEV_RULES_FILE="99-embedded-device-lab.rules"

# Global variables
SELECTED_BOARD=""
SELECTED_SKETCH=""
SELECTED_BAUD_RATE=115200

#############################################################################
# Utility Functions
#############################################################################

##
# Print formatted header with color
##
print_header() {
  echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

##
# Print success message
##
print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

##
# Print warning message
##
print_warning() {
  echo -e "${YELLOW}⚠ $1${NC}"
}

##
# Print error message
##
print_error() {
  echo -e "${RED}✗ $1${NC}" >&2
}

##
# Print info message
##
print_info() {
  echo -e "${CYAN}ℹ $1${NC}"
}

##
# Exit with error
##
exit_error() {
  print_error "$1"
  exit 1
}

##
# Wait for user to continue
##
press_continue() {
  echo -e "\n${MAGENTA}Press Enter to continue...${NC}"
  read -r
}

##
# Verify PlatformIO is installed
##
check_platformio() {
  if ! command -v pio &> /dev/null; then
    exit_error "PlatformIO CLI is not installed. Please install it with: pip install platformio"
  fi
  print_success "PlatformIO CLI found: $(pio --version)"
}

##
# Verify we're in the embedded-device-lab root directory
##
verify_repo_root() {
  if [[ ! -d "${BOARDS_DIR}" ]]; then
    exit_error "boards/ directory not found. Are you in the embedded-device-lab root directory?"
  fi
  print_info "Repository root: ${REPO_ROOT}"
}

##
# Detect host OS for platform-specific serial handling
##
get_host_os() {
  case "$(uname -s 2>/dev/null || echo unknown)" in
    Linux*) echo "linux" ;;
    Darwin*) echo "macos" ;;
    MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
    *)
      if [[ "${OS:-}" == "Windows_NT" ]]; then
        echo "windows"
      else
        echo "unknown"
      fi
      ;;
  esac
}

##
# Return discovered serial devices for current OS
##
get_serial_devices() {
  local os
  os="$(get_host_os)"

  case "${os}" in
    linux)
      compgen -G '/dev/ttyUSB*' 2>/dev/null
      compgen -G '/dev/ttyACM*' 2>/dev/null
      ;;
    macos)
      compgen -G '/dev/tty.usb*' 2>/dev/null
      compgen -G '/dev/cu.usb*' 2>/dev/null
      ;;
    windows)
      if command -v powershell.exe &> /dev/null; then
        powershell.exe -NoProfile -Command "[System.IO.Ports.SerialPort]::GetPortNames()" 2>/dev/null \
          | tr -d '\r' \
          | grep -E '^COM[0-9]+$' || true
      fi
      ;;
  esac
}

#############################################################################
# Board & Sketch Discovery
#############################################################################

##
# List all available boards
# Returns: Array of board names
##
get_available_boards() {
  local boards=()
  if [[ -d "${BOARDS_DIR}" ]]; then
    while IFS= read -r board_dir; do
      local board_name=$(basename "${board_dir}")
      if [[ -f "${board_dir}/platformio.ini" ]]; then
        boards+=("${board_name}")
      fi
    done < <(find "${BOARDS_DIR}" -maxdepth 1 -type d ! -name "boards")
  fi
  printf '%s\n' "${boards[@]}"
}

##
# List all available sketches for a given board
# Arguments: board_name
# Returns: Array of sketch names
##
get_available_sketches() {
  local board_name="$1"
  local board_path="${BOARDS_DIR}/${board_name}"
  local sketches_dir="${board_path}/sketches"
  local sketches=()
  
  if [[ -d "${sketches_dir}" ]]; then
    while IFS= read -r sketch_dir; do
      local sketch_name=$(basename "${sketch_dir}")
      if [[ -f "${sketch_dir}/platformio.ini" ]]; then
        sketches+=("${sketch_name}")
      fi
    done < <(find "${sketches_dir}" -maxdepth 1 -type d ! -name "sketches")
  fi
  printf '%s\n' "${sketches[@]}"
}

##
# Display board selection menu
##
select_board() {
  print_header "Available Boards"
  
  local boards=($(get_available_boards))
  
  if [[ ${#boards[@]} -eq 0 ]]; then
    exit_error "No boards found in ${BOARDS_DIR}"
  fi
  
  # Display numbered menu
  local idx=1
  for board in "${boards[@]}"; do
    echo "  $idx) $board"
    ((idx++))
  done
  
  echo -e "\n${MAGENTA}Enter board number (1-${#boards[@]}): ${NC}" | tr -d '\n'
  read -r board_choice
  
  # Validate choice
  if ! [[ "${board_choice}" =~ ^[0-9]+$ ]] || [[ ${board_choice} -lt 1 ]] || [[ ${board_choice} -gt ${#boards[@]} ]]; then
    print_error "Invalid selection: $board_choice"
    select_board
    return
  fi
  
  SELECTED_BOARD="${boards[$((board_choice - 1))]}"
  print_success "Selected board: ${SELECTED_BOARD}"
}

##
# Display sketch selection menu
##
select_sketch() {
  print_header "Available Sketches for ${SELECTED_BOARD}"
  
  local sketches=($(get_available_sketches "${SELECTED_BOARD}"))
  
  if [[ ${#sketches[@]} -eq 0 ]]; then
    exit_error "No sketches found for board: ${SELECTED_BOARD}"
  fi
  
  # Display numbered menu
  local idx=1
  for sketch in "${sketches[@]}"; do
    echo "  $idx) $sketch"
    ((idx++))
  done
  
  echo -e "\n${MAGENTA}Enter sketch number (1-${#sketches[@]}): ${NC}" | tr -d '\n'
  read -r sketch_choice
  
  # Validate choice
  if ! [[ "${sketch_choice}" =~ ^[0-9]+$ ]] || [[ ${sketch_choice} -lt 1 ]] || [[ ${sketch_choice} -gt ${#sketches[@]} ]]; then
    print_error "Invalid selection: $sketch_choice"
    select_sketch
    return
  fi
  
  SELECTED_SKETCH="${sketches[$((sketch_choice - 1))]}"
  print_success "Selected sketch: ${SELECTED_SKETCH}"
}

#############################################################################
# Build & Upload Operations
#############################################################################

##
# Get the full path to the selected sketch
##
get_sketch_path() {
  echo "${BOARDS_DIR}/${SELECTED_BOARD}/sketches/${SELECTED_SKETCH}"
}

##
# Build (compile) the selected sketch
##
build_sketch() {
  print_header "Building: ${SELECTED_BOARD}/${SELECTED_SKETCH}"
  
  local sketch_path=$(get_sketch_path)
  cd "${sketch_path}" || exit_error "Failed to change directory to ${sketch_path}"
  
  print_info "Compiling sketch..."
  print_info "Running: pio run (in ${sketch_path})"
  if pio run; then
    print_success "Build completed successfully"
  else
    print_error "Build failed"
    return 1
  fi
  
  press_continue
}

##
# Upload sketch to device
##
upload_sketch() {
  print_header "Uploading: ${SELECTED_BOARD}/${SELECTED_SKETCH}"
  
  local sketch_path=$(get_sketch_path)
  cd "${sketch_path}" || exit_error "Failed to change directory to ${sketch_path}"

  # Check for connected serial device in an OS-aware way
  local serial_devices=()
  mapfile -t serial_devices < <(get_serial_devices)
  if [[ ${#serial_devices[@]} -eq 0 ]]; then
    print_warning "No serial device detected. Ensure your board is connected."
  else
    print_info "Detected serial device(s): ${serial_devices[*]}"
  fi
  
  print_info "Uploading firmware..."
  print_info "Running: pio run --target upload (in ${sketch_path})"
  if pio run --target upload; then
    print_success "Upload completed successfully"
  else
    print_error "Upload failed"
    return 1
  fi
  
  press_continue
}

##
# Open serial monitor for the selected sketch
##
open_monitor() {
  print_header "Serial Monitor: ${SELECTED_BOARD}/${SELECTED_SKETCH}"

  local sketch_path
  sketch_path=$(get_sketch_path)
  local sketch_ini="${sketch_path}/platformio.ini"
  local default_baud_rate="115200"

  if [[ -f "${sketch_ini}" ]]; then
    local detected_baud
    detected_baud=$(sed -nE 's/^[[:space:]]*monitor_speed[[:space:]]*=[[:space:]]*([0-9]+).*/\1/p' "${sketch_ini}" | head -n 1)
    if [[ -n "${detected_baud}" ]]; then
      default_baud_rate="${detected_baud}"
    fi
  fi
  
  echo -e "\n${MAGENTA}Available Baud Rates:${NC}"
  local baud_rates=(9600 14400 19200 38400 57600 115200 230400 460800 921600)
  local idx=1
  local default_choice=""
  for rate in "${baud_rates[@]}"; do
    if [[ "${rate}" == "${default_baud_rate}" ]]; then
      default_choice="${idx}"
      echo "  $idx) $rate (from platformio.ini)"
    else
      echo "  $idx) $rate"
    fi
    ((idx++))
  done
  echo "  $idx) Other (custom)"

  if [[ -z "${default_choice}" ]]; then
    default_choice="${idx}"
  fi
  
  echo -e "\n${MAGENTA}Enter baud rate choice (1-${#baud_rates[@]} or 'other') [default: ${default_baud_rate}]: ${NC}" | tr -d '\n'
  read -r baud_choice

  if [[ -z "${baud_choice}" ]]; then
    baud_choice="${default_choice}"
  fi
  
  if [[ "${baud_choice}" == "other" ]] || [[ "${baud_choice}" -eq $((${#baud_rates[@]} + 1)) ]]; then
    echo -e "${MAGENTA}Enter custom baud rate [default: ${default_baud_rate}]: ${NC}" | tr -d '\n'
    read -r SELECTED_BAUD_RATE
    if [[ -z "${SELECTED_BAUD_RATE}" ]]; then
      SELECTED_BAUD_RATE="${default_baud_rate}"
    fi
  elif [[ "${baud_choice}" =~ ^[0-9]+$ ]] && [[ ${baud_choice} -ge 1 ]] && [[ ${baud_choice} -le ${#baud_rates[@]} ]]; then
    SELECTED_BAUD_RATE="${baud_rates[$((baud_choice - 1))]}"
  else
    print_error "Invalid choice: $baud_choice"
    open_monitor
    return
  fi
  
  print_success "Opening serial monitor at ${SELECTED_BAUD_RATE} baud"
  print_info "Press Ctrl+C to exit monitor"
  
  cd "${sketch_path}" || exit_error "Failed to change directory to ${sketch_path}"
  
  print_info "Running: pio device monitor --baud ${SELECTED_BAUD_RATE} (in ${sketch_path})"
  pio device monitor --baud "${SELECTED_BAUD_RATE}"
}

#############################################################################
# Processing Dashboard
#############################################################################

##
# Locate the processing-java launcher on the current OS
# Prints the path if found, or empty string if not found
##
find_processing_java() {
  local os
  os="$(get_host_os)"

  # 1. Already on PATH?
  if command -v processing-java &> /dev/null; then
    command -v processing-java
    return 0
  fi

  case "${os}" in
    linux)
      # Common Linux install locations
      local candidates=(
        "/usr/local/bin/processing-java"
        "/opt/processing/processing-java"
        "${HOME}/processing/processing-java"
        "${HOME}/Downloads/processing-*/processing-java"
      )
      for c in "${candidates[@]}"; do
        # Expand globs
        for path in ${c}; do
          if [[ -x "${path}" ]]; then
            echo "${path}"
            return 0
          fi
        done
      done
      ;;
    macos)
      local mac_candidates=(
        "/Applications/Processing.app/Contents/MacOS/processing-java"
        "/Applications/Processing 4.app/Contents/MacOS/processing-java"
      )
      for c in "${mac_candidates[@]}"; do
        if [[ -x "${c}" ]]; then
          echo "${c}"
          return 0
        fi
      done
      ;;
    windows)
      # Look for processing-java.exe via PowerShell PATH search or common locations
      if command -v powershell.exe &> /dev/null; then
        local win_path
        win_path=$(powershell.exe -NoProfile -Command "
          \$candidates = @(
            'processing-java.exe',
            'C:\\Program Files\\Processing\\bin\\processing-java.exe',
            'C:\\Program Files\\Processing\\processing-java.exe',
            'C:\\Program Files\\Processing\\processing.exe',
            'C:\\Program Files (x86)\\Processing\\bin\\processing-java.exe',
            'C:\\Program Files (x86)\\Processing\\processing-java.exe',
            \"\$env:LOCALAPPDATA\\Processing\\bin\\processing-java.exe\",
            \"\$env:LOCALAPPDATA\\Processing\\processing-java.exe\"
          )
          foreach (\$c in \$candidates) {
            if (Test-Path \$c) { Write-Output \$c; break }
          }
          \$found = Get-Command 'processing-java.exe' -ErrorAction SilentlyContinue
          if (\$found) { Write-Output \$found.Source }
        " 2>/dev/null | tr -d '\r' | head -n 1)
        if [[ -n "${win_path}" ]]; then
          echo "${win_path}"
          return 0
        fi
      fi
      ;;
  esac

  return 1
}

##
# Launch the Processing dashboard for the selected sketch
##
open_processing_dashboard() {
  print_header "Processing Dashboard: ${SELECTED_BOARD}/${SELECTED_SKETCH}"

  local sketch_path
  sketch_path=$(get_sketch_path)
  local dashboard_dir="${sketch_path}/dashboard"
  local pde_file="${dashboard_dir}/dashboard.pde"

  # Check dashboard exists
  if [[ ! -f "${pde_file}" ]]; then
    print_error "No dashboard found at: ${pde_file}"
    print_info "Create dashboard/dashboard.pde in the sketch directory first."
    press_continue
    return 1
  fi

  print_success "Dashboard sketch found: ${pde_file}"

  # Find processing-java
  local proc_java
  if ! proc_java=$(find_processing_java); then
    print_error "processing-java not found on this system."
    echo ""
    print_info "Install Processing from https://processing.org/download"
    
    local os
    os="$(get_host_os)"
    
    case "${os}" in
      windows)
        print_info "On Windows, processing-java is typically located at:"
        echo "  C:\\Program Files\\Processing\\bin\\processing-java.exe"
        echo ""
        echo "To make it available to this script:"
        echo "  1. Option A: Add Processing\\bin to your system PATH"
        echo "  2. Option B: Reinstall Processing with 'Add to PATH' option enabled"
        echo "  3. Option C: In Processing IDE → Tools → Install 'processing-java'"
        ;;
      macos)
        print_info "On macOS, processing-java is typically located at:"
        echo "  /Applications/Processing.app/Contents/MacOS/processing-java"
        echo ""
        print_info "Ensure 'processing-java' is on your PATH, or install it via:"
        echo "  Processing IDE → Tools → Install 'processing-java'"
        ;;
      linux)
        print_info "Then ensure 'processing-java' is on your PATH, or install it via:"
        echo "  Processing IDE → Tools → Install 'processing-java'"
        ;;
    esac
    
    echo ""
    print_info "Alternatively, open the dashboard manually in the Processing IDE:"
    echo "  ${pde_file}"
    press_continue
    return 1
  fi

  print_info "Using Processing launcher: ${proc_java}"
  print_info "Launching dashboard in run mode..."
  print_info "Close the Processing window to return here."
  echo ""

  # Launch Processing sketch (blocking until window closes)
  if "${proc_java}" --sketch="${dashboard_dir}" --run; then
    print_success "Dashboard closed."
  else
    local rc=$?
    # Exit code 1 can mean normal close on some Processing versions — don't treat as fatal
    if [[ ${rc} -ne 1 ]]; then
      print_error "Processing exited with code ${rc}"
    else
      print_success "Dashboard closed."
    fi
  fi

  press_continue
}

#############################################################################
# Hardware Diagnostics & USB Troubleshooting
#############################################################################

##
# List connected USB serial devices
##
list_usb_devices() {
  print_header "Connected USB Devices"

  local os
  os="$(get_host_os)"

  if command -v lsusb &> /dev/null; then
    echo -e "${CYAN}=== lsusb output ===${NC}"
    lsusb | grep -E "serial|USB|FTDI|CH340|CP210x|Prolific" || echo "No obvious serial devices found"
  else
    print_warning "lsusb not found, using alternative method"
  fi

  echo -e "\n${CYAN}=== Serial Devices (${os}) ===${NC}"
  local serial_devices=()
  mapfile -t serial_devices < <(get_serial_devices)

  if [[ ${#serial_devices[@]} -eq 0 ]]; then
    print_warning "No serial devices detected"
  else
    printf '%s\n' "${serial_devices[@]}"
  fi

  if [[ "${os}" == "linux" ]]; then
    echo -e "\n${CYAN}=== Recent dmesg USB Activity ===${NC}"
    if command -v dmesg &> /dev/null; then
      dmesg | tail -30 | grep -E "tty|USB|serial|usb" || echo "No recent USB activity in dmesg"
    else
      echo "dmesg not available"
    fi
  fi
}

##
# Check and display serial port permissions
##
check_serial_permissions() {
  print_header "Serial Port Permissions"

  local os
  os="$(get_host_os)"

  echo -e "${CYAN}=== Checking permission issues ===${NC}\n"

  local serial_devices=()
  mapfile -t serial_devices < <(get_serial_devices)

  if [[ ${#serial_devices[@]} -eq 0 ]]; then
    print_warning "No serial devices found"
    return
  fi

  if [[ "${os}" == "windows" ]]; then
    print_info "Windows COM ports detected:"
    printf '  - %s\n' "${serial_devices[@]}"
    print_info "Serial permissions are managed by Windows drivers and user policy, not chmod/chown."
    return
  fi

  if [[ "${os}" == "macos" ]]; then
    print_info "macOS serial devices detected:"
    printf '  - %s\n' "${serial_devices[@]}"
    print_info "If access is denied, check group membership and close apps using the port."
    return
  fi

  local current_user
  current_user=$(whoami)
  local has_issues=0

  for device in "${serial_devices[@]}"; do
    if [[ -c "${device}" ]]; then
      local perms
      local owner
      perms=$(stat -c '%A' "${device}" 2>/dev/null || stat -f '%OLp' "${device}" 2>/dev/null)
      owner=$(stat -c '%U:%G' "${device}" 2>/dev/null || stat -f '%Su:%Sg' "${device}" 2>/dev/null)

      echo -e "Device: ${CYAN}${device}${NC}"
      echo -e "  Permissions: ${perms}"
      echo -e "  Owner: ${owner}"

      if [[ ! -r "${device}" ]] || [[ ! -w "${device}" ]]; then
        print_error "  User '${current_user}' does NOT have read/write access"
        has_issues=1
      else
        print_success "  User '${current_user}' has read/write access"
      fi
      echo ""
    fi
  done

  if [[ ${has_issues} -eq 1 ]]; then
    echo -e "${YELLOW}=== Suggested Fixes ===${NC}"
    echo "1. Add user to dialout group: sudo usermod -a -G dialout $current_user"
    echo "2. Add user to plugdev group: sudo usermod -a -G plugdev $current_user"
    echo "3. Then log out and log back in for group changes to take effect"
    echo ""
  fi
}

##
# Attempt to fix USB permissions automatically
##
fix_usb_permissions() {
  print_header "Attempting to Fix USB Serial Permissions"

  local os
  os="$(get_host_os)"
  if [[ "${os}" != "linux" ]]; then
    print_warning "Automatic permission fix is only supported on Linux."
    print_info "Detected OS: ${os}"
    press_continue
    return
  fi

  local current_user
  current_user=$(whoami)
  local serial_devices=()
  mapfile -t serial_devices < <(get_serial_devices)

  if [[ ${#serial_devices[@]} -eq 0 ]]; then
    print_warning "No serial devices found. Connect your board and try again."
    return
  fi
  
  echo -e "${YELLOW}This operation requires sudo privileges.${NC}\n"
  
  # Option 1: Quick chmod (temporary until reboot)
  echo -e "${MAGENTA}Option 1: Temporary fix (chmod, until reboot):${NC}"
  read -p "Apply temporary permissions fix? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    for device in "${serial_devices[@]}"; do
      if [[ -c "${device}" ]]; then
        print_info "Fixing permissions on ${device}..."
        if sudo chmod 666 "${device}"; then
          print_success "Fixed ${device}"
        else
          print_error "Failed to fix ${device}"
        fi
      fi
    done
  fi
  
  echo ""
  
  # Option 2: Permanent fix (add to groups)
  echo -e "${MAGENTA}Option 2: Permanent fix (add user to groups):${NC}"
  read -p "Add user '${current_user}' to dialout and plugdev groups? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Adding ${current_user} to dialout group..."
    if sudo usermod -a -G dialout "${current_user}"; then
      print_success "Added to dialout group"
    else
      print_error "Failed to add to dialout group"
    fi
    
    print_info "Adding ${current_user} to plugdev group..."
    if sudo usermod -a -G plugdev "${current_user}"; then
      print_success "Added to plugdev group"
    else
      print_error "Failed to add to plugdev group"
    fi
    
    print_warning "Changes will take effect after you log out and log back in."
  fi
  
  press_continue
}

#############################################################################
# udev Rules Configuration
#############################################################################

##
# Generate standard udev rules for common microcontroller USB bridges
##
generate_udev_rules() {
  cat << 'EOF'
# Embedded Device Lab udev Rules
# Auto-generated rules for common microcontroller USB-to-Serial adapters
# Install to: /etc/udev/rules.d/99-embedded-device-lab.rules

# CH340 (WCH CH340)
SUBSYSTEMS=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE:="0666", SYMLINK+="embedded_ch340"

# CP210x (Silicon Labs)
SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE:="0666", SYMLINK+="embedded_cp210x"

# FTDI FT232
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", MODE:="0666", SYMLINK+="embedded_ftdi"

# Arduino Leonardo / Arduino Micro
SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="8036", MODE:="0666", SYMLINK+="embedded_arduino_leo"

# Arduino Uno
SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0043", MODE:="0666", SYMLINK+="embedded_arduino_uno"

# Arduino Mega
SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0010", MODE:="0666", SYMLINK+="embedded_arduino_mega"

# Generic USB CDC devices
SUBSYSTEMS=="usb", ATTRS{bInterfaceClass}=="02", ATTRS{bInterfaceSubClass}=="02", MODE:="0666", SYMLINK+="embedded_cdc"

# Prolific PL2303
SUBSYSTEMS=="usb", ATTRS{idVendor}=="067b", ATTRS{idProduct}=="2303", MODE:="0666", SYMLINK+="embedded_pl2303"

# Allow group access for users in dialout group
KERNEL=="ttyUSB[0-9]*", MODE="0666"
KERNEL=="ttyACM[0-9]*", MODE="0666"
EOF
}

##
# Display udev rules menu
##
configure_udev_rules() {
  print_header "Configure udev Rules for Automatic USB Access"
  
  echo -e "${MAGENTA}This will enable automatic access to USB serial devices without sudo.${NC}\n"
  
  if [[ -f "${UDEV_RULES_DIR}/${UDEV_RULES_FILE}" ]]; then
    print_success "udev rules already installed at ${UDEV_RULES_DIR}/${UDEV_RULES_FILE}"
    echo ""
    read -p "Reinstall/update rules? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      press_continue
      return
    fi
  fi
  
  echo -e "${YELLOW}This operation requires sudo privileges.${NC}\n"
  
  # Create temporary rules file
  local temp_rules=$(mktemp)
  generate_udev_rules > "${temp_rules}"
  
  print_info "Generated udev rules file..."
  echo ""
  
  # Show preview
  echo -e "${CYAN}=== Preview of rules (first 10 lines) ===${NC}"
  head -10 "${temp_rules}"
  echo "... (see full file in ${temp_rules})"
  echo ""
  
  read -p "Install these rules? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    rm "${temp_rules}"
    print_warning "Installation cancelled"
    press_continue
    return
  fi
  
  # Install rules
  print_info "Installing udev rules to ${UDEV_RULES_DIR}/${UDEV_RULES_FILE}..."
  if sudo cp "${temp_rules}" "${UDEV_RULES_DIR}/${UDEV_RULES_FILE}"; then
    print_success "Rules installed successfully"
    
    # Set permissions
    if sudo chmod 644 "${UDEV_RULES_DIR}/${UDEV_RULES_FILE}"; then
      print_success "Rules permissions set to 644"
    fi
    
    # Reload udev
    print_info "Reloading udev system..."
    if sudo udevadm control --reload-rules && sudo udevadm trigger; then
      print_success "udev rules reloaded and triggered"
      print_info "Disconnect and reconnect your USB device for changes to take effect"
    else
      print_error "Failed to reload udev rules"
    fi
  else
    print_error "Failed to install rules"
  fi
  
  rm -f "${temp_rules}"
  press_continue
}

##
# Display udev status
##
show_udev_status() {
  print_header "udev Rules Status"
  
  if [[ -f "${UDEV_RULES_DIR}/${UDEV_RULES_FILE}" ]]; then
    print_success "Rules file found at ${UDEV_RULES_DIR}/${UDEV_RULES_FILE}"
    echo ""
    echo -e "${CYAN}=== Current rules (first 15 lines) ===${NC}"
    head -15 "${UDEV_RULES_DIR}/${UDEV_RULES_FILE}"
  else
    print_warning "No udev rules file installed"
    echo "Run 'Configure Linux udev Rules' from the operations menu to install"
  fi
  
  press_continue
}

#############################################################################
# Main Operations Menu
#############################################################################

##
# Display operations menu and handle selections
##
operations_menu() {
  while true; do
    print_header "Operations: ${SELECTED_BOARD} / ${SELECTED_SKETCH}"
    
    echo "  1) Build (Compile)"
    echo "  2) Upload"
    echo "  3) Monitor (Serial Console)"
    echo "  4) Processing Dashboard"
    echo "  5) Hardware Diagnostics & USB Fix"
    echo "  6) Configure Linux udev Rules"
    echo "  7) Show udev Rules Status"
    echo "  8) Switch Sketch/Board"
    echo "  9) Exit"
    echo ""
    echo -e "${MAGENTA}Enter your choice (1-9): ${NC}" | tr -d '\n'
    read -r choice
    
    case "${choice}" in
      1)
        build_sketch
        ;;
      2)
        build_sketch && upload_sketch
        ;;
      3)
        open_monitor
        ;;
      4)
        open_processing_dashboard
        ;;
      5)
        list_usb_devices
        check_serial_permissions
        echo ""
        read -p "Attempt automatic fix? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
          fix_usb_permissions
        else
          press_continue
        fi
        ;;
      6)
        configure_udev_rules
        ;;
      7)
        show_udev_status
        ;;
      8)
        print_info "Returning to board selection..."
        main_menu
        return
        ;;
      9)
        print_success "Exiting Embedded Device Lab Manager"
        exit 0
        ;;
      *)
        print_error "Invalid choice: $choice"
        press_continue
        ;;
    esac
  done
}

##
# Main menu: Board and sketch selection, then operations
##
main_menu() {
  select_board
  select_sketch
  operations_menu
}

##
# Script entry point
##
main() {
  print_header "Embedded Device Lab - Master Management Script"
  print_info "Initializing environment..."
  
  # Verify setup
  verify_repo_root
  check_platformio
  
  # Main workflow
  main_menu
}

# Execute main function
main "$@"
