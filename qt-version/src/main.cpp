#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QIcon>

#include "backend/database.h"
#include "backend/encryption.h"
#include "backend/authmanager.h"
#include "backend/transactionmanager.h"
#include "backend/categorymanager.h"
#include "backend/budgetmanager.h"
#include "backend/userprofilemanager.h"
#include "backend/dataexporter.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("岁里时光");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("SuiLiShiGuang");

    // Set Material style
    QQuickStyle::setStyle("Material");

    // Initialize database
    Database &db = Database::instance();
    if (!db.initialize()) {
        qCritical() << "Failed to initialize database!";
        return -1;
    }

    // Create backend managers
    Encryption encryption;
    AuthManager authManager(&db, &encryption);
    CategoryManager categoryManager(&db);
    TransactionManager transactionManager(&db, &encryption);
    BudgetManager budgetManager(&db, &encryption);
    UserProfileManager userProfileManager(&db, &encryption);
    DataExporter dataExporter(&db, &encryption);

    // QML Engine
    QQmlApplicationEngine engine;

    // Expose C++ objects to QML
    engine.rootContext()->setContextProperty("authManager", &authManager);
    engine.rootContext()->setContextProperty("categoryManager", &categoryManager);
    engine.rootContext()->setContextProperty("transactionManager", &transactionManager);
    engine.rootContext()->setContextProperty("budgetManager", &budgetManager);
    engine.rootContext()->setContextProperty("userProfileManager", &userProfileManager);
    engine.rootContext()->setContextProperty("dataExporter", &dataExporter);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("SuiLiShiGuang", "Main");

    return app.exec();
}
