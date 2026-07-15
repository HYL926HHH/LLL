#!/bin/bash
# ============================================
# 岁里时光 - Qt 桌面版一键部署脚本
# 支持: macOS / Linux
# ============================================

set -e

echo "🍂 岁里时光 - 桌面版部署"
echo "========================"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查 Qt 安装
check_qt() {
    echo -e "${YELLOW}[1/5] 检查 Qt 环境...${NC}"
    
    if [ -n "$CMAKE_PREFIX_PATH" ]; then
        echo "  ✓ 使用 CMAKE_PREFIX_PATH: $CMAKE_PREFIX_PATH"
        return 0
    fi
    
    # macOS Homebrew
    if command -v brew &> /dev/null; then
        QT_PATH=$(brew --prefix qt@6 2>/dev/null || brew --prefix qt 2>/dev/null)
        if [ -n "$QT_PATH" ] && [ -d "$QT_PATH" ]; then
            export CMAKE_PREFIX_PATH="$QT_PATH"
            echo "  ✓ 检测到 Homebrew Qt: $QT_PATH"
            return 0
        fi
    fi
    
    # Linux 默认路径
    for path in /usr/lib/qt6 /usr/lib/x86_64-linux-gnu/qt6 /opt/Qt/6.5.0/gcc_64; do
        if [ -d "$path" ]; then
            export CMAKE_PREFIX_PATH="$path"
            echo "  ✓ 检测到 Qt: $path"
            return 0
        fi
    done
    
    echo -e "${RED}  ✗ 未找到 Qt 6，请先安装:${NC}"
    echo ""
    echo "  macOS:   brew install qt@6"
    echo "  Ubuntu:  sudo apt install qt6-base-dev qt6-declarative-dev qt6-charts-dev"
    echo "  Windows: https://www.qt.io/download-qt-installer"
    echo ""
    exit 1
}

# 检查 CMake
check_cmake() {
    echo -e "${YELLOW}[2/5] 检查 CMake...${NC}"
    if command -v cmake &> /dev/null; then
        VERSION=$(cmake --version | head -1 | awk '{print $3}')
        echo "  ✓ CMake $VERSION"
    else
        echo -e "${RED}  ✗ 未找到 CMake${NC}"
        echo "  安装: brew install cmake (macOS) / sudo apt install cmake (Linux)"
        exit 1
    fi
}

# 编译
build() {
    echo -e "${YELLOW}[3/5] 编译项目...${NC}"
    
    cd "$(dirname "$0")"
    
    mkdir -p build
    cd build
    
    cmake .. -DCMAKE_PREFIX_PATH="$CMAKE_PREFIX_PATH" -DCMAKE_BUILD_TYPE=Release
    cmake --build . --config Release -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
    
    echo -e "${GREEN}  ✓ 编译成功${NC}"
}

# 运行测试
test_run() {
    echo -e "${YELLOW}[4/5] 测试运行...${NC}"
    
    if [ -f "build/SuiliTime" ]; then
        echo "  ✓ 可执行文件: build/SuiliTime"
        echo ""
        echo "  运行命令: ./build/SuiliTime"
    elif [ -f "build/SuiliTime.app" ]; then
        echo "  ✓ 应用包: build/SuiliTime.app"
        echo ""
        echo "  运行命令: open build/SuiliTime.app"
    fi
}

# 打包
package() {
    echo -e "${YELLOW}[5/5] 打包发布...${NC}"
    
    OS=$(uname -s)
    
    if [ "$OS" = "Darwin" ]; then
        # macOS
        if [ -d "build/SuiliTime.app" ]; then
            macdeployqt build/SuiliTime.app -dmg 2>/dev/null || true
            echo -e "${GREEN}  ✓ 已生成: build/SuiliTime.dmg${NC}"
        fi
    elif [ "$OS" = "Linux" ]; then
        # Linux - 创建 AppDir
        echo "  创建 AppDir 结构..."
        mkdir -p deploy/AppDir/usr/bin
        mkdir -p deploy/AppDir/usr/share/applications
        mkdir -p deploy/AppDir/usr/share/icons/hicolor/256x256/apps
        
        cp build/SuiliTime deploy/AppDir/usr/bin/
        
        # 创建 desktop 文件
        cat > deploy/AppDir/usr/share/applications/suili-time.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=岁里时光
Comment=个人财务管理工具
Exec=SuiliTime
Icon=suili-time
Categories=Office;Finance;
EOF
        
        cp deploy/AppDir/usr/share/applications/suili-time.desktop deploy/AppDir/
        
        echo -e "${GREEN}  ✓ 已生成: deploy/AppDir/${NC}"
        echo "  可使用 appimagetool 打包为 .AppImage"
    fi
}

# 主流程
main() {
    check_qt
    check_cmake
    build
    test_run
    
    echo ""
    read -p "是否打包发布版本? (y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        package
    fi
    
    echo ""
    echo -e "${GREEN}========================${NC}"
    echo -e "${GREEN}  部署完成!${NC}"
    echo -e "${GREEN}========================${NC}"
}

main "$@"
