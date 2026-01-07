# Single-stage development container for EnergyPlus
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set up basic environment
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=UTC

# Install ca-certificates package first (required for certificate management)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install certificate management (single script)
COPY .devcontainer/certs* /tmp/certs/
COPY .devcontainer/scripts/certctl-safe.sh /tmp/
RUN chmod +x /tmp/certctl-safe.sh && \
    /tmp/certctl-safe.sh install && \
    /tmp/certctl-safe.sh certs-refresh && \
    rm -rf /tmp/certctl-safe.sh /tmp/certs/

# Unified dev environment init (venv + prompt)
COPY .devcontainer/scripts/dev-env-init.sh /etc/profile.d/dev-env-init.sh
RUN chmod 644 /etc/profile.d/dev-env-init.sh

# Add PPAs for newer compiler versions
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
    && wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
    && add-apt-repository -y "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-18 main" \
    && rm -rf /var/lib/apt/lists/*

# Install essential build tools and compilers
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build essentials
    build-essential \
    curl \
    wget \
    git \
    # C/C++ compilers and tools
    gcc-13 \
    g++-13 \
    gfortran-13 \
    clang-18 \
    clang-format-18 \
    # Build tools
    cmake \
    ninja-build \
    ccache \
    pkg-config \
    patchelf \
    # System Python (uv will manage project Python versions)
    python3 \
    python3-dev \
    python3-venv \
    python3-pip \
    # X11 and OpenGL libraries for graphics support
    libxkbcommon-x11-0 \
    xorg-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    # Debugging and profiling tools
    gdb \
    valgrind \
    strace \
    ltrace \
    # Development utilities
    vim \
    nano \
    less \
    tree \
    file \
    zip \
    unzip \
    # Process and system tools
    htop \
    procps \
    lsof \
    && rm -rf /var/lib/apt/lists/*

# Set GCC 13 as default
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100 && \
    update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-13 100 && \
    update-alternatives --install /usr/bin/gcov gcov /usr/bin/gcov-13 100


# Install CMake (ensure we have a recent version >= 3.19)
RUN CMAKE_VERSION=$(cmake --version | head -n1 | cut -d' ' -f3) && \
    if [ "$(printf '%s\n' "3.19" "$CMAKE_VERSION" | sort -V | head -n1)" != "3.19" ]; then \
        echo "Installing newer CMake..." && \
        wget -q https://github.com/Kitware/CMake/releases/download/v3.28.1/cmake-3.28.1-linux-x86_64.sh && \
        sh cmake-3.28.1-linux-x86_64.sh --prefix=/usr/local --skip-license && \
        rm cmake-3.28.1-linux-x86_64.sh; \
    fi


# Configure ccache
RUN mkdir -p /workspace/.ccache && \
    chown -R vscode:vscode /workspace/.ccache

# Set up Git configuration for the container
RUN git config --system core.autocrlf input && \
    git config --system pull.rebase false && \
    git config --system init.defaultBranch main

# Copy installation scripts and install development tools
# This modular approach makes the Dockerfile cleaner and scripts reusable
COPY .devcontainer/scripts/ /tmp/install-scripts/
RUN chmod +x /tmp/install-scripts/*.sh

# Set up for development workflow
USER vscode
WORKDIR /workspaces/EnergyPlus-seb
ENV DOCKER_BUILD_CONTEXT=true
# Ensure user-local bin (Node, uv, etc.) is visible during install scripts
ENV PATH="/home/vscode/.local/bin:$PATH"


# Install user-level tools (UV, Node.js) - no sudo required
# This allows npm install -g and UV operations without sudo
# Python will be installed by UV during post-create setup
RUN bash -c '. /usr/local/bin/certctl 2>/dev/null || true && \
    certctl_load 2>/dev/null || true && \
    /tmp/install-scripts/install-user-uv.sh'
# RUN bash -c '. /usr/local/bin/certctl 2>/dev/null || true && \
#     certctl_load 2>/dev/null || true && \
#     /tmp/install-scripts/install-user-nodejs.sh'
# RUN bash -c '. /usr/local/bin/certctl 2>/dev/null || true && \
#     certctl_load 2>/dev/null || true && \
#     /tmp/install-scripts/install-user-claude-cli.sh'

# Ensure user-local bin (Node, uv, etc.) is visible during runtime
ENV PATH="/home/vscode/.local/bin:$PATH"

## Stateless certificate detection: no persistent status display configured


# Set working directory
WORKDIR /workspace

# Configure user environment
ENV PATH="/home/vscode/.local/bin:${PATH}" \
    CCACHE_DIR="/workspace/.ccache" \
    CCACHE_MAXSIZE="5G"

# Default command
CMD ["/bin/bash"]
