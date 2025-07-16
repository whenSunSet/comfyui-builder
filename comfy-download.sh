#!/bin/bash

# 检查是否提供了id参数
if [ -z "$1" ]; then
  echo "Usage: $0 <comfy_result_id>"
  echo "Example: $0 64f8a1b2c3d4e5f6a7b8c9d0"
  exit 1
fi

ID=$1

# 定义POST请求的URL - 使用comfyResult的get端点
POST_URL="https://fakenews.heshixi.com/fake-news/api/comfyResult/get"

echo "正在请求ID: $ID"

# 发送POST请求并获取响应
RESPONSE=$(curl -s -X POST $POST_URL \
  -H "Content-Type: application/json" \
  -d "{\"id\": \"$ID\"}")

echo "API响应: $RESPONSE"

# 检查响应是否包含必要的数据，即使code不是200
if echo $RESPONSE | grep -q '"requirementsUrl"' && echo $RESPONSE | grep -q '"githubUrl"'; then
  echo "响应包含必要的数据，继续处理"
elif echo $RESPONSE | grep -q '"code":200'; then
  echo "请求成功"
else
  echo "请求失败 - 响应中缺少必要的数据"
  # 尝试提取错误信息
  ERROR_MSG=$(echo $RESPONSE | grep -o '"errorMsg":"[^"]*"' | cut -d'"' -f4)
  if [ -n "$ERROR_MSG" ]; then
    echo "错误信息: $ERROR_MSG"
  fi
  exit 1
fi

# 提取requirementsUrl和githubUrl
REQUIREMENTS_URL=$(echo $RESPONSE | grep -o '"requirementsUrl":"[^"]*"' | cut -d'"' -f4)
GITHUB_URL=$(echo $RESPONSE | grep -o '"githubUrl":"[^"]*"' | cut -d'"' -f4)

# 检查是否成功获取URL
if [ -z "$REQUIREMENTS_URL" ] || [ -z "$GITHUB_URL" ]; then
  echo "获取文件URL失败"
  echo "requirementsUrl: $REQUIREMENTS_URL"
  echo "githubUrl: $GITHUB_URL"
  exit 1
fi

echo "获取的requirementsUrl是: $REQUIREMENTS_URL"
echo "获取的githubUrl是: $GITHUB_URL"

# 检查是否存在basePlugin字段
if echo $RESPONSE | grep -q '"basePlugin"'; then
  echo "检测到basePlugin字段，开始处理基础插件..."
  
  # 提取zipUrl
  ZIP_URL=$(echo $RESPONSE | grep -o '"zipUrl":"[^"]*"' | cut -d'"' -f4)
  
  if [ -z "$ZIP_URL" ]; then
    echo "获取basePlugin的zipUrl失败"
    exit 1
  fi
  
  echo "获取的zipUrl是: $ZIP_URL"
  
  # 创建/home/work目录（如果不存在）
  mkdir -p /home/work
  
  # 下载zip文件到/home/work
  ZIP_FILE="/home/work/ComfyUI.zip"
  echo "正在下载ComfyUI.zip到/home/work..."
  curl -o $ZIP_FILE $ZIP_URL
  if [ $? -ne 0 ]; then
    echo "下载ComfyUI.zip失败"
    exit 1
  fi
  
  # 解压成ComfyUI目录
  echo "正在解压ComfyUI.zip..."
  cd /home/work
  
  # 创建ComfyUI目录
  mkdir -p ComfyUI
  
  # 解压到ComfyUI目录
  unzip -o ComfyUI.zip -d ComfyUI
  if [ $? -ne 0 ]; then
    echo "解压ComfyUI.zip失败"
    exit 1
  fi
  
  # 进入ComfyUI目录
  cd ComfyUI
  
  # 检查是否成功进入ComfyUI目录
  if [ ! -f "requirements.txt" ] && [ ! -f "main.py" ] && [ ! -d "comfy" ]; then
    echo "ComfyUI目录中未找到ComfyUI相关文件，检查是否有子目录"
    # 查找包含ComfyUI文件的子目录
    COMFY_DIR=$(find . -maxdepth 2 -name "requirements.txt" -o -name "main.py" -o -name "comfy" | head -1 | xargs dirname)
    if [ -n "$COMFY_DIR" ] && [ "$COMFY_DIR" != "." ]; then
      echo "找到ComfyUI文件在子目录: $COMFY_DIR"
      cd "$COMFY_DIR"
    else
      echo "无法找到ComfyUI相关文件"
      exit 1
    fi
  fi
  
  # 进入ComfyUI目录并安装requirements.txt
  echo "进入ComfyUI目录并安装依赖..."
  if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    if [ $? -ne 0 ]; then
      echo "安装requirements.txt失败"
      exit 1
    fi
    echo "ComfyUI依赖安装完成"
  else
    echo "ComfyUI目录中未找到requirements.txt"
  fi
  
  echo "basePlugin处理完成"
else
  echo "未检测到basePlugin字段，跳过基础插件处理"
fi

# 定义下载路径
REQUIREMENTS_DOWNLOAD_PATH="/home/scripts/requirements.txt"
CLONE_SCRIPT_DOWNLOAD_PATH="/home/scripts/plugin/clone.sh"

# 使用curl下载文件
echo "正在下载requirements.txt..."
curl -o $REQUIREMENTS_DOWNLOAD_PATH $REQUIREMENTS_URL
if [ $? -ne 0 ]; then
  echo "下载requirements.txt失败"
  exit 1
fi

echo "正在下载clone.sh..."
curl -o $CLONE_SCRIPT_DOWNLOAD_PATH $GITHUB_URL
if [ $? -ne 0 ]; then
  echo "下载clone.sh失败"
  exit 1
fi

echo "文件下载完成"
