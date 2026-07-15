#include "userprofilemanager.h"
#include <QSqlQuery>
#include <QJsonObject>
#include <QJsonDocument>
#include <QUuid>

UserProfileManager::UserProfileManager(Database *db, Encryption *enc, QObject *parent)
    : QObject(parent), m_db(db), m_enc(enc) {}

QString UserProfileManager::nickname() const { return m_profile.value("nickname").toString(); }
QString UserProfileManager::phone() const { return m_profile.value("phone").toString(); }
QString UserProfileManager::birthday() const { return m_profile.value("birthday").toString(); }
QString UserProfileManager::bio() const { return m_profile.value("bio").toString(); }

void UserProfileManager::loadProfile()
{
    m_profile.clear();
    QSqlQuery query(m_db->connection());
    query.prepare("SELECT encrypted_profile FROM user_profile WHERE user_id = :uid");
    query.bindValue(":uid", m_db->userId());
    if (query.exec() && query.next()) {
        m_profile = m_enc->decryptJson(query.value("encrypted_profile").toString(), m_db->userId()).toVariantMap();
    }
    emit profileLoaded();
}

void UserProfileManager::saveProfile(const QString &nickname, const QString &phone,
                                      const QString &birthday, const QString &bio)
{
    QString userId = m_db->userId();
    QJsonObject json;
    json["nickname"] = nickname;
    json["phone"] = phone;
    json["birthday"] = birthday;
    json["bio"] = bio;
    QString encrypted = m_enc->encrypt(
        QString::fromUtf8(QJsonDocument(json).toJson(QJsonDocument::Compact)), userId);

    QSqlQuery query(m_db->connection());
    query.prepare("SELECT id FROM user_profile WHERE user_id = :uid");
    query.bindValue(":uid", userId);
    if (query.exec() && query.next()) {
        QString id = query.value("id").toString();
        QSqlQuery update(m_db->connection());
        update.prepare("UPDATE user_profile SET encrypted_profile = :edata WHERE id = :id");
        update.bindValue(":edata", encrypted);
        update.bindValue(":id", id);
        if (!update.exec()) { emit errorOccurred("保存失败"); return; }
    } else {
        query.prepare("INSERT INTO user_profile (id, user_id, encrypted_profile) VALUES (:id, :uid, :edata)");
        query.bindValue(":id", QUuid::createUuid().toString(QUuid::WithoutBraces));
        query.bindValue(":uid", userId);
        query.bindValue(":edata", encrypted);
        if (!query.exec()) { emit errorOccurred("保存失败"); return; }
    }
    m_profile = json.toVariantMap();
    emit profileSaved();
    emit profileLoaded();
}
