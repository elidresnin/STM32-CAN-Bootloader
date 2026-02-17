# Contributing to STM32-CAN-Bootloader

Thank you for your interest in contributing to the STM32-CAN-Bootloader project!

## Development Environment Setup

Before contributing, please set up your development environment:

- **macOS**: Follow [SETUP_MAC.md](SETUP_MAC.md)
- **Windows/Linux**: See README.md for setup instructions
- **Quick Start**: See [QUICK_START.md](QUICK_START.md) for common tasks

## Working with STM32CubeMX

This project uses STM32CubeMX for hardware configuration. When making changes to peripheral configurations:

### Making Configuration Changes

1. Open `CAN-Bootloader-TEST.ioc` in STM32CubeMX
2. Make your configuration changes (GPIO, peripherals, clocks, etc.)
3. Before generating code, verify these settings:
   - **Project Manager → Project → Toolchain/IDE**: Should be set to "Makefile"
   - **Project Manager → Code Generator → Generated files**: Check "Generate peripheral initialization as a pair of '.c/.h' files per peripheral"
   - **Project Manager → Code Generator**: Check "Keep User Code when re-generating"

4. Click "Generate Code" (or press `Alt+K`)

### Protecting Your Custom Code

STM32CubeMX will preserve code between these special markers:

```c
/* USER CODE BEGIN 0 */
// Your custom code here - this will be preserved
/* USER CODE END 0 */
```

Always place custom code within these markers. Code outside these markers may be overwritten when regenerating.

### After Regenerating Code

1. Review the changes STM32CubeMX made:
   ```bash
   git status
   git diff
   ```

2. Test that the project still builds:
   ```bash
   make clean
   make
   ```

3. Commit the changes with a clear message:
   ```bash
   git add .
   git commit -m "Update STM32CubeMX config: Add UART2 peripheral"
   ```

## Code Style Guidelines

### C Code Style

- Use STM32 HAL naming conventions
- Follow the existing code style in the project
- Use meaningful variable and function names
- Comment complex logic
- Keep functions focused and short

### Example:
```c
/**
 * @brief Handles CAN receive interrupt
 * @param hcan Pointer to CAN handle structure
 * @retval None
 */
void HAL_CAN_RxFifo0MsgPendingCallback(CAN_HandleTypeDef *hcan) {
    /* USER CODE BEGIN CAN_RX_HANDLER */
    CAN_RxHeaderTypeDef rxHeader;
    uint8_t rxData[8];
    
    // Get the message
    if (HAL_CAN_GetRxMessage(hcan, CAN_RX_FIFO0, &rxHeader, rxData) == HAL_OK) {
        // Process the message
        ProcessCANMessage(&rxHeader, rxData);
    }
    /* USER CODE END CAN_RX_HANDLER */
}
```

### Git Commit Messages

Write clear, descriptive commit messages:

```
Good:
✓ "Add UART2 support for debug logging"
✓ "Fix memory leak in flash write function"
✓ "Update CAN baud rate to 500kbps"

Bad:
✗ "fixed bug"
✗ "update"
✗ "changes"
```

## Testing Your Changes

### Build Testing

Always test that your changes build successfully:

```bash
# Clean build
make clean && make

# Check for warnings
make 2>&1 | grep -i warning
```

### Functional Testing

1. Flash the bootloader to hardware
2. Test basic bootloader functionality:
   - Device boots and initializes
   - CAN communication works
   - Flash operations succeed
   - Application jump works

3. Test your specific changes thoroughly

### Testing on macOS

If you're developing on macOS:

1. Ensure the project builds with the macOS toolchain
2. Test flashing with your ST-Link
3. Verify OpenOCD connectivity
4. Test the Python flash scripts if modified

## Pull Request Process

1. **Fork the repository** (if you don't have write access)

2. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes** and commit them with clear messages

4. **Test thoroughly** - both build and functional tests

5. **Update documentation** if you've changed functionality:
   - Update README.md if needed
   - Update SETUP_MAC.md for macOS-specific changes
   - Add comments to complex code

6. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create a Pull Request** with:
   - Clear title describing the change
   - Detailed description of what changed and why
   - Steps to test the changes
   - Any breaking changes or migration notes

## Common Development Tasks

### Adding a New Peripheral

1. Open STM32CubeMX and configure the peripheral
2. Generate code
3. Add initialization in appropriate USER CODE sections
4. Add necessary driver code in bootloader.c or new files
5. Update documentation
6. Test thoroughly

### Modifying the Bootloader Protocol

1. Update the protocol definitions in bootloader.h
2. Implement the changes in bootloader.c
3. Update the Python flash scripts if needed
4. Update the README.md protocol documentation
5. Test with real hardware and CAN bus

### Changing Memory Layout

⚠️ **Warning**: Memory layout changes require careful coordination with applications!

1. Update STM32L432XX_FLASH.ld
2. Update #defines in bootloader code
3. Update README.md memory layout section
4. Document migration path for existing applications
5. Test that bootloader fits in new region
6. Verify applications can still run

## Project Structure

```
STM32-CAN-Bootloader/
├── Core/
│   ├── Inc/                 # Header files
│   │   ├── main.h          # Main application header
│   │   ├── bootloader.h    # Bootloader definitions
│   │   └── ...
│   └── Src/                # Source files
│       ├── main.c          # Main initialization
│       ├── bootloader.c    # Bootloader implementation
│       └── ...
├── Drivers/                 # STM32 HAL and CMSIS
├── .vscode/                # VSCode configuration
├── build/                  # Build output (not in git)
├── *.py                    # Python flash scripts
├── Makefile                # Build system
├── *.ioc                   # STM32CubeMX project
└── *.md                    # Documentation
```

## Getting Help

If you need help:

1. Check existing documentation (README.md, SETUP_MAC.md, QUICK_START.md)
2. Look at existing code for examples
3. Search existing issues on GitHub
4. Create a new issue with:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - Your environment (OS, toolchain versions, etc.)

## Code of Conduct

- Be respectful and professional
- Help others learn and grow
- Provide constructive feedback
- Focus on the code, not the person

## License

By contributing to this project, you agree that your contributions will be licensed under the same license as the project.

## Recognition

Contributors will be acknowledged in the project. Thank you for helping improve the STM32-CAN-Bootloader!
