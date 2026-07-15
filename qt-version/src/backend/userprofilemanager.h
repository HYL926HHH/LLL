#ifndef USERPROFILEMANAGER_H
#define USERPROFILEMANAGER_H
#include <QObject>
#include <QVariantMap>
#include "database.h"
#include "encryption.h"

class UserProfileManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString nickname READ nickname NOTIFY profileLoaded)
    Q_PROPERTY(QString phone READ phone NOTIFY profileLoaded)
    Q_PROPERTY(QString birthday READ birthday NOTIFY profileLoaded)
    Q_PROPERTY(QString bio READ bio NOTIFY profileLoaded)
public:
    explicit UserProfileManager(Database *db, Encryption *enc, QObject *parent = nullptr);
    Q_INVOKABLE void loadProfile();
    Q_INVOKABLE void saveProfile(const QString &nickname, const QString &phone,
                                  const QString &birthday, const QString &bio);
    QString nickname() const;
    QString phone() const;
    QString birthday() const;
    QString bio() const;
signals:
    void profileLoaded();
    void profileSaved();
    void errorOccurred(const QString &error);
private:
    Database *m_db; Encryption *m_enc;
    QVariantMap m_profile;
};
#endif
