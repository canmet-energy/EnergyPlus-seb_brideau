#!/bin/bash
set -e

# echo "🚀 Setting up EnergyPlus development environment..."

# # Install Python dependencies from requirements.txt if it exists
# if [ -f "requirements.txt" ]; then
#     echo "📦 Installing Python dependencies from requirements.txt..."
#     uv pip install -r requirements.txt
# fi

# # Install Python package in development mode
# if [ -f "setup.py" ]; then
#     echo "📦 Installing EnergyPlus Python API in development mode..."
#     uv pip install -e .
# fi



# Configure ccache
echo "⚙️  Configuring ccache..."
ccache --set-config=max_size=5G
ccache --set-config=compression=true
ccache --zero-stats

# Create common build directories
echo "📁 Creating build directories..."
mkdir -p build/Debug
mkdir -p build/Release
mkdir -p build/RelWithDebInfo

# Display versions of key tools
echo ""
echo "✅ Development environment ready!"
echo ""
echo "📊 Installed versions:"
echo "  - GCC:      $(gcc --version | head -n1)"
echo "  - G++:      $(g++ --version | head -n1)"
echo "  - Gfortran: $(gfortran --version | head -n1)"
echo "  - CMake:    $(cmake --version | head -n1)"
echo "  - Python:   $(python3 --version)"
echo "  - Ninja:    $(ninja --version)"
echo "  - ccache:   $(ccache --version | head -n1)"
echo ""
echo "🔨 Quick start commands:"
echo "  - Install Python dependencies: uv pip install -r requirements.txt"
echo "  - Install EnergyPlus Python API: uv pip install -e ."
echo "  - Configure (Debug):   cmake -B build/Debug -G Ninja -DCMAKE_BUILD_TYPE=Debug -DBUILD_FORTRAN=ON -DBUILD_TESTING=ON -DLINK_WITH_PYTHON=ON"
echo "  - All in one install/configure: uv pip install -r requirements.txt && uv pip install -e . && cmake -B build/Debug -G Ninja -DCMAKE_BUILD_TYPE=Debug -DBUILD_FORTRAN=ON -DBUILD_TESTING=ON -DLINK_WITH_PYTHON=ON && cmake --build build/Debug -j\$(nproc)"
echo "  - Build:               cmake --build build/Debug -j\$(nproc)"
echo "  - Test:                cd build/Debug && ctest --output-on-failure"
echo "  - Run EnergyPlus:      ./build/Debug/Products/energyplus --help"
echo ""
echo "🐛 Debugging tools available:"
echo "  - gdb (GNU Debugger)"
echo "  - valgrind (Memory leak detection)"
echo "  - Address Sanitizer (add -DENABLE_SANITIZER_ADDRESS=ON to CMake)"
# echo "🚀 EnergyPlus development environment setup complete!"

