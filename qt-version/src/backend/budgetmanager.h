#ifndef BUDGETMANAGER_H
#define BUDGETMANAGER_H
#include <QObject>
#include <QVariantMap>
#include "database.h"
#include "encryption.h"

class BudgetManager : public QObject
{
    Q_OBJECT
public:
    explicit BudgetManager(Database *db, Encryption *enc, QObject *parent = nullptr);
    Q_INVOKABLE void loadBudget(const QString &month);
    Q_INVOKABLE void saveBudget(const QString &month, const QString &amount);
    Q_INVOKABLE QVariantMap currentBudget() const;

signals:
    void budgetLoaded();
    void budgetSaved();
    void errorOccurred(const QString &error);

private:
    Database *m_db;
    Encryption *m_enc;
    QVariantMap m_budget;
};
#endif
