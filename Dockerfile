# Stage 1: Build stage
FROM nvidia/cuda:12.8.0-base-ubuntu22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Add labels to document runtime requirements
LABEL maintainer="Albert Yang"
LABEL description="Jupyter notebook for fastai course workloads with GPU support"
LABEL runtime.requirements="Run with: docker run --gpus all --shm-size=2g -p 8888:8888 <image-name>"

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-dev \
    gcc \
    build-essential \
    libssl-dev \
    libffi-dev \
    git \
    graphviz \
    pkg-config \
    sentencepiece \
    libsentencepiece-dev

# Install Python packages
RUN python3 -m pip install --no-cache-dir --upgrade pip "setuptools>=68.0.0" "wheel>=0.41.0"

# Install PyTorch and other dependencies
RUN python3 -m pip install --no-cache-dir --pre \
    torch torchvision \
    --index-url https://download.pytorch.org/whl/nightly/cu128 \
    --target /python_packages

# Stage 2: Final stage
FROM nvidia/cuda:12.8.0-base-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install only runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    graphviz && \
    rm -rf /var/lib/apt/lists/*

# Copy the installed packages from builder stage
COPY --from=builder /python_packages /usr/local/lib/python3.10/site-packages/

RUN python3 -m pip install --no-cache-dir --upgrade pip && \
    python3 -m pip install --no-cache-dir \
    notebook \
    jupyterlab \
    ipykernel \
    ipython \
    "ipywidgets<8"  # Downgrade ipywidgets for fastbook 0.2.9 compatibility

# Install fastai and its core dependencies manually to avoid torch reinstall
RUN python3 -m pip install --no-cache-dir \
    scipy \
    scikit-learn \
    "fastcore<1.6.0" \
    fastdownload \
    fastprogress \
    matplotlib \
    pandas \
    spacy \
    datasets \
    transformers \
    duckduckgo_search \
    "sentencepiece==0.1.97" \
    && python3 -m pip install --no-cache-dir fastai --no-deps \
    && python3 -m pip install --no-cache-dir fastbook --no-deps

# Create non-root user
RUN useradd -m jupyter

# Set proper permissions after all installations
RUN chown -R jupyter:jupyter /home/jupyter

# Switch to non-root user
USER jupyter
WORKDIR /home/jupyter

EXPOSE 8888

# Use jupyter-notebook command
CMD ["jupyter", "notebook", \
    "--ServerApp.ip=0.0.0.0", \
    "--port=8888", \
    "--ServerApp.port_retries=0", \
    "--ServerApp.allow_credentials=True", \
    "--no-browser"]