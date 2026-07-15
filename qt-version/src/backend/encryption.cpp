#include "encryption.h"
#include <QCryptographicHash>
#include <QJsonDocument>
#include <QUuid>
#include <QRandomGenerator>
#include <QByteArray>

const QString Encryption::SALT_PREFIX = "suili-v1-encrypt";

Encryption::Encryption() {}

QByteArray Encryption::deriveKey(const QString &userId) const
{
    QString combined = SALT_PREFIX + "-" + userId;
    return QCryptographicHash::hash(combined.toUtf8(), QCryptographicHash::Sha256);
}

QString Encryption::encrypt(const QString &plainText, const QString &userId) const
{
    QByteArray key = deriveKey(userId);
    QByteArray data = plainText.toUtf8();

    // Simple XOR encryption with key (for demo; use Qt Cryptographic module in production)
    QByteArray encrypted;
    encrypted.reserve(data.size());
    for (int i = 0; i < data.size(); ++i) {
        encrypted.append(data[i] ^ key[i % key.size()]);
    }

    return encrypted.toBase64();
}

QString Encryption::decrypt(const QString &cipherText, const QString &userId) const
{
    QByteArray key = deriveKey(userId);
    QByteArray data = QByteArray::fromBase64(cipherText.toUtf8());

    QByteArray decrypted;
    decrypted.reserve(data.size());
    for (int i = 0; i < data.size(); ++i) {
        decrypted.append(data[i] ^ key[i % key.size()]);
    }

    return QString::fromUtf8(decrypted);
}

QJsonObject Encryption::encryptJson(const QJsonObject &json, const QString &userId) const
{
    QJsonObject result;
    // Store encrypted as a single field
    QJsonDocument doc(json);
    QString encrypted = encrypt(QString::fromUtf8(doc.toJson(QJsonDocument::Compact)), userId);
    result["encrypted"] = encrypted;
    return result;
}

QJsonObject Encryption::decryptJson(const QString &cipherText, const QString &userId) const
{
    QString decrypted = decrypt(cipherText, userId);
    QJsonDocument doc = QJsonDocument::fromJson(decrypted.toUtf8());
    return doc.object();
}

QString Encryption::hashPassword(const QString &password, const QString &salt) const
{
    QString combined = password + salt;
    QByteArray hash = QCryptographicHash::hash(combined.toUtf8(), QCryptographicHash::Sha256);
    return hash.toHex();
}

QString Encryption::generateSalt() const
{
    QByteArray bytes(16, 0);
    for (int i = 0; i < 16; ++i) {
        bytes[i] = static_cast<char>(QRandomGenerator::global()->bounded(256));
    }
    return bytes.toHex();
}

QString Encryption::generateUuid() const
{
    return QUuid::createUuid().toString(QUuid::WithoutBraces);
}
