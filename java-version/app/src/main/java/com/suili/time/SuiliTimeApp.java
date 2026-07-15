package com.suili.time;

import android.app.Application;
import com.suili.time.data.DatabaseHelper;

/**
 * 岁里时光 Application 入口
 */
public class SuiliTimeApp extends Application {

    private static SuiliTimeApp instance;
    private DatabaseHelper dbHelper;

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;
        dbHelper = new DatabaseHelper(this);
    }

    public static SuiliTimeApp getInstance() {
        return instance;
    }

    public DatabaseHelper getDatabaseHelper() {
        return dbHelper;
    }
}
