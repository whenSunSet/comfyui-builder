FROM 1018998632/comfy-base:v2

# Define build argument for version_id
ARG version_id

USER root

RUN mkdir -p /home/work /home/scripts/plugin \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY comfy-download.sh /home/scripts/comfy-download.sh
COPY install_requirements.py /home/scripts/install_requirements.py
COPY comfy_supervisor.conf /etc/supervisor
COPY start-comfy.sh /home/scripts/start-comfy.sh
COPY entrypoint.sh /home/scripts/entrypoint.sh

RUN sh /home/scripts/comfy-download.sh $version_id \
    && cd /home/scripts/plugin && sh /home/scripts/plugin/clone.sh \
    && python3 /home/scripts/install_requirements.py \
    && pip3 uninstall -y onnxruntime-gpu \
    && pip3 install onnxruntime-gpu==1.18.0 --extra-index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/onnxruntime-cuda-12/pypi/simple/ \
    && chmod +x /etc/supervisor/comfy_supervisor.conf \
    && chmod +x /home/scripts/start-comfy.sh \
    && chmod +x /home/scripts/entrypoint.sh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /home/work
CMD ["sh", "/home/scripts/start-comfy.sh"]