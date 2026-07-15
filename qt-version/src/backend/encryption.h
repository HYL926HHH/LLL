#ifndef ENCRYPTION_H
#define ENCRYPTION_H

#include <QString>
#include <QJsonObject>

class Encryption
{
public:
    Encryption();

    QString encrypt(const QString &plainText, const QString &userId) const;
    QString decrypt(const QString &cipherText, const QString &userId) const;

    QJsonObject encryptJson(const QJsonObject &json, const QString &userId) const;
    QJsonObject decryptJson(const QString &cipherText, const QString &userId) const;

    QString hashPassword(const QString &password, const QString &salt) const;
    QString generateSalt() const;
    QString generateUuid() const;

private:
    QByteArray deriveKey(const QString &userId) const;
    static const QString SALT_PREFIX;
};

#endif // ENCRYPTION_H
