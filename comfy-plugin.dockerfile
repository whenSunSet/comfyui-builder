FROM 1018998632/comfy-base:v1

# Define build argument for version_id
ARG version_id

RUN mkdir -p /home/work
USER root

RUN mkdir -p /home/scripts/plugin

# Set environment variable from build argument
ENV version_id=$version_id

COPY comfy-download.sh /home/scripts/comfy-download.sh

RUN sh /home/scripts/comfy-download.sh $version_id
RUN cd /home/scripts/plugin && sh /home/scripts/plugin/clone.sh 

COPY install_requirements.py /home/scripts/install_requirements.py
RUN python3 /home/scripts/install_requirements.py

RUN pip3 uninstall -y onnxruntime-gpu && pip3 install onnxruntime-gpu==1.18.0 --extra-index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/onnxruntime-cuda-12/pypi/simple/

COPY comfy_supervisor.conf /etc/supervisor
COPY start-comfy.sh /home/scripts/start-comfy.sh
COPY entrypoint.sh /home/scripts/entrypoint.sh

RUN chmod +x /etc/supervisor/comfy_supervisor.conf
RUN chmod +x /home/scripts/start-comfy.sh
RUN chmod +x /home/scripts/entrypoint.sh

WORKDIR /home/work
CMD ["sh", "/home/scripts/start-comfy.sh"]