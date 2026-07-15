#include "categorymanager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QUuid>
#include <QDateTime>

CategoryManager::CategoryManager(Database *db, QObject *parent)
    : QObject(parent), m_db(db) {}

QVariantList CategoryManager::categories() const { return m_categories; }

void CategoryManager::loadCategories(const QString &type)
{
    m_categories.clear();
    QSqlQuery query(m_db->connection());

    if (type.isEmpty()) {
        query.prepare("SELECT * FROM categories WHERE user_id = :uid ORDER BY sort_order");
    } else {
        query.prepare("SELECT * FROM categories WHERE user_id = :uid AND type = :type ORDER BY sort_order");
    }
    query.bindValue(":uid", m_db->userId());
    if (!type.isEmpty()) query.bindValue(":type", type);

    if (!query.exec()) { emit errorOccurred(query.lastError().text()); return; }

    while (query.next()) {
        QVariantMap item;
        item["id"] = query.value("id").toString();
        item["name"] = query.value("name").toString();
        item["icon"] = query.value("icon").toString();
        item["type"] = query.value("type").toString();
        item["parent_id"] = query.value("parent_id").toString();
        item["sort_order"] = query.value("sort_order").toInt();
        m_categories.append(item);
    }

    // Auto-seed if empty
    if (m_categories.isEmpty()) {
        seedDefaultCategories();
        // Reload
        loadCategories(type);
        return;
    }

    emit categoriesLoaded();
}

void CategoryManager::seedDefaultCategories()
{
    struct CatDef { QString name; QString icon; QString type; int order; };
    QList<CatDef> defaults = {
        {"餐饮", "🍜", "expense", 1}, {"交通", "🚌", "expense", 2},
        {"购物", "🛒", "expense", 3}, {"娱乐", "🎮", "expense", 4},
        {"居住", "🏠", "expense", 5}, {"医疗", "💊", "expense", 6},
        {"教育", "📚", "expense", 7}, {"其他支出", "📦", "expense", 8},
        {"工资", "💰", "income", 1}, {"奖金", "🎁", "income", 2},
        {"投资", "📈", "income", 3}, {"兼职", "💼", "income", 4},
        {"其他收入", "💵", "income", 5},
    };

    QSqlQuery query(m_db->connection());
    query.prepare("INSERT INTO categories (id, user_id, name, icon, type, sort_order) "
                  "VALUES (:id, :uid, :name, :icon, :type, :order)");

    for (const auto &cat : defaults) {
        query.bindValue(":id", QUuid::createUuid().toString(QUuid::WithoutBraces));
        query.bindValue(":uid", m_db->userId());
        query.bindValue(":name", cat.name);
        query.bindValue(":icon", cat.icon);
        query.bindValue(":type", cat.type);
        query.bindValue(":order", cat.order);
        query.exec();
    }
}

void CategoryManager::addCategory(const QString &name, const QString &icon,
                                   const QString &type, const QString &parentId)
{
    QSqlQuery query(m_db->connection());
    query.prepare("INSERT INTO categories (id, user_id, name, icon, type, parent_id) "
                  "VALUES (:id, :uid, :name, :icon, :type, :pid)");
    query.bindValue(":id", QUuid::createUuid().toString(QUuid::WithoutBraces));
    query.bindValue(":uid", m_db->userId());
    query.bindValue(":name", name);
    query.bindValue(":icon", icon);
    query.bindValue(":type", type);
    query.bindValue(":pid", parentId.isEmpty() ? QVariant(QVariant::String) : parentId);

    if (!query.exec()) { emit errorOccurred("添加失败"); return; }
    emit categoryAdded();
}

void CategoryManager::deleteCategory(const QString &id)
{
    QSqlQuery query(m_db->connection());
    query.prepare("DELETE FROM categories WHERE id = :id AND user_id = :uid");
    query.bindValue(":id", id);
    query.bindValue(":uid", m_db->userId());
    if (!query.exec()) { emit errorOccurred("删除失败"); return; }
    emit categoryDeleted();
}
