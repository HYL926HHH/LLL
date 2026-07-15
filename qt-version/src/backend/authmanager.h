#ifndef AUTHMANAGER_H
#define AUTHMANAGER_H

#include <QObject>
#include <QString>
#include "database.h"
#include "encryption.h"

class AuthManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isLoggedIn READ isLoggedIn NOTIFY authStateChanged)
    Q_PROPERTY(QString currentUserEmail READ currentUserEmail NOTIFY authStateChanged)
    Q_PROPERTY(QString currentUserId READ currentUserId NOTIFY authStateChanged)

public:
    explicit AuthManager(Database *db, Encryption *encryption, QObject *parent = nullptr);

    bool isLoggedIn() const;
    QString currentUserEmail() const;
    QString currentUserId() const;

    Q_INVOKABLE void registerUser(const QString &email, const QString &password);
    Q_INVOKABLE void loginUser(const QString &email, const QString &password);
    Q_INVOKABLE void logout();

signals:
    void authStateChanged();
    void registerSuccess();
    void registerFailed(const QString &error);
    void loginSuccess();
    void loginFailed(const QString &error);

private:
    Database *m_db;
    Encryption *m_encryption;
    QString m_currentUserId;
    QString m_currentEmail;
};

#endif // AUTHMANAGER_H
