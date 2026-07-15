cmake_minimum_required(VERSION 3.21)
project(SuiLiShiGuang VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Widgets
    Quick
    QuickControls2
    Sql
    Network
    Crypto
)

set(SOURCES
    src/main.cpp
    src/backend/database.cpp
    src/backend/encryption.cpp
    src/backend/authmanager.cpp
    src/backend/transactionmanager.cpp
    src/backend/categorymanager.cpp
    src/backend/budgetmanager.cpp
    src/backend/userprofilemanager.cpp
    src/backend/dataexporter.cpp
)

set(HEADERS
    src/backend/database.h
    src/backend/encryption.h
    src/backend/authmanager.h
    src/backend/transactionmanager.h
    src/backend/categorymanager.h
    src/backend/budgetmanager.h
    src/backend/userprofilemanager.h
    src/backend/dataexporter.h
)

qt_add_executable(SuiLiShiGuang ${SOURCES} ${HEADERS})

qt_add_qml_module(SuiLiShiGuang
    URI SuiLiShiGuang
    VERSION 1.0
    QML_FILES
        src/qml/Main.qml
        src/qml/pages/LoginPage.qml
        src/qml/pages/RegisterPage.qml
        src/qml/pages/ModeSelectPage.qml
        src/qml/pages/HomePage.qml
        src/qml/pages/AddPage.qml
        src/qml/pages/StatsPage.qml
        src/qml/pages/BudgetPage.qml
        src/qml/pages/CategoriesPage.qml
        src/qml/pages/ProfilePage.qml
        src/qml/pages/SettingsPage.qml
        src/qml/components/NavBar.qml
        src/qml/components/SideBar.qml
        src/qml/components/CategoryPicker.qml
        src/qml/components/ConfirmDialog.qml
        src/qml/theme/Theme.qml
    RESOURCES
        resources/resources.qrc
)

target_link_libraries(SuiLiShiGuang PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Sql
    Qt6::Network
)
