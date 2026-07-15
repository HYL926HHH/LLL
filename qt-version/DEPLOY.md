# 岁里时光 - 桌面版部署指南

## 快速开始

### macOS / Linux
```bash
# 一键部署
chmod +x deploy.sh
./deploy.sh
```

### Windows
```cmd
# 双击运行
deploy.bat
```

---

## 手动部署

### 1. 安装依赖

| 平台 | 命令 |
|------|------|
| macOS | `brew install qt@6 cmake` |
| Ubuntu | `sudo apt install qt6-base-dev qt6-declarative-dev qt6-charts-dev cmake` |
| Windows | 下载安装 [Qt 6.5+](https://www.qt.io/download) + [CMake](https://cmake.org/download/) |

**Qt 安装组件勾选：**
- ✅ Qt 6.x (Core, GUI, QML, Quick, QuickControls2)
- ✅ Qt Charts
- ✅ Qt SQL (SQLite plugin)
- ✅ 编译器 (MSVC 2019+ 或 MinGW)

### 2. 编译

```bash
mkdir build && cd build

# macOS
cmake .. -DCMAKE_PREFIX_PATH=$(brew --prefix qt@6)

# Linux (如果 Qt 在默认路径)
cmake ..

# Windows (根据实际路径调整)
cmake .. -DCMAKE_PREFIX_PATH="C:/Qt/6.5.0/msvc2019_64"

# 编译
cmake --build . --config Release
```

### 3. 运行

```bash
# Linux
./build/SuiliTime

# macOS
open build/SuiliTime.app

# Windows
build\Release\SuiliTime.exe
```

---

## 打包发布

### macOS → .dmg
```bash
macdeployqt build/SuiliTime.app -dmg
# 输出: SuiliTime.dmg
```

### Linux → .AppImage
```bash
# 安装 appimagetool
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool*.AppImage

# 打包
./appimagetool-x86_64.AppImage deploy/AppDir
# 输出: SuiliTime-x86_64.AppImage
```

### Windows → 可分发文件夹
```cmd
windeployqt build\Release\SuiliTime.exe --release
# 将 Release 文件夹打包为 zip 即可分发
```

---

## 常见问题

### Q: 编译报错 "Could not find Qt6"
**A:** 设置 `CMAKE_PREFIX_PATH` 指向 Qt 安装目录：
```bash
export CMAKE_PREFIX_PATH=/path/to/Qt/6.5.0/gcc_64
```

### Q: 运行时报错 "Cannot load library Qt6Charts"
**A:** 确保安装了 Qt Charts 组件，或运行 `windeployqt` / `macdeployqt` 部署依赖。

### Q: Windows 运行缺少 DLL
**A:** 运行 `windeployqt SuiliTime.exe` 自动复制所有依赖 DLL。

### Q: Linux 中文显示为方块
**A:** 安装中文字体：
```bash
sudo apt install fonts-noto-cjk
```

### Q: 数据库文件在哪里？
**A:** 首次运行自动创建：
- macOS: `~/Library/Application Support/SuiliTime/suili.db`
- Linux: `~/.local/share/SuiliTime/suili.db`
- Windows: `%APPDATA%\SuiliTime\suili.db`

---

## 系统要求

| 项目 | 最低要求 |
|------|----------|
| 操作系统 | Windows 10+ / macOS 11+ / Ubuntu 20.04+ |
| 内存 | 512 MB |
| 磁盘 | 100 MB |
| 屏幕 | 1024×768 |

---

## 技术支持

如有问题，请检查：
1. Qt 版本是否为 6.5+
2. CMake 版本是否为 3.16+
3. 是否安装了所有必需的 Qt 组件
