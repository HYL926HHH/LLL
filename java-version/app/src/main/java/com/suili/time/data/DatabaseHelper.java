package com.suili.time.data;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import com.suili.time.util.EncryptionUtil;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 数据库帮助类 - SQLite 本地存储
 */
public class DatabaseHelper extends SQLiteOpenHelper {

    private static final String DB_NAME = "suili_time.db";
    private static final int DB_VERSION = 1;

    // 表名
    public static final String TABLE_USERS = "users";
    public static final String TABLE_CATEGORIES = "categories";
    public static final String TABLE_TRANSACTIONS = "transactions";
    public static final String TABLE_BUDGETS = "budgets";
    public static final String TABLE_USER_PROFILE = "user_profile";

    private final EncryptionUtil encryptionUtil;

    public DatabaseHelper(Context context) {
        super(context, DB_NAME, null, DB_VERSION);
        encryptionUtil = new EncryptionUtil(context);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        // 用户表
        db.execSQL("CREATE TABLE " + TABLE_USERS + " (" +
                "id TEXT PRIMARY KEY, " +
                "email TEXT UNIQUE NOT NULL, " +
                "password_hash TEXT NOT NULL, " +
                "created_at TEXT DEFAULT (datetime('now'))" +
                ")");

        // 分类表
        db.execSQL("CREATE TABLE " + TABLE_CATEGORIES + " (" +
                "id TEXT PRIMARY KEY, " +
                "user_id TEXT NOT NULL, " +
                "name TEXT NOT NULL, " +
                "icon TEXT, " +
                "parent_id TEXT, " +
                "type TEXT NOT NULL CHECK(type IN ('income','expense')), " +
                "sort_order INTEGER DEFAULT 0, " +
                "created_at TEXT DEFAULT (datetime('now')), " +
                "FOREIGN KEY(user_id) REFERENCES users(id), " +
                "FOREIGN KEY(parent_id) REFERENCES categories(id) ON DELETE SET NULL" +
                ")");

        // 收支记录表（加密存储）
        db.execSQL("CREATE TABLE " + TABLE_TRANSACTIONS + " (" +
                "id TEXT PRIMARY KEY, " +
                "user_id TEXT NOT NULL, " +
                "category_id TEXT NOT NULL, " +
                "type TEXT NOT NULL CHECK(type IN ('income','expense')), " +
                "encrypted_data TEXT NOT NULL, " +
                "transaction_date TEXT NOT NULL, " +
                "created_at TEXT DEFAULT (datetime('now')), " +
                "FOREIGN KEY(user_id) REFERENCES users(id), " +
                "FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE CASCADE" +
                ")");

        // 预算表（金额加密）
        db.execSQL("CREATE TABLE " + TABLE_BUDGETS + " (" +
                "id TEXT PRIMARY KEY, " +
                "user_id TEXT NOT NULL, " +
                "month TEXT NOT NULL, " +
                "encrypted_amount TEXT NOT NULL, " +
                "created_at TEXT DEFAULT (datetime('now')), " +
                "UNIQUE(user_id, month), " +
                "FOREIGN KEY(user_id) REFERENCES users(id)" +
                ")");

        // 用户资料表（加密存储）
        db.execSQL("CREATE TABLE " + TABLE_USER_PROFILE + " (" +
                "id TEXT PRIMARY KEY, " +
                "user_id TEXT UNIQUE NOT NULL, " +
                "encrypted_profile TEXT NOT NULL, " +
                "created_at TEXT DEFAULT (datetime('now')), " +
                "FOREIGN KEY(user_id) REFERENCES users(id)" +
                ")");

        // 创建索引
        db.execSQL("CREATE INDEX idx_categories_user ON categories(user_id)");
        db.execSQL("CREATE INDEX idx_categories_type ON categories(type)");
        db.execSQL("CREATE INDEX idx_transactions_user ON transactions(user_id)");
        db.execSQL("CREATE INDEX idx_transactions_date ON transactions(transaction_date)");
        db.execSQL("CREATE INDEX idx_budgets_user ON budgets(user_id)");
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_USER_PROFILE);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_BUDGETS);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_TRANSACTIONS);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_CATEGORIES);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_USERS);
        onCreate(db);
    }

    // ========== 用户操作 ==========

    public String createUser(String email, String password) {
        SQLiteDatabase db = getWritableDatabase();
        String id = UUID.randomUUID().toString();
        String passwordHash = encryptionUtil.hashPassword(password);

        ContentValues values = new ContentValues();
        values.put("id", id);
        values.put("email", email);
        values.put("password_hash", passwordHash);

        long result = db.insert(TABLE_USERS, null, values);
        return result > 0 ? id : null;
    }

    public String authenticateUser(String email, String password) {
        SQLiteDatabase db = getReadableDatabase();
        Cursor cursor = db.query(TABLE_USERS, new String[]{"id", "password_hash"},
                "email = ?", new String[]{email}, null, null, null);

        if (cursor.moveToFirst()) {
            String id = cursor.getString(0);
            String storedHash = cursor.getString(1);
            cursor.close();

            if (encryptionUtil.verifyPassword(password, storedHash)) {
                return id;
            }
        }
        cursor.close();
        return null;
    }

    // ========== 分类操作 ==========

    public String createCategory(String userId, String name, String icon, String parentId, String type, int sortOrder) {
        SQLiteDatabase db = getWritableDatabase();
        String id = UUID.randomUUID().toString();

        ContentValues values = new ContentValues();
        values.put("id", id);
        values.put("user_id", userId);
        values.put("name", name);
        values.put("icon", icon);
        values.put("parent_id", parentId);
        values.put("type", type);
        values.put("sort_order", sortOrder);

        long result = db.insert(TABLE_CATEGORIES, null, values);
        return result > 0 ? id : null;
    }

    public List<Map<String, Object>> getCategories(String userId, String type) {
        List<Map<String, Object>> list = new ArrayList<>();
        SQLiteDatabase db = getReadableDatabase();

        String selection = "user_id = ?";
        String[] selectionArgs = new String[]{userId};
        if (type != null) {
            selection += " AND type = ?";
            selectionArgs = new String[]{userId, type};
        }

        Cursor cursor = db.query(TABLE_CATEGORIES, null, selection, selectionArgs,
                null, null, "sort_order ASC");

        while (cursor.moveToNext()) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", cursor.getString(cursor.getColumnIndexOrThrow("id")));
            item.put("name", cursor.getString(cursor.getColumnIndexOrThrow("name")));
            item.put("icon", cursor.getString(cursor.getColumnIndexOrThrow("icon")));
            item.put("parent_id", cursor.getString(cursor.getColumnIndexOrThrow("parent_id")));
            item.put("type", cursor.getString(cursor.getColumnIndexOrThrow("type")));
            item.put("sort_order", cursor.getInt(cursor.getColumnIndexOrThrow("sort_order")));
            list.add(item);
        }
        cursor.close();
        return list;
    }

    public void seedDefaultCategories(String userId) {
        SQLiteDatabase db = getReadableDatabase();
        Cursor cursor = db.query(TABLE_CATEGORIES, new String[]{"COUNT(*)"},
                "user_id = ?", new String[]{userId}, null, null, null);
        cursor.moveToFirst();
        int count = cursor.getInt(0);
        cursor.close();

        if (count == 0) {
            // 支出分类
            createCategory(userId, "餐饮", "🍜", null, "expense", 1);
            createCategory(userId, "交通", "🚌", null, "expense", 2);
            createCategory(userId, "购物", "🛒", null, "expense", 3);
            createCategory(userId, "娱乐", "🎮", null, "expense", 4);
            createCategory(userId, "居住", "🏠", null, "expense", 5);
            createCategory(userId, "医疗", "💊", null, "expense", 6);
            createCategory(userId, "教育", "📚", null, "expense", 7);
            createCategory(userId, "其他支出", "📦", null, "expense", 8);
            // 收入分类
            createCategory(userId, "工资", "💰", null, "income", 1);
            createCategory(userId, "奖金", "🎁", null, "income", 2);
            createCategory(userId, "投资", "📈", null, "income", 3);
            createCategory(userId, "兼职", "💼", null, "income", 4);
            createCategory(userId, "其他收入", "💵", null, "income", 5);
        }
    }

    // ========== 收支记录操作 ==========

    public String createTransaction(String userId, String categoryId, String type,
                                     String amount, String note, String date) {
        SQLiteDatabase db = getWritableDatabase();
        String id = UUID.randomUUID().toString();

        // 加密敏感数据
        String jsonData = String.format("{\"amount\":\"%s\",\"note\":\"%s\"}", amount, note != null ? note : "");
        String encryptedData = encryptionUtil.encrypt(jsonData, userId);

        ContentValues values = new ContentValues();
        values.put("id", id);
        values.put("user_id", userId);
        values.put("category_id", categoryId);
        values.put("type", type);
        values.put("encrypted_data", encryptedData);
        values.put("transaction_date", date);

        long result = db.insert(TABLE_TRANSACTIONS, null, values);
        return result > 0 ? id : null;
    }

    public List<Map<String, Object>> getTransactions(String userId, String month) {
        List<Map<String, Object>> list = new ArrayList<>();
        SQLiteDatabase db = getReadableDatabase();

        String selection = "user_id = ?";
        String[] selectionArgs;
        if (month != null) {
            selection += " AND transaction_date LIKE ?";
            selectionArgs = new String[]{userId, month + "%"};
        } else {
            selectionArgs = new String[]{userId};
        }

        Cursor cursor = db.query(TABLE_TRANSACTIONS, null, selection, selectionArgs,
                null, null, "transaction_date DESC");

        while (cursor.moveToNext()) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", cursor.getString(cursor.getColumnIndexOrThrow("id")));
            item.put("category_id", cursor.getString(cursor.getColumnIndexOrThrow("category_id")));
            item.put("type", cursor.getString(cursor.getColumnIndexOrThrow("type")));
            item.put("transaction_date", cursor.getString(cursor.getColumnIndexOrThrow("transaction_date")));

            // 解密数据
            String encrypted = cursor.getString(cursor.getColumnIndexOrThrow("encrypted_data"));
            String decrypted = encryptionUtil.decrypt(encrypted, userId);
            item.put("raw_data", decrypted);

            list.add(item);
        }
        cursor.close();
        return list;
    }

    // ========== 预算操作 ==========

    public String setBudget(String userId, String month, String amount) {
        SQLiteDatabase db = getWritableDatabase();

        // 先检查是否已存在
        Cursor cursor = db.query(TABLE_BUDGETS, new String[]{"id"},
                "user_id = ? AND month = ?", new String[]{userId, month}, null, null, null);

        if (cursor.moveToFirst()) {
            String id = cursor.getString(0);
            cursor.close();
            // 更新
            String encrypted = encryptionUtil.encrypt(
                    String.format("{\"amount\":\"%s\"}", amount), userId);
            ContentValues values = new ContentValues();
            values.put("encrypted_amount", encrypted);
            db.update(TABLE_BUDGETS, values, "id = ?", new String[]{id});
            return id;
        }
        cursor.close();

        // 新增
        String id = UUID.randomUUID().toString();
        String encrypted = encryptionUtil.encrypt(
                String.format("{\"amount\":\"%s\"}", amount), userId);

        ContentValues values = new ContentValues();
        values.put("id", id);
        values.put("user_id", userId);
        values.put("month", month);
        values.put("encrypted_amount", encrypted);

        long result = db.insert(TABLE_BUDGETS, null, values);
        return result > 0 ? id : null;
    }

    public Map<String, Object> getBudget(String userId, String month) {
        SQLiteDatabase db = getReadableDatabase();
        Cursor cursor = db.query(TABLE_BUDGETS, null,
                "user_id = ? AND month = ?", new String[]{userId, month}, null, null, null);

        Map<String, Object> result = null;
        if (cursor.moveToFirst()) {
            result = new HashMap<>();
            result.put("id", cursor.getString(cursor.getColumnIndexOrThrow("id")));
            result.put("month", cursor.getString(cursor.getColumnIndexOrThrow("month")));

            String encrypted = cursor.getString(cursor.getColumnIndexOrThrow("encrypted_amount"));
            String decrypted = encryptionUtil.decrypt(encrypted, userId);
            result.put("raw_data", decrypted);
        }
        cursor.close();
        return result;
    }

    // ========== 用户资料操作 ==========

    public void saveUserProfile(String userId, String nickname, String phone, String birthday, String bio) {
        SQLiteDatabase db = getWritableDatabase();

        String jsonData = String.format(
                "{\"nickname\":\"%s\",\"phone\":\"%s\",\"birthday\":\"%s\",\"bio\":\"%s\"}",
                nickname, phone, birthday, bio);
        String encrypted = encryptionUtil.encrypt(jsonData, userId);

        Cursor cursor = db.query(TABLE_USER_PROFILE, new String[]{"id"},
                "user_id = ?", new String[]{userId}, null, null, null);

        if (cursor.moveToFirst()) {
            String id = cursor.getString(0);
            cursor.close();
            ContentValues values = new ContentValues();
            values.put("encrypted_profile", encrypted);
            db.update(TABLE_USER_PROFILE, values, "id = ?", new String[]{id});
        } else {
            cursor.close();
            String id = UUID.randomUUID().toString();
            ContentValues values = new ContentValues();
            values.put("id", id);
            values.put("user_id", userId);
            values.put("encrypted_profile", encrypted);
            db.insert(TABLE_USER_PROFILE, null, values);
        }
    }

    public Map<String, Object> getUserProfile(String userId) {
        SQLiteDatabase db = getReadableDatabase();
        Cursor cursor = db.query(TABLE_USER_PROFILE, null,
                "user_id = ?", new String[]{userId}, null, null, null);

        Map<String, Object> result = null;
        if (cursor.moveToFirst()) {
            result = new HashMap<>();
            String encrypted = cursor.getString(cursor.getColumnIndexOrThrow("encrypted_profile"));
            String decrypted = encryptionUtil.decrypt(encrypted, userId);
            result.put("raw_data", decrypted);
        }
        cursor.close();
        return result;
    }
}
