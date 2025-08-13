#!/bin/bash

# Novogene 下载管理系统 - 环境自动配置脚本
# 作者: Python架构师
# 功能: 使用mamba创建环境，conda激活环境

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

print_error() {
    echo -e "${RED}[错误]${NC} $1"
}

# 检查是否安装了conda/mamba
check_conda_mamba() {
    print_info "检查conda/mamba安装状态..."
    
    if command -v mamba &> /dev/null; then
        print_success "检测到mamba，将使用mamba创建环境（速度更快）"
        USE_MAMBA=true
    elif command -v conda &> /dev/null; then
        print_warning "未检测到mamba，将使用conda创建环境"
        USE_MAMBA=false
    else
        print_error "错误：未检测到conda或mamba，请先安装Anaconda/Miniconda"
        exit 1
    fi
}

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_DIR/environment.yml"

print_info "项目目录: $PROJECT_DIR"
print_info "环境配置文件: $ENV_FILE"

# 检查environment.yml是否存在
if [ ! -f "$ENV_FILE" ]; then
    print_error "未找到environment.yml文件: $ENV_FILE"
    exit 1
fi

# 环境名称
ENV_NAME="novogene-download"

# 检查环境是否已存在
check_env_exists() {
    if conda env list | grep -q "^$ENV_NAME "; then
        return 0  # 环境存在
    else
        return 1  # 环境不存在
    fi
}

# 创建或更新环境
create_or_update_env() {
    if check_env_exists; then
        print_warning "环境 '$ENV_NAME' 已存在"
        read -p "是否要更新现有环境? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "更新环境 '$ENV_NAME'..."
            if [ "$USE_MAMBA" = true ]; then
                mamba env update -f "$ENV_FILE"
            else
                conda env update -f "$ENV_FILE"
            fi
            print_success "环境更新完成！"
        else
            print_info "跳过环境更新"
        fi
    else
        print_info "创建新环境 '$ENV_NAME'..."
        if [ "$USE_MAMBA" = true ]; then
            mamba env create -f "$ENV_FILE"
        else
            conda env create -f "$ENV_FILE"
        fi
        print_success "环境创建完成！"
    fi
}

# 验证环境安装
verify_installation() {
    print_info "验证环境安装..."
    
    # 激活环境并测试
    source "$(conda info --base)/etc/profile.d/conda.sh"
    conda activate "$ENV_NAME"
    
    # 检查Python版本
    python_version=$(python --version 2>&1)
    print_success "Python版本: $python_version"
    
    # 检查关键包
    print_info "检查关键依赖包..."
    python -c "
import flask
import psutil
import subprocess
import os
print('✓ Flask版本:', flask.__version__)
print('✓ psutil版本:', psutil.__version__)
print('✓ 所有关键包导入成功')
"
    
    conda deactivate
    print_success "环境验证完成！"
}

# 创建激活脚本
create_activation_script() {
    print_info "创建环境激活脚本..."
    
    cat > "$PROJECT_DIR/scripts/activate_env.sh" << 'EOF'
#!/bin/bash

# 快速激活Novogene下载管理系统环境
ENV_NAME="novogene-download"

# 检查环境是否存在
if ! conda env list | grep -q "^$ENV_NAME "; then
    echo "错误：环境 '$ENV_NAME' 不存在，请先运行 ./scripts/setup_env.sh"
    exit 1
fi

# 激活环境
echo "激活环境 '$ENV_NAME'..."
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate "$ENV_NAME"

echo "环境已激活！当前Python: $(which python)"
echo "要运行应用程序，请执行: python run.py"
EOF

    chmod +x "$PROJECT_DIR/scripts/activate_env.sh"
    print_success "激活脚本创建完成: scripts/activate_env.sh"
}

# 创建一键运行脚本
create_run_script() {
    print_info "创建一键运行脚本..."
    
    cat > "$PROJECT_DIR/run_app.sh" << 'EOF'
#!/bin/bash

# Novogene下载管理系统一键运行脚本
ENV_NAME="novogene-download"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 启动Novogene下载管理系统..."

# 检查环境是否存在
if ! conda env list | grep -q "^$ENV_NAME "; then
    echo "❌ 环境 '$ENV_NAME' 不存在，正在自动创建..."
    "$SCRIPT_DIR/scripts/setup_env.sh"
fi

# 激活环境并运行
echo "🔧 激活环境..."
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate "$ENV_NAME"

echo "🌐 启动Web服务器..."
cd "$SCRIPT_DIR"
python run.py
EOF

    chmod +x "$PROJECT_DIR/run_app.sh"
    print_success "一键运行脚本创建完成: run_app.sh"
}

# 主执行流程
main() {
    print_info "=== Novogene下载管理系统环境配置 ==="
    
    # 检查conda/mamba
    check_conda_mamba
    
    # 创建或更新环境
    create_or_update_env
    
    # 验证安装
    verify_installation
    
    # 创建辅助脚本
    create_activation_script
    create_run_script
    
    print_success "=== 环境配置完成 ==="
    print_info ""
    print_info "使用方法："
    print_info "1. 激活环境: source scripts/activate_env.sh"
    print_info "2. 运行应用: python run.py"
    print_info "3. 一键运行: ./run_app.sh"
    print_info ""
    print_success "环境名称: $ENV_NAME"
    print_success "访问地址: http://202.116.2.252:3683"
}

# 执行主函数
main "$@"
