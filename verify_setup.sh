#!/bin/bash
# 
# STM32-CAN-Bootloader Setup Verification Script
# This script checks if all required tools are installed and properly configured
# for macOS development with STM32CubeMX and VSCode
#

echo "=========================================="
echo "STM32-CAN-Bootloader Setup Verification"
echo "=========================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track overall status
ALL_OK=true

# Helper function to check if a command exists
check_command() {
    local cmd=$1
    local name=$2
    local install_hint=$3
    
    echo -n "Checking for $name... "
    if command -v "$cmd" &> /dev/null; then
        version=$($cmd --version 2>&1 | head -n 1)
        echo -e "${GREEN}✓ Found${NC} ($version)"
        return 0
    else
        echo -e "${RED}✗ Not found${NC}"
        if [ -n "$install_hint" ]; then
            echo "  → Install with: $install_hint"
        fi
        ALL_OK=false
        return 1
    fi
}

# Helper function to check if a file exists
check_file() {
    local file=$1
    local name=$2
    
    echo -n "Checking for $name... "
    if [ -f "$file" ] || [ -d "$file" ]; then
        echo -e "${GREEN}✓ Found${NC} ($file)"
        return 0
    else
        echo -e "${YELLOW}⚠ Not found${NC} ($file)"
        return 1
    fi
}

echo "1. Core Development Tools"
echo "-------------------------"
check_command "make" "Make" "xcode-select --install"
check_command "git" "Git" "xcode-select --install"
check_command "python3" "Python 3" "brew install python3"
check_command "pip3" "pip3" "brew install python3"
echo ""

echo "2. ARM Toolchain"
echo "----------------"
check_command "arm-none-eabi-gcc" "ARM GCC Compiler" "brew install --cask gcc-arm-embedded"
if command -v arm-none-eabi-gcc &> /dev/null; then
    check_command "arm-none-eabi-gdb" "ARM GDB Debugger"
    check_command "arm-none-eabi-objcopy" "ARM objcopy"
    check_command "arm-none-eabi-size" "ARM size utility"
fi
echo ""

echo "3. OpenOCD (for flashing/debugging)"
echo "------------------------------------"
check_command "openocd" "OpenOCD" "brew install openocd"
echo ""

echo "4. STM32CubeMX"
echo "--------------"
if [ -d "/Applications/STMicroelectronics/STM32CubeMX.app" ]; then
    echo -e "Checking for STM32CubeMX... ${GREEN}✓ Found${NC} (/Applications/STMicroelectronics/STM32CubeMX.app)"
elif [ -d "$HOME/STMicroelectronics/STM32CubeMX.app" ]; then
    echo -e "Checking for STM32CubeMX... ${GREEN}✓ Found${NC} ($HOME/STMicroelectronics/STM32CubeMX.app)"
else
    echo -e "Checking for STM32CubeMX... ${YELLOW}⚠ Not found${NC}"
    echo "  → Download from: https://www.st.com/en/development-tools/stm32cubemx.html"
fi
echo ""

echo "5. Python Packages"
echo "------------------"
echo -n "Checking for python-can... "
if python3 -c "import can" 2>/dev/null; then
    echo -e "${GREEN}✓ Installed${NC}"
else
    echo -e "${RED}✗ Not installed${NC}"
    echo "  → Install with: pip3 install python-can"
    ALL_OK=false
fi
echo ""

echo "6. VSCode Setup"
echo "---------------"
check_file ".vscode/c_cpp_properties.json" "C/C++ Properties"
check_file ".vscode/tasks.json" "Build Tasks"
check_file ".vscode/launch.json" "Debug Configuration"
check_file ".vscode/extensions.json" "Extension Recommendations"
echo ""

echo "7. Project Files"
echo "----------------"
check_file "Makefile" "Makefile"
check_file "STM32-for-VSCode.config.yaml" "STM32 for VSCode Config"
check_file "openocd.cfg" "OpenOCD Configuration"
check_file "CAN-Bootloader-TEST.ioc" "STM32CubeMX Project"
echo ""

echo "8. Build Test"
echo "-------------"
if command -v arm-none-eabi-gcc &> /dev/null && command -v make &> /dev/null; then
    echo "Attempting to build project..."
    if make clean > /dev/null 2>&1 && make > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Build successful!${NC}"
        if [ -f "build/CAN-Bootloader-TEST.elf" ]; then
            size=$(ls -lh build/CAN-Bootloader-TEST.elf | awk '{print $5}')
            echo "  → Binary size: $size"
            arm-none-eabi-size build/CAN-Bootloader-TEST.elf
        fi
    else
        echo -e "${RED}✗ Build failed${NC}"
        echo "  → Run 'make' to see detailed error messages"
        ALL_OK=false
    fi
else
    echo -e "${YELLOW}⚠ Skipping build test (missing toolchain)${NC}"
fi
echo ""

echo "=========================================="
if [ "$ALL_OK" = true ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "Your environment is ready for STM32 development."
    echo "See QUICK_START.md for next steps."
else
    echo -e "${YELLOW}⚠ Some checks failed${NC}"
    echo ""
    echo "Please install the missing tools listed above."
    echo "See SETUP_MAC.md for detailed installation instructions."
fi
echo "=========================================="
