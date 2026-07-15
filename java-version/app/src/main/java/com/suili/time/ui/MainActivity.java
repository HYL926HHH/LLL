package com.suili.time.ui;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.suili.time.R;
import com.suili.time.SuiliTimeApp;
import com.suili.time.ui.fragments.HomeFragment;
import com.suili.time.ui.fragments.AddFragment;
import com.suili.time.ui.fragments.StatsFragment;
import com.suili.time.ui.fragments.BudgetFragment;
import com.suili.time.ui.fragments.ProfileFragment;

/**
 * 主界面 - 底部导航
 */
public class MainActivity extends AppCompatActivity {

    private static final String PREF_NAME = "suili_prefs";
    private static final String KEY_USER_ID = "user_id";
    private static final String KEY_MODE = "app_mode";

    private String currentUserId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // 检查登录状态
        SharedPreferences prefs = getSharedPreferences(PREF_NAME, MODE_PRIVATE);
        currentUserId = prefs.getString(KEY_USER_ID, null);

        if (currentUserId == null) {
            startActivity(new Intent(this, LoginActivity.class));
            finish();
            return;
        }

        // 检查是否已选择模式
        String mode = prefs.getString(KEY_MODE, null);
        if (mode == null) {
            startActivity(new Intent(this, ModeSelectActivity.class));
            finish();
            return;
        }

        setContentView(R.layout.activity_main);

        // 初始化默认分类
        SuiliTimeApp.getInstance().getDatabaseHelper().seedDefaultCategories(currentUserId);

        // 设置底部导航
        setupBottomNavigation();

        // 默认显示首页
        if (savedInstanceState == null) {
            loadFragment(new HomeFragment());
        }
    }

    private void setupBottomNavigation() {
        BottomNavigationView bottomNav = findViewById(R.id.bottom_navigation);

        bottomNav.setOnItemSelectedListener(item -> {
            Fragment fragment = null;
            int itemId = item.getItemId();

            if (itemId == R.id.nav_home) {
                fragment = new HomeFragment();
            } else if (itemId == R.id.nav_add) {
                fragment = new AddFragment();
            } else if (itemId == R.id.nav_stats) {
                fragment = new StatsFragment();
            } else if (itemId == R.id.nav_budget) {
                fragment = new BudgetFragment();
            } else if (itemId == R.id.nav_profile) {
                fragment = new ProfileFragment();
            }

            if (fragment != null) {
                loadFragment(fragment);
                return true;
            }
            return false;
        });
    }

    private void loadFragment(Fragment fragment) {
        getSupportFragmentManager()
                .beginTransaction()
                .replace(R.id.fragment_container, fragment)
                .commit();
    }

    public String getCurrentUserId() {
        return currentUserId;
    }
}
