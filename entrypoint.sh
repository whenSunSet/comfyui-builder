#!/bin/bash

echo "########################################"
echo "[INFO] entrypoint start..."
echo "########################################"

dirA="/home/scripts/plugin"
dirB="/home/work/ComfyUI/custom_nodes"
touched_file="/home/scripts/.touched"

# 检查 .touched 文件是否存在
if [ ! -f "$touched_file" ]; then
  # 清空目录B中的所有子目录
  for subdir in "$dirB"/*; do
    rm -rf "$subdir"
  done

  # 定义三元组
  triplets=()

  # 遍历目录A中的一级子目录
  for subdir in "$dirA"/*; do
    if [ -d "$subdir" ]; then
      # 获取子目录的名字
      subdir_name=$(basename "$subdir")
      # 检查目录B中是否存在同名子目录
      if [ ! -d "$dirB/$subdir_name" ]; then
        # 复制子目录到目录B
        cp -r "$subdir" "$dirB"
      fi
      
      # 遍历三元组列表
      for triplet in "${triplets[@]}"; do
        IFS=',' read -r triplet_subdir triplet_file triplet_url <<< "$triplet"
        
        # 检查子目录名是否匹配
        if [ "$subdir_name" == "$triplet_subdir" ]; then
          # 删除已有文件
          if [ -f "$dirB/$subdir_name/$triplet_file" ]; then
            rm "$dirB/$subdir_name/$triplet_file"
          fi
          
          unset http_proxy && unset https_proxy && unset HTTP_PROXY && unset HTTPS_PROXY && cd $dirB/$subdir_name

          triplet_dir=$(dirname "$triplet_file")
          if [ "$triplet_dir" != "." ]; then
              mkdir -p "$triplet_dir"
          fi

          curl -o "$triplet_file" "$triplet_url"
          
          # 检查下载是否成功
          if [ $? -ne 0 ]; then
            echo "Error downloading $triplet_url for $subdir_name"
          fi
        fi
      done
      
      # 文件替换完成后，检查子目录中是否存在 install.py 文件并执行
      if [ -f "$dirB/$subdir_name/install.py" ]; then
        # 在子目录中执行 install.py 脚本，并捕获错误
        echo "########################################"
        echo "Executing start install.py in $dirB/$subdir_name"
        cd "$dirB/$subdir_name" && python3 "install.py" || echo "Error executing install.py in $dirB/$subdir_name"
        echo "Executing end install.py in $dirB/$subdir_name"
        echo "########################################"
      fi
    fi
  done

  # 创建 .touched 文件
  touch "$touched_file"
else
  echo ".touched 文件已存在，跳过脚本执行。"
fi

export PATH="${PATH}:/home/work/.local/bin"
export PYTHONPYCACHEPREFIX="/home/work/.cache/pycache"
export HF_ENDPOINT=https://hf-mirror.com
export TRANSPARENT_BACKGROUND_FILE_PATH="/home/work/ComfyUI/models/transparent-background"

# Create and link controlnet directories if they don't exist
if [ ! -d "/home/work/ComfyUI/models/custom_nodes/comfyui_controlnet_aux/ckpts" ]; then
    echo "[INFO] Creating controlnet directory..."
    mkdir -p /home/work/ComfyUI/models/custom_nodes/comfyui_controlnet_aux/ckpts
    echo "[INFO] Controlnet directory created successfully"
else
    echo "[INFO] Controlnet directory already exists"
fi

if [ ! -L "/home/work/ComfyUI/custom_nodes/comfyui_controlnet_aux/ckpts" ]; then
    echo "[INFO] Creating controlnet symlink..."
    ln -s /home/work/ComfyUI/models/custom_nodes/comfyui_controlnet_aux/ckpts /home/work/ComfyUI/custom_nodes/comfyui_controlnet_aux/ckpts
    echo "[INFO] Controlnet symlink created successfully"
else
    echo "[INFO] Controlnet symlink already exists"
fi

# Create and link huggingface cache directory if it doesn't exist
if [ ! -d "/home/work/ComfyUI/models/design_cache/huggingface" ]; then
    echo "[INFO] Creating huggingface cache directory..."
    mkdir -p /home/work/ComfyUI/models/design_cache/huggingface
    echo "[INFO] Huggingface cache directory created successfully"
else
    echo "[INFO] Huggingface cache directory already exists"
fi

if [ ! -L "/root/.cache/huggingface" ]; then
    echo "[INFO] Creating huggingface cache symlink..."
    ln -s /home/work/ComfyUI/models/design_cache/huggingface /root/.cache/huggingface
    echo "[INFO] Huggingface cache symlink created successfully"
else
    echo "[INFO] Huggingface cache symlink already exists"
fi

# Create and link paddleocr cache directory if it doesn't exist
if [ ! -d "/home/work/ComfyUI/models/design_cache/paddleocr" ]; then
    echo "[INFO] Creating paddleocr cache directory..."
    mkdir -p /home/work/ComfyUI/models/design_cache/paddleocr
    echo "[INFO] Paddleocr cache directory created successfully"
else
    echo "[INFO] Paddleocr cache directory already exists"
fi

if [ ! -L "/root/.paddleocr" ]; then
    echo "[INFO] Creating paddleocr cache symlink..."
    ln -s /home/work/ComfyUI/models/design_cache/paddleocr /root/.paddleocr
    echo "[INFO] Paddleocr cache symlink created successfully"
else
    echo "[INFO] Paddleocr cache symlink already exists"
fi

cd /home/work

echo "########################################"
echo "[INFO] running ComfyUI..."
echo "########################################"

PYTHONFAULTHANDLER=1 python3 ./ComfyUI/main.py --listen --port ${AUTO_PORT2:-8188}

echo "########################################"
echo "[INFO] ComfyUI started successfully"
echo "########################################"
