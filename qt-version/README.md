# 岁里时光 - Qt 版本

温馨风格的个人财务管理桌面/移动应用，基于 Qt 6 + QML 构建。

## 技术栈

- **Framework**: Qt 6.5+ (QML + C++)
- **Language**: C++17 / QML
- **Database**: SQLite (本地加密存储)
- **Encryption**: Qt Cryptographic Module (AES-256)
- **Charts**: Qt Charts (饼图/柱状图/折线图)
- **Build**: CMake 3.16+

## 项目结构

```
qt-version/
├── CMakeLists.txt                    # CMake 构建配置
├── src/
│   ├── main.cpp                      # 应用入口
│   ├── backend/
│   │   ├── database.h/cpp            # SQLite 数据库管理
│   │   ├── encryption.h/cpp          # AES-256 加密/解密
│   │   ├── authmanager.h/cpp         # 用户认证管理
│   │   ├── transactionmanager.h/cpp  # 收支记录管理
│   │   ├── categorymanager.h/cpp     # 分类管理
│   │   ├── budgetmanager.h/cpp       # 预算管理
│   │   ├── userprofilemanager.h/cpp  # 个人资料管理
│   │   └── dataexporter.h/cpp        # CSV/Excel 导出
│   └── qml/
│       ├── Main.qml                  # 主窗口
│       ├── theme/
│       │   └── Theme.qml             # 温馨秋日主题
│       ├── components/
│       │   └── NavBar.qml            # 底部导航栏
│       └── pages/
│           ├── LoginPage.qml         # 登录页
│           ├── RegisterPage.qml      # 注册页
│           ├── ModeSelectPage.qml    # 模式选择页
│           ├── HomePage.qml          # 首页（月度概览）
│           ├── AddPage.qml           # 记账页
│           ├── StatsPage.qml         # 统计页
│           ├── BudgetPage.qml        # 预算页
│           ├── CategoriesPage.qml    # 分类管理页
│           ├── ProfilePage.qml       # 个人中心页
│           └── SettingsPage.qml      # 设置页
└── resources/
    └── resources.qrc                 # Qt 资源文件
```

## 构建方法

### 前置要求

- Qt 6.5 或更高版本
- CMake 3.16+
- C++17 编译器（GCC/Clang/MSVC）

### 编译步骤

```bash
mkdir build && cd build
cmake .. -DCMAKE_PREFIX_PATH=/path/to/Qt/6.x.x/gcc_64
cmake --build .
./SuiliTime
```

### Qt Creator

1. 打开 Qt Creator
2. 选择 "打开文件或项目"
3. 选择 `CMakeLists.txt`
4. 配置 Kit（Qt 6.5+）
5. 点击运行

## 功能特性

- ✅ 用户注册/登录（本地 SQLite 存储）
- ✅ 移动端/PC端双模式布局
- ✅ 收支记录增删改查
- ✅ 分类管理（支持多级树形结构）
- ✅ 月度预算管理
- ✅ 统计图表（饼图/柱状图/折线图）
- ✅ 个人中心（资料编辑、数据统计）
- ✅ CSV/Excel 数据导出
- ✅ AES-256 加密存储
- ✅ 深色/浅色主题切换
- ✅ 温馨秋日风格 UI

## 设计规范

与 Web 版本一致：
- 主色：#E8915B（暖橘）
- 收入色：#8DB580（鼠尾草绿）
- 支出色：#D4725E（赤陶色）
- 背景色：#FDF8F0（奶油白）
- 字体：Noto Sans SC
- 圆角卡片 + 柔和阴影
