#ifndef DATABASE_H
#define DATABASE_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QString>
#include <QStandardPaths>

class Database : public QObject
{
    Q_OBJECT

public:
    static Database &instance();
    bool initialize();
    QSqlDatabase connection() const;
    QString userId() const;
    void setUserId(const QString &userId);

private:
    explicit Database(QObject *parent = nullptr);
    bool createTables();

    QSqlDatabase m_db;
    QString m_userId;
};

#endif // DATABASE_H
