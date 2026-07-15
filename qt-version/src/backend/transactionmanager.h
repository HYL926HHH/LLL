#ifndef TRANSACTIONMANAGER_H
#define TRANSACTIONMANAGER_H

#include <QObject>
#include <QVariantList>
#include "database.h"
#include "encryption.h"

class TransactionManager : public QObject
{
    Q_OBJECT
public:
    explicit TransactionManager(Database *db, Encryption *enc, QObject *parent = nullptr);
    Q_INVOKABLE void loadTransactions(const QString &month = "");
    Q_INVOKABLE void addTransaction(const QString &categoryId, const QString &type,
                                     const QString &amount, const QString &date,
                                     const QString &note);
    Q_INVOKABLE void deleteTransaction(const QString &id);
    Q_INVOKABLE QVariantMap getStats();

    QVariantList transactions() const;

signals:
    void transactionsLoaded();
    void transactionAdded();
    void transactionDeleted();
    void errorOccurred(const QString &error);

private:
    Database *m_db;
    Encryption *m_enc;
    QVariantList m_transactions;
};

#endif
