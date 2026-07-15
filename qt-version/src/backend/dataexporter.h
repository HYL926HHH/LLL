#ifndef DATAEXPORTER_H
#define DATAEXPORTER_H
#include <QObject>
#include <QString>
#include "database.h"
#include "encryption.h"

class DataExporter : public QObject
{
    Q_OBJECT
public:
    explicit DataExporter(Database *db, Encryption *enc, QObject *parent = nullptr);
    Q_INVOKABLE QString exportCSV(const QString &filePath);
    Q_INVOKABLE QString importCSV(const QString &filePath);
private:
    Database *m_db; Encryption *m_enc;
};
#endif
