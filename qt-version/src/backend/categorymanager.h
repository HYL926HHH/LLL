#ifndef CATEGORYMANAGER_H
#define CATEGORYMANAGER_H

#include <QObject>
#include <QVariantList>
#include "database.h"

class CategoryManager : public QObject
{
    Q_OBJECT
public:
    explicit CategoryManager(Database *db, QObject *parent = nullptr);
    Q_INVOKABLE void loadCategories(const QString &type = "");
    Q_INVOKABLE void addCategory(const QString &name, const QString &icon,
                                  const QString &type, const QString &parentId = "");
    Q_INVOKABLE void deleteCategory(const QString &id);
    Q_INVOKABLE void seedDefaultCategories();
    QVariantList categories() const;

signals:
    void categoriesLoaded();
    void categoryAdded();
    void categoryDeleted();
    void errorOccurred(const QString &error);

private:
    Database *m_db;
    QVariantList m_categories;
};

#endif
