#include "database.h"
#include <QDebug>

Database &Database::instance()
{
    static Database inst;
    return inst;
}

Database::Database(QObject *parent) : QObject(parent) {}

bool Database::initialize()
{
    QString dbPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (dbPath.isEmpty()) {
        qCritical() << "Cannot determine app data location";
        return false;
    }

    QDir dir(dbPath);
    if (!dir.exists()) dir.mkpath(".");

    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(dbPath + "/suili.db");

    if (!m_db.open()) {
        qCritical() << "Cannot open database:" << m_db.lastError().text();
        return false;
    }

    return createTables();
}

bool Database::createTables()
{
    QSqlQuery query(m_db);

    // Categories table
    bool ok = query.exec(
        "CREATE TABLE IF NOT EXISTS categories ("
        "  id TEXT PRIMARY KEY,"
        "  user_id TEXT NOT NULL,"
        "  name TEXT NOT NULL,"
        "  icon TEXT,"
        "  parent_id TEXT,"
        "  type TEXT NOT NULL CHECK(type IN ('income','expense')),"
        "  sort_order INTEGER NOT NULL DEFAULT 0,"
        "  created_at TEXT NOT NULL DEFAULT (datetime('now')),"
        "  updated_at TEXT"
        ")");
    if (!ok) { qCritical() << "Create categories:" << query.lastError().text(); return false; }

    // Transactions table (encrypted_data stores AES-encrypted JSON)
    ok = query.exec(
        "CREATE TABLE IF NOT EXISTS transactions ("
        "  id TEXT PRIMARY KEY,"
        "  user_id TEXT NOT NULL,"
        "  category_id TEXT NOT NULL,"
        "  type TEXT NOT NULL CHECK(type IN ('income','expense')),"
        "  encrypted_data TEXT NOT NULL,"
        "  transaction_date TEXT NOT NULL,"
        "  created_at TEXT NOT NULL DEFAULT (datetime('now')),"
        "  updated_at TEXT,"
        "  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE"
        ")");
    if (!ok) { qCritical() << "Create transactions:" << query.lastError().text(); return false; }

    // Budgets table (encrypted_amount stores AES-encrypted JSON)
    ok = query.exec(
        "CREATE TABLE IF NOT EXISTS budgets ("
        "  id TEXT PRIMARY KEY,"
        "  user_id TEXT NOT NULL,"
        "  month TEXT NOT NULL,"
        "  encrypted_amount TEXT NOT NULL,"
        "  created_at TEXT NOT NULL DEFAULT (datetime('now')),"
        "  updated_at TEXT,"
        "  UNIQUE(user_id, month)"
        ")");
    if (!ok) { qCritical() << "Create budgets:" << query.lastError().text(); return false; }

    // User profile table (encrypted_profile stores AES-encrypted JSON)
    ok = query.exec(
        "CREATE TABLE IF NOT EXISTS user_profile ("
        "  id TEXT PRIMARY KEY,"
        "  user_id TEXT NOT NULL UNIQUE,"
        "  encrypted_profile TEXT NOT NULL,"
        "  created_at TEXT NOT NULL DEFAULT (datetime('now')),"
        "  updated_at TEXT"
        ")");
    if (!ok) { qCritical() << "Create user_profile:" << query.lastError().text(); return false; }

    // User accounts table (local auth)
    ok = query.exec(
        "CREATE TABLE IF NOT EXISTS user_accounts ("
        "  id TEXT PRIMARY KEY,"
        "  email TEXT NOT NULL UNIQUE,"
        "  password_hash TEXT NOT NULL,"
        "  salt TEXT NOT NULL,"
        "  created_at TEXT NOT NULL DEFAULT (datetime('now'))"
        ")");
    if (!ok) { qCritical() << "Create user_accounts:" << query.lastError().text(); return false; }

    qDebug() << "Database tables created successfully";
    return true;
}

QSqlDatabase Database::connection() const { return m_db; }

QString Database::userId() const { return m_userId; }
void Database::setUserId(const QString &userId) { m_userId = userId; }
