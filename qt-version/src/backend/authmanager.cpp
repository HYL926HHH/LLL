#include "authmanager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

AuthManager::AuthManager(Database *db, Encryption *encryption, QObject *parent)
    : QObject(parent), m_db(db), m_encryption(encryption) {}

bool AuthManager::isLoggedIn() const { return !m_currentUserId.isEmpty(); }
QString AuthManager::currentUserEmail() const { return m_currentEmail; }
QString AuthManager::currentUserId() const { return m_currentUserId; }

void AuthManager::registerUser(const QString &email, const QString &password)
{
    if (email.isEmpty() || password.isEmpty()) {
        emit registerFailed("请填写所有字段");
        return;
    }
    if (password.length() < 6) {
        emit registerFailed("密码长度至少为6位");
        return;
    }

    QSqlQuery query(m_db->connection());
    query.prepare("SELECT id FROM user_accounts WHERE email = :email");
    query.bindValue(":email", email);
    if (query.exec() && query.next()) {
        emit registerFailed("该邮箱已注册");
        return;
    }

    QString salt = m_encryption->generateSalt();
    QString hash = m_encryption->hashPassword(password, salt);
    QString id = m_encryption->generateUuid();

    query.prepare("INSERT INTO user_accounts (id, email, password_hash, salt) VALUES (:id, :email, :hash, :salt)");
    query.bindValue(":id", id);
    query.bindValue(":email", email);
    query.bindValue(":hash", hash);
    query.bindValue(":salt", salt);

    if (!query.exec()) {
        emit registerFailed("注册失败: " + query.lastError().text());
        return;
    }

    emit registerSuccess();
}

void AuthManager::loginUser(const QString &email, const QString &password)
{
    if (email.isEmpty() || password.isEmpty()) {
        emit loginFailed("请填写邮箱和密码");
        return;
    }

    QSqlQuery query(m_db->connection());
    query.prepare("SELECT id, password_hash, salt FROM user_accounts WHERE email = :email");
    query.bindValue(":email", email);

    if (!query.exec() || !query.next()) {
        emit loginFailed("邮箱或密码错误");
        return;
    }

    QString id = query.value("id").toString();
    QString storedHash = query.value("password_hash").toString();
    QString salt = query.value("salt").toString();
    QString inputHash = m_encryption->hashPassword(password, salt);

    if (inputHash != storedHash) {
        emit loginFailed("邮箱或密码错误");
        return;
    }

    m_currentUserId = id;
    m_currentEmail = email;
    m_db->setUserId(id);
    emit authStateChanged();
    emit loginSuccess();
}

void AuthManager::logout()
{
    m_currentUserId.clear();
    m_currentEmail.clear();
    m_db->setUserId("");
    emit authStateChanged();
}
