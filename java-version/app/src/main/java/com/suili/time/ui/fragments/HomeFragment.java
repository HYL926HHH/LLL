package com.suili.time.ui.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.suili.time.R;
import com.suili.time.SuiliTimeApp;
import com.suili.time.data.DatabaseHelper;
import com.suili.time.ui.MainActivity;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * 首页 - 月度概览
 */
public class HomeFragment extends Fragment {

    private TextView tvTotalIncome, tvTotalExpense, tvBalance;
    private TextView tvMonthLabel;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_home, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        tvTotalIncome = view.findViewById(R.id.tv_total_income);
        tvTotalExpense = view.findViewById(R.id.tv_total_expense);
        tvBalance = view.findViewById(R.id.tv_balance);
        tvMonthLabel = view.findViewById(R.id.tv_month_label);

        loadData();
    }

    private void loadData() {
        String userId = ((MainActivity) requireActivity()).getCurrentUserId();
        DatabaseHelper dbHelper = SuiliTimeApp.getInstance().getDatabaseHelper();

        String currentMonth = new SimpleDateFormat("yyyy-MM", Locale.getDefault()).format(new Date());
        tvMonthLabel.setText(currentMonth);

        List<Map<String, Object>> transactions = dbHelper.getTransactions(userId, currentMonth);

        double totalIncome = 0;
        double totalExpense = 0;

        for (Map<String, Object> t : transactions) {
            String type = (String) t.get("type");
            String rawData = (String) t.get("raw_data");
            double amount = parseAmountFromJson(rawData);

            if ("income".equals(type)) {
                totalIncome += amount;
            } else {
                totalExpense += amount;
            }
        }

        tvTotalIncome.setText(String.format(Locale.getDefault(), "¥%.2f", totalIncome));
        tvTotalExpense.setText(String.format(Locale.getDefault(), "¥%.2f", totalExpense));
        tvBalance.setText(String.format(Locale.getDefault(), "¥%.2f", totalIncome - totalExpense));
    }

    private double parseAmountFromJson(String json) {
        try {
            // 简单解析 {"amount":"100.00","note":"..."}
            int start = json.indexOf("\"amount\":\"") + 10;
            int end = json.indexOf("\"", start);
            return Double.parseDouble(json.substring(start, end));
        } catch (Exception e) {
            return 0;
        }
    }
}
