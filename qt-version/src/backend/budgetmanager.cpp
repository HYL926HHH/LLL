#include "budgetmanager.h"
#include <QSqlQuery>
#include <QJsonObject>
#include <QJsonDocument>
#include <QUuid>

BudgetManager::BudgetManager(Database *db, Encryption *enc, QObject *parent)
    : QObject(parent), m_db(db), m_enc(enc) {}

QVariantMap BudgetManager::currentBudget() const { return m_budget; }

void BudgetManager::loadBudget(const QString &month)
{
    m_budget.clear();
    QSqlQuery query(m_db->connection());
    query.prepare("SELECT * FROM budgets WHERE user_id = :uid AND month = :month");
    query.bindValue(":uid", m_db->userId());
    query.bindValue(":month", month);

    if (query.exec() && query.next()) {
        QJsonObject plain = m_enc->decryptJson(query.value("encrypted_amount").toString(), m_db->userId());
        m_budget["id"] = query.value("id").toString();
        m_budget["month"] = month;
        m_budget["amount"] = plain["amount"].toString();
    }
    emit budgetLoaded();
}

void BudgetManager::saveBudget(const QString &month, const QString &amount)
{
    QString userId = m_db->userId();
    QJsonObject plain;
    plain["amount"] = amount;
    QString encrypted = m_enc->encrypt(
        QString::fromUtf8(QJsonDocument(plain).toJson(QJsonDocument::Compact)), userId);

    QSqlQuery query(m_db->connection());
    // Check if exists
    query.prepare("SELECT id FROM budgets WHERE user_id = :uid AND month = :month");
    query.bindValue(":uid", userId);
    query.bindValue(":month", month);
    if (query.exec() && query.next()) {
        // Update
        QString id = query.value("id").toString();
        QSqlQuery update(m_db->connection());
        update.prepare("UPDATE budgets SET encrypted_amount = :edata WHERE id = :id");
        update.bindValue(":edata", encrypted);
        update.bindValue(":id", id);
        if (!update.exec()) { emit errorOccurred("保存失败"); return; }
    } else {
        // Insert
        query.prepare("INSERT INTO budgets (id, user_id, month, encrypted_amount) VALUES (:id, :uid, :month, :edata)");
        query.bindValue(":id", QUuid::createUuid().toString(QUuid::WithoutBraces));
        query.bindValue(":uid", userId);
        query.bindValue(":month", month);
        query.bindValue(":edata", encrypted);
        if (!query.exec()) { emit errorOccurred("保存失败"); return; }
    }
    emit budgetSaved();
}
