#!/bin/bash

# Novogene下载管理系统一键运行脚本
# 功能: 自动检查环境，创建/激活环境，启动应用

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

ENV_NAME="novogene-download"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║               诺禾云下载管理系统启动器                     ║"
echo "║                Novogene Download Manager                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# 检查conda是否可用
check_conda() {
    if ! command -v conda &> /dev/null; then
        echo -e "${RED}❌ 错误：未检测到conda，请先安装Anaconda/Miniconda${NC}"
        exit 1
    fi
}

# 检查环境是否存在
check_env_exists() {
    if conda env list | grep -q "^$ENV_NAME "; then
        return 0  # 环境存在
    else
        return 1  # 环境不存在
    fi
}

# 主启动流程
main() {
    echo -e "${BLUE}🔍 检查系统环境...${NC}"
    check_conda
    
    # 检查环境是否存在
    if check_env_exists; then
        echo -e "${GREEN}✅ 环境 '$ENV_NAME' 已存在${NC}"
    else
        echo -e "${YELLOW}⚠️  环境 '$ENV_NAME' 不存在，正在自动创建...${NC}"
        
        # 检查setup脚本是否存在
        if [ ! -f "$SCRIPT_DIR/scripts/setup_env.sh" ]; then
            echo -e "${RED}❌ 错误：未找到环境配置脚本 scripts/setup_env.sh${NC}"
            exit 1
        fi
        
        # 运行环境配置脚本
        echo -e "${BLUE}🛠️  运行环境配置脚本...${NC}"
        "$SCRIPT_DIR/scripts/setup_env.sh"
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}❌ 环境创建失败${NC}"
            exit 1
        fi
    fi
    
    echo -e "${BLUE}🔧 激活环境 '$ENV_NAME'...${NC}"
    
    # 初始化conda
    source "$(conda info --base)/etc/profile.d/conda.sh"
    
    # 激活环境
    conda activate "$ENV_NAME"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ 环境激活失败${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ 环境激活成功！${NC}"
    echo -e "${GREEN}🐍 Python版本: $(python --version)${NC}"
    echo -e "${GREEN}📍 Python路径: $(which python)${NC}"
    
    # 切换到项目目录
    cd "$SCRIPT_DIR"
    
    echo -e "${BLUE}🌐 启动Web服务器...${NC}"
    echo -e "${YELLOW}访问地址: http://202.116.2.252:3683${NC}"
    echo -e "${YELLOW}按 Ctrl+C 停止服务器${NC}"
    echo ""
    
    # 启动应用
    python run.py
}

# 错误处理
trap 'echo -e "\n${YELLOW}🛑 服务器已停止${NC}"; exit 0' INT

# 执行主函数
main "$@"
