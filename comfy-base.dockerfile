FROM python:3.11 as base

FROM node:18 AS node
RUN mkdir /node
RUN cp -r /usr/local/* /node/

FROM base
COPY --from=node /node /usr/local/
RUN node -v && npm -v

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" >> /etc/timezone

LABEL maintainer="a1018998632@gmail.com"

# ENV https_proxy="oversea-squid4.sgp.txyun:11080"
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=all

RUN apt update -y && apt install git aria2 wget ffmpeg curl supervisor unzip openssh-client openssh-server nfs-common vim -y && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip install torch==2.3.1 torchvision torchaudio

# Fix for libs (.so files)
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}\
:/usr/lib64/python3.11/site-packages/torch/lib\
:/usr/lib/python3.11/site-packages/nvidia/cuda_cupti/lib\
:/usr/lib/python3.11/site-packages/nvidia/cuda_runtime/lib\
:/usr/lib/python3.11/site-packages/nvidia/cudnn/lib\
:/usr/lib/python3.11/site-packages/nvidia/cufft/lib"

# More libs (not necessary, just in case)
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}\
:/usr/lib/python3.11/site-packages/nvidia/cublas/lib\
:/usr/lib/python3.11/site-packages/nvidia/cuda_nvrtc/lib\
:/usr/lib/python3.11/site-packages/nvidia/curand/lib\
:/usr/lib/python3.11/site-packages/nvidia/cusolver/lib\
:/usr/lib/python3.11/site-packages/nvidia/cusparse/lib\
:/usr/lib/python3.11/site-packages/nvidia/nccl/lib\
:/usr/lib/python3.11/site-packages/nvidia/nvjitlink/lib\
:/usr/lib/python3.11/site-packages/nvidia/nvtx/lib"

CMD ["sleep", "infinity"]

