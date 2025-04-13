FROM nvidia/cuda:12.8.0-base-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# Add labels to document runtime requirements
LABEL maintainer="Albert Yang"
LABEL description="Jupyter notebook for fastai course workloads with GPU support"
LABEL runtime.requirements="Run with: docker run --gpus all --shm-size=2g -p 8888:8888 <image-name>"

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

# Reduce final image size by deleting apt cache
RUN rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m jupyter

# Create and set permissions for pip cache directory
RUN mkdir -p /home/jupyter/.cache/pip && \
    chown -R jupyter:jupyter /home/jupyter/.cache

# Switch to the non-root user
USER jupyter
WORKDIR /home/jupyter

# Install Python packages and ensure scripts are in PATH
ENV PATH="${PATH}:/home/jupyter/.local/bin"

# Upgrade pip and basic tools
RUN python3 -m pip install --no-cache-dir --upgrade pip && \
    python3 -m pip install --no-cache-dir --upgrade setuptools wheel

# Install Jupyter ecosystem
RUN python3 -m pip install --no-cache-dir \
    notebook \
    jupyterlab \
    ipykernel \
    ipython \
    "ipywidgets<8"  # Downgrade ipywidgets for fastbook 0.2.9 compatibility

# Install PyTorch with CUDA support (nightly - 5070ti support)
RUN python3 -m pip install --no-cache-dir --pre \
    torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/nightly/cu128

# Install graphviz used by fastai notebooks
RUN python3 -m pip install --no-cache-dir graphviz

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
    "sentencepiece==0.1.97" \
    && python3 -m pip install --no-cache-dir fastai --no-deps \
    && python3 -m pip install --no-cache-dir fastbook --no-deps

EXPOSE 8888

# Use jupyter-notebook command
CMD ["jupyter-notebook", "--ip", "0.0.0.0", "--no-browser"]