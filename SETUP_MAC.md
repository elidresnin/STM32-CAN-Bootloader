# macOS Setup Guide for STM32-CAN-Bootloader

This guide will help you set up the STM32-CAN-Bootloader development environment on macOS using Visual Studio Code and STM32CubeMX.

## Quick Verification

After completing the setup, you can verify your installation by running:

```bash
chmod +x verify_setup.sh
./verify_setup.sh
```

This script will check all required tools and configurations.

## Prerequisites

- macOS (10.15 Catalina or later recommended)
- [Homebrew](https://brew.sh/) package manager
- Visual Studio Code

## Installation Steps

### 1. Install Homebrew (if not already installed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install ARM GCC Toolchain

The ARM GCC toolchain is required to compile code for STM32 microcontrollers.

```bash
brew install --cask gcc-arm-embedded
```

Alternatively, you can use the ARM official distribution:

```bash
# Download from: https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads
# Or install via Homebrew tap
brew tap osx-cross/arm
brew install arm-gcc-bin
```

After installation, verify the installation:

```bash
arm-none-eabi-gcc --version
```

### 3. Install OpenOCD

OpenOCD is used for flashing and debugging STM32 microcontrollers.

```bash
brew install openocd
```

Verify installation:

```bash
openocd --version
```

### 4. Install STM32CubeMX

1. Download STM32CubeMX from [ST's website](https://www.st.com/en/development-tools/stm32cubemx.html)
2. You may need to create a free ST account
3. Download the macOS version (`.zip` file)
4. Extract the archive and run the installer
5. Follow the installation wizard
6. The default installation path is usually `/Applications/STMicroelectronics/STM32CubeMX.app`

Alternatively, you can install via Homebrew Cask (if available):

```bash
# Check if available in homebrew cask
brew search stm32cubemx
```

### 5. Install Make

macOS comes with `make`, but you may need to install Xcode Command Line Tools:

```bash
xcode-select --install
```

Verify make is installed:

```bash
make --version
```

### 6. Install Visual Studio Code

Download and install VS Code from [code.visualstudio.com](https://code.visualstudio.com/)

Or install via Homebrew:

```bash
brew install --cask visual-studio-code
```

### 7. Install VS Code Extensions

Install the following extensions in VS Code:

#### Required Extensions:
1. **STM32 for VSCode** (by bmd)
   - Command Palette → Extensions: Install Extensions
   - Search for "STM32 for VSCode"
   - Click Install

2. **C/C++** (by Microsoft)
   - Provides IntelliSense, debugging, and code browsing

3. **Cortex-Debug** (by marus25)
   - ARM Cortex-M debugging support

#### Recommended Extensions:
4. **Better C++ Syntax** (by Jeff Hykin)
5. **C/C++ Themes** (by Microsoft)
6. **ARM Assembly** (by dan-c-underwood)

You can install all required extensions at once if you have the `.vscode/extensions.json` file (included in this repo).

### 8. Install Python and CAN Tools (for flashing)

The bootloader comes with Python scripts for flashing over CAN bus.

```bash
# Install Python 3
brew install python3

# Install required Python packages
pip3 install python-can
```

For PCAN-USB adapter support on macOS:
```bash
# Download PCAN drivers from PEAK System:
# https://www.peak-system.com/fileadmin/media/files/pcanbasic.dmg
```

For CANable adapter (SocketCAN):
```bash
# CANable uses slcand - install can-utils
brew install can-utils
```

## Configuration

### Verify Your Setup

Before continuing, run the verification script to check your installation:

```bash
chmod +x verify_setup.sh
./verify_setup.sh
```

This will verify that all tools are installed correctly and in your PATH.

### 1. Update Paths in VSCode Settings

The `.vscode/c_cpp_properties.json` file needs to be updated with your Mac-specific paths. This repository includes a Mac configuration, but you may need to adjust paths based on your installation.

Typical ARM GCC path on macOS (Homebrew):
```
/opt/homebrew/bin/arm-none-eabi-gcc  (Apple Silicon M1/M2/M3/M4)
/usr/local/bin/arm-none-eabi-gcc     (Intel Mac)
```

The included Mac configuration uses the Apple Silicon path (`/opt/homebrew/bin/arm-none-eabi-gcc`). If you're on an Intel Mac, you may need to update this in `.vscode/c_cpp_properties.json`.

### 2. Configure the STM32 for VSCode Extension

1. Open the project in VS Code
2. The extension should auto-detect the `STM32-for-VSCode.config.yaml` file
3. If needed, update toolchain paths in the extension settings:
   - Press `Cmd+Shift+P` → "Preferences: Open Settings (UI)"
   - Search for "STM32"
   - Update paths if necessary

### 3. Build the Project

You can build the project using:

1. **VS Code Task**: Press `Cmd+Shift+B` and select "Build STM"
2. **Command Palette**: `Cmd+Shift+P` → "STM32: Build Project"
3. **Terminal**: `make` in the project root directory

```bash
cd /path/to/STM32-CAN-Bootloader
make clean
make
```

Successful build will create:
- `build/CAN-Bootloader-TEST.elf`
- `build/CAN-Bootloader-TEST.bin`
- `build/CAN-Bootloader-TEST.hex`

## Hardware Setup

### ST-Link Debugger

1. Connect your ST-Link debugger to the STM32L432 board
2. Connect the debugger to your Mac via USB
3. macOS should recognize the device automatically

### Debugging

1. Open the project in VS Code
2. Set breakpoints in your code
3. Press `F5` or go to Run → Start Debugging
4. Select "Debug STM32" configuration

The debugger uses OpenOCD and should connect automatically if your ST-Link is properly connected.

## Flashing Over CAN Bus

To use the Python scripts for flashing over CAN:

```bash
# For PCAN-USB adapter
python3 Flash_Application.py --interface pcan --channel PCAN_USBBUS1 --app your_app.bin

# For CANable adapter
python3 Flash_Application.py --interface socketcan --channel can0 --app your_app.bin
```

## Troubleshooting

### Issue: arm-none-eabi-gcc not found

**Solution**: Add the toolchain to your PATH:

```bash
# For Apple Silicon (M1/M2)
export PATH="/opt/homebrew/bin:$PATH"

# For Intel Mac
export PATH="/usr/local/bin:$PATH"

# Add to ~/.zshrc or ~/.bash_profile to make permanent
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
```

### Issue: OpenOCD can't find ST-Link

**Solution**: Check USB permissions and device connection:

```bash
# List USB devices
system_profiler SPUSBDataType

# Try running OpenOCD with sudo (not recommended for regular use)
sudo openocd -f openocd.cfg
```

### Issue: STM32CubeMX doesn't open

**Solution**: macOS may block the app due to security settings:

1. Go to System Preferences → Security & Privacy
2. Click "Open Anyway" for STM32CubeMX
3. Or run: `xattr -cr /Applications/STMicroelectronics/STM32CubeMX.app`

### Issue: Build fails with "file not found" errors

**Solution**: Ensure all paths use forward slashes and are relative to project root. The Makefile should work cross-platform.

### Issue: Permission denied when accessing serial ports

**Solution**: Add your user to the dialout group equivalent on macOS:

```bash
# Check which group owns the device
ls -l /dev/cu.*

# Usually no group changes needed on macOS, but you may need to install drivers
```

## Using STM32CubeMX with this Project

1. Open STM32CubeMX
2. Load the `.ioc` file: `File → Load Project → CAN-Bootloader-TEST.ioc`
3. Make your configuration changes
4. Generate code: `Project → Generate Code`
5. Choose "Makefile" as the toolchain in project settings
6. STM32CubeMX will update the Makefile and source files
7. Rebuild in VS Code

**Important**: STM32CubeMX may overwrite custom code between `USER CODE BEGIN` and `USER CODE END` comments if you're not careful. Always use these markers to protect your code.

## Tips for macOS Development

1. **Use Terminal within VS Code**: Press `` Ctrl+` `` to open integrated terminal
2. **File paths**: macOS uses forward slashes `/` like Linux
3. **Case sensitivity**: By default, macOS file system is case-insensitive but case-preserving
4. **USB drivers**: Most USB-Serial adapters work out of the box on macOS
5. **Python**: Use `python3` and `pip3` explicitly (macOS may have Python 2 as `python`)

## Additional Resources

- [STM32CubeMX User Manual](https://www.st.com/resource/en/user_manual/um1718-stm32cubemx-for-stm32-configuration-and-initialization-c-code-generation-stmicroelectronics.pdf)
- [ARM GCC Toolchain Documentation](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm)
- [OpenOCD Documentation](http://openocd.org/doc/html/index.html)
- [STM32 for VSCode Extension](https://marketplace.visualstudio.com/items?itemName=bmd.stm32-for-vscode)
- [Python-CAN Documentation](https://python-can.readthedocs.io/)

## Next Steps

After setting up your environment:

1. Read the main [README.md](README.md) for bootloader usage
2. Build the bootloader: `make`
3. Flash to your STM32 device using ST-Link
4. Test CAN communication with the Python scripts
5. Start developing your application firmware

For application development with this bootloader, refer to the "Application Development" section in the main README.
