# EnergyPlus DevContainer

This directory contains the development container configuration for building and debugging EnergyPlus.

## What's Included

### Development Tools
- **C/C++**: GCC 13, G++ 13, Clang 18 with C++17 support
- **Fortran**: gfortran-13 for building Fortran utilities
- **Build System**: CMake 3.28+, Ninja build system
- **Python**: Python 3.12 with development headers
- **Build Acceleration**: ccache configured with 5GB cache

### Debugging Tools
- **gdb**: GNU Debugger for C/C++/Fortran
- **valgrind**: Memory leak and profiling analysis
- **strace/ltrace**: System call tracing
- **Sanitizers**: Address, Undefined Behavior, Leak, Thread sanitizers available via CMake options

### Dependencies
- X11 and OpenGL libraries for graphics support
- All required system libraries (libxkbcommon, xorg-dev, mesa)
- Python testing and development packages (pytest, black, flake8)

## Quick Start

### 1. Open in DevContainer
In VS Code:
1. Install the "Dev Containers" extension
2. Press `F1` and select "Dev Containers: Reopen in Container"
3. Wait for the container to build (first time only, ~5-10 minutes)

### 2. Configure and Build

Using CMake Presets (recommended):
```bash
# Configure Debug build
cmake --preset debug

# Build
cmake --build build/debug -j$(nproc)

# Test
ctest --preset debug
```

Manual configuration:
```bash
# Configure
cmake -B build/Debug -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DBUILD_FORTRAN=ON \
  -DBUILD_TESTING=ON \
  -DLINK_WITH_PYTHON=ON \
  -DENABLE_PCH=ON

# Build
cmake --build build/Debug -j$(nproc)

# Test
cd build/Debug && ctest --output-on-failure
```

### 3. Run EnergyPlus
```bash
./build/debug/Products/energyplus --help

# Run with a test file
./build/debug/Products/energyplus \
  -w weather/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.epw \
  -d build/output \
  testfiles/1ZoneUncontrolled.idf
```

## Available CMake Presets

- **debug**: Standard debug build with symbols
- **debug-asan**: Debug with Address Sanitizer (memory errors)
- **debug-ubsan**: Debug with Undefined Behavior Sanitizer
- **release**: Optimized release build
- **relwithdebinfo**: Optimized with debug symbols (for profiling)

## Debugging

### Using VS Code Debugger
1. Set breakpoints in your code
2. Press `F5` or go to Run and Debug
3. Select a debug configuration:
   - "(gdb) Launch EnergyPlus" - Run with default arguments
   - "(gdb) Launch EnergyPlus with IDF" - Run with custom IDF file
   - "Python: Current File" - Debug Python scripts

### Using gdb Directly
```bash
gdb --args ./build/debug/Products/energyplus -d output testfiles/1ZoneUncontrolled.idf
```

### Memory Leak Detection with Valgrind
```bash
valgrind --leak-check=full --show-leak-kinds=all \
  ./build/debug/Products/energyplus -d output testfiles/1ZoneUncontrolled.idf
```

### Using Sanitizers
```bash
# Build with Address Sanitizer
cmake --preset debug-asan
cmake --build build/debug-asan

# Run (will report memory errors automatically)
./build/debug-asan/Products/energyplus ...
```

## Python Development

The Python API is installed in development mode during container setup:
```bash
# Run Python scripts
python3 script.py

# Run tests
pytest

# Format code
black .
```

## Tips

### Build Performance
- ccache is configured and will speed up rebuilds
- Use `-j$(nproc)` to build with all CPU cores
- Precompiled headers are enabled by default

### CMake
- Build directory is excluded from Git via `.gitignore`
- Use `cmake --build --clean-first` to force rebuild
- Compile commands are exported to `compile_commands.json`

### Container Customization
- Edit `.devcontainer/devcontainer.json` to add VS Code extensions
- Edit `.devcontainer/Dockerfile` to add system packages
- Edit `.devcontainer/setup.sh` for post-creation setup

## Troubleshooting

**Container build fails**: Check Docker has enough disk space and memory (recommend 4GB+ RAM, 20GB+ disk)

**CMake can't find Python**: The container uses Python 3.12 at `/usr/bin/python3.12`

**Build is slow**: First build takes time; subsequent builds use ccache for speed

**Tests fail**: Some tests may require specific weather files or test data

## Resources

- [EnergyPlus Documentation](https://energyplus.net/documentation)
- [Dev Containers Documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [CMake Documentation](https://cmake.org/documentation/)
