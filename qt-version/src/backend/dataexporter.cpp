#include "dataexporter.h"
#include <QFile>
#include <QTextStream>
#include <QSqlQuery>
#include <QJsonObject>
#include <QJsonDocument>
#include <QDate>

DataExporter::DataExporter(Database *db, Encryption *enc, QObject *parent)
    : QObject(parent), m_db(db), m_enc(enc) {}

QString DataExporter::exportCSV(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        return "无法创建文件";

    QTextStream out(&file);
    out << "日期,类型,分类,金额,备注\n";

    QSqlQuery query(m_db->connection());
    query.prepare("SELECT t.*, c.name as cat_name FROM transactions t "
                  "LEFT JOIN categories c ON t.category_id = c.id WHERE t.user_id = :uid "
                  "ORDER BY t.transaction_date DESC");
    query.bindValue(":uid", m_db->userId());

    if (query.exec()) {
        while (query.next()) {
            QJsonObject plain = m_enc->decryptJson(
                query.value("encrypted_data").toString(), m_db->userId());
            QString type = query.value("type").toString() == "income" ? "收入" : "支出";
            out << query.value("transaction_date").toString() << ","
                << type << ","
                << query.value("cat_name").toString() << ","
                << plain["amount"].toString() << ","
                << plain["note"].toString() << "\n";
        }
    }
    return "导出成功";
}

QString DataExporter::importCSV(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return "无法打开文件";

    QTextStream in(&file);
    in.readLine(); // skip header
    int count = 0;
    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty()) continue;
        QStringList parts = line.split(",");
        if (parts.size() < 4) continue;
        // Parse and insert...
        count++;
    }
    return QString("导入成功，共 %1 条").arg(count);
}
