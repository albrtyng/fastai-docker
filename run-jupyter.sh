#!/bin/bash

# Create a named volume if it doesn't exist
docker volume create fastai-notebooks

docker build -t fastai-local .

docker run \
    --gpus all \
    --shm-size=2g \
    -p 8888:8888 \
    -v fastai-notebooks:/home/jupyter/notebooks \
    fastai-local 