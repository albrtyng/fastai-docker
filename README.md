# FastAI Docker Environment for Local GPU

This Docker container provides a minimal environment for running FastAI course notebooks with local NVIDIA GPU support. It's specifically tested with the NVIDIA RTX 5070 Ti (sm120).

## Prerequisites

- Docker installed on your system
- NVIDIA GPU drivers installed
- NVIDIA Container Toolkit (nvidia-docker2)

## Features

- Minimal base image to reduce container size
- CUDA support for GPU acceleration
- Jupyter Lab environment
- FastAI library and dependencies
- Python 3.x environment

## Quick Start

1. Using the shell script (recommended):

```bash
./run-jupyter.sh
```

2. Or manually build and run:

```bash
docker volume create fastai-notebooks
```

```bash
docker build -t fastai-local .
```

3. Run the container:

```bash
docker run --gpus all -p 8888:8888 -v fastai-notebooks:/home/jupyter/ fastai-local
```

This will:

- Enable GPU access with `--gpus all`
- Map port 8888 for Jupyter Lab access
- Mount current directory to /workspace in container

## Accessing Notebooks

Once the container is running:

1. Open your browser to `http://localhost:8888`
2. The Jupyter Lab interface will load with access to your notebooks
3. Any notebooks in your current directory will be available in the /workspace folder

## GPU Verification

To verify GPU access inside the container, you can run:

```python
import torch
print(torch.cuda.is_available())
print(torch.cuda.get_device_name())
```

## Notes

- This container is optimized for the NVIDIA RTX 5070 Ti with Compute Capability 12.0
- Adjust CUDA version in Dockerfile if using different GPU models
- Container includes minimal dependencies to reduce size and build time

## License

This project is open-source and available under the MIT License.
