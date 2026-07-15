package com.suili.time.ui;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.widget.Button;

import androidx.appcompat.app.AppCompatActivity;

import com.suili.time.R;

/**
 * 模式选择界面 - 移动端/PC端
 */
public class ModeSelectActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_mode_select);

        Button btnMobile = findViewById(R.id.btn_mobile);
        Button btnPc = findViewById(R.id.btn_pc);

        btnMobile.setOnClickListener(v -> selectMode("mobile"));
        btnPc.setOnClickListener(v -> selectMode("pc"));
    }

    private void selectMode(String mode) {
        SharedPreferences prefs = getSharedPreferences("suili_prefs", MODE_PRIVATE);
        prefs.edit().putString("app_mode", mode).apply();

        Intent intent = new Intent(this, MainActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
        finish();
    }
}
