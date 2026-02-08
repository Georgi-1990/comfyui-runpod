# =============================================================================
# Arguments (can be overridden at build time)
# =============================================================================

ARG CUDA_VERSION=12.8
ARG BASE_IMAGE=runtime
ARG TORCH_CUDA=cu124

# =============================================================================
# Base image (CUDA runtime or devel)
# =============================================================================

FROM nvidia/cuda:${CUDA_VERSION}-cudnn9-${BASE_IMAGE}-ubuntu22.04

# =============================================================================
# Environment
# =============================================================================

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1
ENV PATH=/usr/local/bin:$PATH

# =============================================================================
# System dependencies
# =============================================================================

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    ca-certificates \
    curl \
    wget \
    git \
    gnupg \
    openssh-client \
    openssh-server \
    nano \
    htop \
    tmux \
    less \
    net-tools \
    iputils-ping \
    procps \
    ffmpeg \
    build-essential \
    libssl-dev \
    && add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# =============================================================================
# Set Python 3.12 as default
# =============================================================================

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 && \
    update-alternatives --set python3 /usr/bin/python3.12

# =============================================================================
# Pip
# =============================================================================

RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12 && \
    pip install --upgrade pip

# =============================================================================
# PyTorch (CUDA-compatible)
# =============================================================================

ARG TORCH_CUDA
RUN pip install \
    torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/${TORCH_CUDA}

# =============================================================================
# Jupyter
# =============================================================================

RUN pip install jupyter jupyterlab

# =============================================================================
# FileBrowser
# =============================================================================

RUN curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

# =============================================================================
# SSH configuration
# =============================================================================

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    mkdir -p /run/sshd && \
    rm -f /etc/ssh/ssh_host_*

# =============================================================================
# Workspace
# =============================================================================

RUN mkdir -p /workspace
WORKDIR /workspace

# =============================================================================
# Ports
# =============================================================================

EXPOSE 8188 8888 8080 22

# =============================================================================
# Start script
# =============================================================================

COPY start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
