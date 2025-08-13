#!/bin/bash

# Novogene下载管理系统 - 快速环境激活脚本
# 功能: 快速激活conda环境

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ENV_NAME="novogene-download"

echo -e "${YELLOW}🔧 激活Novogene下载管理系统环境...${NC}"

# 检查conda是否可用
if ! command -v conda &> /dev/null; then
    echo -e "${RED}❌ 错误：未检测到conda，请先安装Anaconda/Miniconda${NC}"
    exit 1
fi

# 检查环境是否存在
if ! conda env list | grep -q "^$ENV_NAME "; then
    echo -e "${RED}❌ 错误：环境 '$ENV_NAME' 不存在${NC}"
    echo -e "${YELLOW}请先运行环境配置脚本: ./scripts/setup_env.sh${NC}"
    exit 1
fi

# 初始化conda
source "$(conda info --base)/etc/profile.d/conda.sh"

# 激活环境
conda activate "$ENV_NAME"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 环境 '$ENV_NAME' 已成功激活！${NC}"
    echo -e "${GREEN}📍 当前Python路径: $(which python)${NC}"
    echo -e "${GREEN}🐍 Python版本: $(python --version)${NC}"
    echo ""
    echo -e "${YELLOW}💡 使用提示:${NC}"
    echo "   • 运行应用: python run.py"
    echo "   • 退出环境: conda deactivate"
    echo "   • 一键运行: ./run_app.sh"
else
    echo -e "${RED}❌ 环境激活失败${NC}"
    exit 1
fi
