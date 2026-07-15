#include "transactionmanager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QJsonObject>
#include <QJsonDocument>
#include <QDateTime>

TransactionManager::TransactionManager(Database *db, Encryption *enc, QObject *parent)
    : QObject(parent), m_db(db), m_enc(enc) {}

QVariantList TransactionManager::transactions() const { return m_transactions; }

void TransactionManager::loadTransactions(const QString &month)
{
    m_transactions.clear();
    QSqlQuery query(m_db->connection());
    QString userId = m_db->userId();

    if (month.isEmpty()) {
        query.prepare("SELECT t.*, c.name as category_name, c.icon as category_icon "
                      "FROM transactions t LEFT JOIN categories c ON t.category_id = c.id "
                      "WHERE t.user_id = :uid ORDER BY t.transaction_date DESC LIMIT 100");
    } else {
        QString startDate = month + "-01";
        QString endDate = month + "-31";
        query.prepare("SELECT t.*, c.name as category_name, c.icon as category_icon "
                      "FROM transactions t LEFT JOIN categories c ON t.category_id = c.id "
                      "WHERE t.user_id = :uid AND t.transaction_date >= :start AND t.transaction_date <= :end "
                      "ORDER BY t.transaction_date DESC");
        query.bindValue(":start", startDate);
        query.bindValue(":end", endDate);
    }
    query.bindValue(":uid", userId);

    if (!query.exec()) {
        emit errorOccurred(query.lastError().text());
        return;
    }

    while (query.next()) {
        QString encryptedData = query.value("encrypted_data").toString();
        QJsonObject plain = m_enc->decryptJson(encryptedData, userId);

        QVariantMap item;
        item["id"] = query.value("id").toString();
        item["category_id"] = query.value("category_id").toString();
        item["type"] = query.value("type").toString();
        item["transaction_date"] = query.value("transaction_date").toString();
        item["amount"] = plain["amount"].toString();
        item["note"] = plain["note"].toString();
        item["category_name"] = query.value("category_name").toString();
        item["category_icon"] = query.value("category_icon").toString();
        m_transactions.append(item);
    }
    emit transactionsLoaded();
}

void TransactionManager::addTransaction(const QString &categoryId, const QString &type,
                                         const QString &amount, const QString &date,
                                         const QString &note)
{
    QString userId = m_db->userId();
    QString id = m_enc->generateUuid();

    QJsonObject plain;
    plain["amount"] = amount;
    plain["note"] = note;
    QString encrypted = m_enc->encrypt(QString::fromUtf8(
        QJsonDocument(plain).toJson(QJsonDocument::Compact)), userId);

    QSqlQuery query(m_db->connection());
    query.prepare("INSERT INTO transactions (id, user_id, category_id, type, encrypted_data, transaction_date) "
                  "VALUES (:id, :uid, :cid, :type, :edata, :date)");
    query.bindValue(":id", id);
    query.bindValue(":uid", userId);
    query.bindValue(":cid", categoryId);
    query.bindValue(":type", type);
    query.bindValue(":edata", encrypted);
    query.bindValue(":date", date);

    if (!query.exec()) {
        emit errorOccurred("保存失败: " + query.lastError().text());
        return;
    }
    emit transactionAdded();
}

void TransactionManager::deleteTransaction(const QString &id)
{
    QSqlQuery query(m_db->connection());
    query.prepare("DELETE FROM transactions WHERE id = :id AND user_id = :uid");
    query.bindValue(":id", id);
    query.bindValue(":uid", m_db->userId());
    if (!query.exec()) {
        emit errorOccurred("删除失败");
        return;
    }
    emit transactionDeleted();
}

QVariantMap TransactionManager::getStats()
{
    QVariantMap stats;
    double totalIncome = 0, totalExpense = 0;
    int count = 0;

    QSqlQuery query(m_db->connection());
    query.prepare("SELECT encrypted_data, type FROM transactions WHERE user_id = :uid");
    query.bindValue(":uid", m_db->userId());
    if (query.exec()) {
        while (query.next()) {
            QJsonObject plain = m_enc->decryptJson(query.value("encrypted_data").toString(), m_db->userId());
            double amt = plain["amount"].toString().toDouble();
            if (query.value("type").toString() == "income") totalIncome += amt;
            else totalExpense += amt;
            count++;
        }
    }

    stats["totalIncome"] = totalIncome;
    stats["totalExpense"] = totalExpense;
    stats["count"] = count;
    stats["balance"] = totalIncome - totalExpense;
    return stats;
}
