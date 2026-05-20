#!/bin/bash
# OpenTenBase .deb 构建脚本
# 用法: ./build-deb.sh [源码目录] [输出目录]

set -e

# 默认路径
SOURCE_DIR="${1:-/source}"
OUTPUT_DIR="${2:-/output}"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查源码目录
check_source() {
    if [ ! -d "$SOURCE_DIR" ]; then
        log_error "源码目录不存在: $SOURCE_DIR"
        exit 1
    fi

    if [ ! -f "$SOURCE_DIR/configure" ] && [ ! -f "$SOURCE_DIR/Makefile" ]; then
        log_error "未找到构建文件 (configure 或 Makefile)"
        exit 1
    fi
}

# 安装构建依赖
install_dependencies() {
    log_info "安装构建依赖..."
    
    apt-get update -qq
    apt-get install -y -qq \
        build-essential \
        debhelper \
        devscripts \
        fakeroot \
        quilt \
        bison \
        flex \
        perl \
        libreadline-dev \
        zlib1g-dev \
        libssl-dev \
        libpam0g-dev \
        libxml2-dev \
        libldap2-dev \
        libossp-uuid-dev \
        uuid-dev \
        libcurl4-openssl-dev \
        liblz4-dev \
        libzstd-dev \
        libssh2-1-dev \
        libpqxx-dev \
        libcli11-dev \
        pkg-config \
        libtool
}

# 应用补丁
apply_patches() {
    log_info "应用补丁..."
    
    cd "$SOURCE_DIR"
    
    # 应用 bool/stdbool 补丁
    if [ -f debian/patches/01-bool-stdbool.patch ]; then
        patch -p1 < debian/patches/01-bool-stdbool.patch || true
    fi
    
    # 应用 nolic sharding 补丁
    if [ -f debian/patches/02-nolic-sharding.patch ]; then
        patch -p1 < debian/patches/02-nolic-sharding.patch || true
    fi
}

# 构建软件包
build_packages() {
    log_info "构建软件包..."
    
    cd "$SOURCE_DIR"
    
    # 清理之前的构建
    fakeroot debian/rules clean || true
    
    # 构建软件包
    fakeroot debian/rules binary
    
    # 移动到输出目录
    mkdir -p "$OUTPUT_DIR"
    mv ../*.deb "$OUTPUT_DIR/"
}

# 验证软件包
verify_packages() {
    log_info "验证软件包..."
    
    cd "$OUTPUT_DIR"
    
    for deb in *.deb; do
        echo "=== $deb ==="
        dpkg-deb -I "$deb" | head -15
        echo
    done
}

# 主函数
main() {
    echo "========================================"
    echo "  OpenTenBase .deb 构建脚本"
    echo "========================================"
    echo ""
    
    check_source
    install_dependencies
    apply_patches
    build_packages
    verify_packages
    
    log_info "构建完成！"
    log_info "软件包位置: $OUTPUT_DIR"
}

# 执行主函数
main "$@"
