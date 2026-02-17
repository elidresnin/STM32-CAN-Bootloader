# Quick Start Guide

This is a quick reference for common development tasks with the STM32-CAN-Bootloader project.

## Prerequisites

Before you begin, make sure you've completed the setup for your platform:
- **macOS**: See [SETUP_MAC.md](SETUP_MAC.md)
- **Windows/Linux**: Install ARM GCC toolchain, Make, and OpenOCD

## Building the Project

### Option 1: Using VS Code (Recommended)

1. Open the project in VS Code
2. Press `Cmd+Shift+B` (macOS) or `Ctrl+Shift+B` (Windows/Linux)
3. Select "Build STM" from the task list
4. View build output in the terminal

### Option 2: Using Make (Command Line)

```bash
# Clean build
make clean

# Build the bootloader
make

# Build output will be in build/ directory:
# - build/CAN-Bootloader-TEST.elf (ELF file for debugging)
# - build/CAN-Bootloader-TEST.bin (Binary file for flashing)
# - build/CAN-Bootloader-TEST.hex (Hex file for flashing)
```

### Option 3: Using STM32 for VSCode Extension

1. Press `Cmd+Shift+P` (macOS) or `Ctrl+Shift+P` (Windows/Linux)
2. Type "STM32: Build Project"
3. Press Enter

## Flashing the Bootloader

### Using ST-Link Debugger

#### VS Code Method:
1. Connect ST-Link to your STM32L432 board
2. Connect ST-Link to your computer via USB
3. Press `F5` to build and flash
4. Debugging session will start automatically

#### Command Line Method:
```bash
# Build first
make

# Flash using OpenOCD
openocd -f openocd.cfg -c "program build/CAN-Bootloader-TEST.elf verify reset exit"
```

### Using STM32CubeProgrammer (Alternative)

1. Download and install [STM32CubeProgrammer](https://www.st.com/en/development-tools/stm32cubeprog.html)
2. Connect your ST-Link
3. Open STM32CubeProgrammer
4. Select ST-LINK connection
5. Click "Connect"
6. Load the `.bin` file from `build/CAN-Bootloader-TEST.bin`
7. Set the start address to `0x08000000`
8. Click "Download"

## Debugging

### Start Debugging Session

1. Set breakpoints in your code (click left of line numbers)
2. Press `F5` or Run → Start Debugging
3. Select "Debug STM32" configuration
4. Use debug controls:
   - `F10` - Step Over
   - `F11` - Step Into
   - `Shift+F11` - Step Out
   - `F5` - Continue
   - `Shift+F5` - Stop

### Attach to Running Device

1. Make sure device is powered and connected
2. Press `F5`
3. Select "Attach STM32" configuration

## Using STM32CubeMX

### Open the Project

```bash
# Open STM32CubeMX
# File → Load Project → Select CAN-Bootloader-TEST.ioc
```

### Making Configuration Changes

1. Load the `.ioc` file in STM32CubeMX
2. Make your changes (peripherals, clock configuration, etc.)
3. Project Manager → Project → Toolchain/IDE → "Makefile"
4. Generate Code
5. Review changes in VS Code
6. Rebuild: `make clean && make`

**Important**: STM32CubeMX may overwrite some files. Always use `USER CODE BEGIN` and `USER CODE END` markers to protect custom code.

## Flashing Applications via CAN

Once the bootloader is installed on your STM32, you can flash applications over CAN bus.

### Using PCAN-USB Adapter

```bash
python3 Flash_Application.py --interface pcan --channel PCAN_USBBUS1 --app your_app.bin
```

### Using CANable Adapter

```bash
# First, bring up the CAN interface (macOS/Linux)
sudo ip link set can0 type can bitrate 500000
sudo ip link set can0 up

# Flash the application
python3 Flash_Application.py --interface socketcan --channel can0 --app your_app.bin
```

## Common Issues and Solutions

### Build Fails: "arm-none-eabi-gcc: command not found"

**Solution**: ARM toolchain not in PATH. See platform-specific setup guide.

macOS:
```bash
# Add to ~/.zshrc or ~/.bash_profile
export PATH="/opt/homebrew/bin:$PATH"  # Apple Silicon
# or
export PATH="/usr/local/bin:$PATH"     # Intel Mac
```

### Flash Fails: "Error: couldn't bind tcl to socket"

**Solution**: OpenOCD already running or port in use.

```bash
# Kill existing OpenOCD processes
killall openocd

# Try again
openocd -f openocd.cfg
```

### ST-Link Not Detected

**macOS/Linux**:
```bash
# Check if device is visible
lsusb | grep -i stm

# Try running with sudo (not recommended for regular use)
sudo openocd -f openocd.cfg
```

**Windows**:
- Install ST-Link drivers from ST website
- Check Device Manager for ST-Link device

### Make Command Not Found (macOS)

```bash
# Install Xcode Command Line Tools
xcode-select --install
```

### Python Can't Find python-can Module

```bash
# Install python-can
pip3 install python-can

# If using CANable on Linux
sudo apt-get install can-utils
```

## Project Structure

```
STM32-CAN-Bootloader/
├── Core/
│   ├── Inc/              # Header files
│   └── Src/              # Source files
│       ├── main.c        # Main application
│       ├── bootloader.c  # Bootloader logic
│       └── ...
├── Drivers/              # STM32 HAL drivers
├── build/                # Build output (generated)
├── .vscode/              # VS Code configuration
├── Makefile              # Build configuration
├── STM32-for-VSCode.config.yaml  # STM32 extension config
├── openocd.cfg           # OpenOCD configuration
├── CAN-Bootloader-TEST.ioc       # STM32CubeMX project
├── Flash_Application.py  # CAN flash script
├── README.md             # Main documentation
├── SETUP_MAC.md          # macOS setup guide
└── QUICK_START.md        # This file
```

## Development Workflow

1. **Make code changes** in Core/Src/ or Core/Inc/
2. **Build**: Press `Cmd/Ctrl+Shift+B`
3. **Fix errors** if any appear
4. **Flash**: Press `F5` to flash and debug
5. **Test** your changes
6. **Commit** using git

## Tips

- Use `Cmd/Ctrl+P` to quickly open files by name
- Use `Cmd/Ctrl+Shift+F` to search across all files
- Use `Cmd/Ctrl+Click` on function names to jump to definition
- Enable "Auto Save" in VS Code for convenience
- Use the integrated terminal (`` Ctrl+` ``) for commands

## Next Steps

1. Read the full [README.md](README.md) for bootloader protocol details
2. Review the memory layout for application development
3. Study the CAN protocol message format
4. Create your first application with the correct linker script
5. Test firmware updates over CAN bus

## Additional Resources

- [STM32L432 Reference Manual](https://www.st.com/resource/en/reference_manual/rm0394-stm32l41xxx42xxx43xxx44xxx45xxx46xxx-advanced-armbased-32bit-mcus-stmicroelectronics.pdf)
- [STM32L432 Datasheet](https://www.st.com/resource/en/datasheet/stm32l432kc.pdf)
- [CAN Bus Protocol](https://en.wikipedia.org/wiki/CAN_bus)
- [ARM Cortex-M4 Programming](https://developer.arm.com/documentation/dui0553/latest/)
