@echo off
chcp 65001 >nul
REM ============================================
REM 岁里时光 - Qt 桌面版一键部署脚本 (Windows)
REM ============================================

echo.
echo 🍂 岁里时光 - 桌面版部署 (Windows)
echo ========================
echo.

REM 检查 Qt 安装
echo [1/4] 检查 Qt 环境...

if defined CMAKE_PREFIX_PATH (
    echo   使用 CMAKE_PREFIX_PATH: %CMAKE_PREFIX_PATH%
    goto :check_cmake
)

REM 检查常见 Qt 安装路径
for %%P in (
    "C:\Qt\6.5.0\msvc2019_64"
    "C:\Qt\6.5.0\mingw_64"
    "C:\Qt\6.6.0\msvc2019_64"
    "C:\Qt\6.6.0\mingw_64"
    "D:\Qt\6.5.0\msvc2019_64"
    "D:\Qt\6.5.0\mingw_64"
) do (
    if exist %%P (
        set "CMAKE_PREFIX_PATH=%%~P"
        echo   检测到 Qt: %%P
        goto :check_cmake
    )
)

echo.
echo   [错误] 未找到 Qt 6，请先安装:
echo.
echo   下载地址: https://www.qt.io/download-qt-installer
echo   安装时勾选: Qt 6.x + MSVC/MinGW + Qt Charts + Qt SQL
echo.
pause
exit /b 1

:check_cmake
echo [2/4] 检查 CMake...
where cmake >nul 2>&1
if %errorlevel% neq 0 (
    echo   [错误] 未找到 CMake
    echo   下载: https://cmake.org/download/
    pause
    exit /b 1
)
cmake --version | findstr /i "version"
echo.

:build
echo [3/4] 编译项目...
echo.

if not exist build mkdir build
cd build

cmake .. -DCMAKE_PREFIX_PATH="%CMAKE_PREFIX_PATH%" -DCMAKE_BUILD_TYPE=Release
if %errorlevel% neq 0 (
    echo   [错误] CMake 配置失败
    pause
    exit /b 1
)

cmake --build . --config Release
if %errorlevel% neq 0 (
    echo   [错误] 编译失败
    pause
    exit /b 1
)

echo.
echo   [成功] 编译完成
echo.

:deploy
echo [4/4] 部署依赖...
echo.

REM 查找生成的 exe
for /r "Release" %%f in (*.exe) do (
    set "EXE_PATH=%%f"
    echo   找到: %%f
    
    REM 使用 windeployqt 复制依赖
    echo   运行 windeployqt...
    windeployqt "%%f" --release --no-translations 2>nul
    
    echo.
    echo   [成功] 依赖部署完成
    echo   可直接运行: %%f
    echo   或将整个 Release 文件夹打包分发
)

echo.
echo ========================
echo   部署完成!
echo ========================
echo.
pause
