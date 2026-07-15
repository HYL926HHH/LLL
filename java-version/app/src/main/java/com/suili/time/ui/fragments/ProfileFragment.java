package com.suili.time.ui.fragments;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.suili.time.R;
import com.suili.time.SuiliTimeApp;
import com.suili.time.data.DatabaseHelper;
import com.suili.time.ui.LoginActivity;
import com.suili.time.ui.MainActivity;

import java.util.List;
import java.util.Map;

/**
 * 个人中心界面
 */
public class ProfileFragment extends Fragment {

    private TextView tvEmail, tvNickname, tvTransactionCount;
    private Button btnLogout;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_profile, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        tvEmail = view.findViewById(R.id.tv_email);
        tvNickname = view.findViewById(R.id.tv_nickname);
        tvTransactionCount = view.findViewById(R.id.tv_transaction_count);
        btnLogout = view.findViewById(R.id.btn_logout);

        btnLogout.setOnClickListener(v -> logout());
        loadProfile();
    }

    private void loadProfile() {
        String userId = ((MainActivity) requireActivity()).getCurrentUserId();
        DatabaseHelper dbHelper = SuiliTimeApp.getInstance().getDatabaseHelper();

        // 获取交易统计
        List<Map<String, Object>> transactions = dbHelper.getTransactions(userId, null);
        tvTransactionCount.setText("共 " + transactions.size() + " 笔记录");

        // 获取个人资料
        Map<String, Object> profile = dbHelper.getUserProfile(userId);
        if (profile != null) {
            String rawData = (String) profile.get("raw_data");
            tvNickname.setText(parseNicknameFromJson(rawData));
        } else {
            tvNickname.setText("未设置昵称");
        }
    }

    private String parseNicknameFromJson(String json) {
        try {
            int start = json.indexOf("\"nickname\":\"") + 12;
            int end = json.indexOf("\"", start);
            return json.substring(start, end);
        } catch (Exception e) {
            return "未设置昵称";
        }
    }

    private void logout() {
        SharedPreferences prefs = requireContext().getSharedPreferences("suili_prefs", 0);
        prefs.edit().clear().apply();

        Intent intent = new Intent(requireContext(), LoginActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
        requireActivity().finish();
    }
}
