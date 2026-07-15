package com.suili.time.ui.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.suili.time.R;
import com.suili.time.SuiliTimeApp;
import com.suili.time.data.DatabaseHelper;
import com.suili.time.ui.MainActivity;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.Map;

/**
 * 预算界面
 */
public class BudgetFragment extends Fragment {

    private EditText etBudgetAmount;
    private Button btnSaveBudget;
    private TextView tvBudgetInfo;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_budget, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        etBudgetAmount = view.findViewById(R.id.et_budget_amount);
        btnSaveBudget = view.findViewById(R.id.btn_save_budget);
        tvBudgetInfo = view.findViewById(R.id.tv_budget_info);

        btnSaveBudget.setOnClickListener(v -> saveBudget());
        loadBudget();
    }

    private void loadBudget() {
        String userId = ((MainActivity) requireActivity()).getCurrentUserId();
        String currentMonth = new SimpleDateFormat("yyyy-MM", Locale.getDefault()).format(new Date());
        DatabaseHelper dbHelper = SuiliTimeApp.getInstance().getDatabaseHelper();

        Map<String, Object> budget = dbHelper.getBudget(userId, currentMonth);
        if (budget != null) {
            String rawData = (String) budget.get("raw_data");
            tvBudgetInfo.setText("本月预算: " + parseAmountFromJson(rawData));
        } else {
            tvBudgetInfo.setText("本月未设置预算");
        }
    }

    private void saveBudget() {
        String amount = etBudgetAmount.getText().toString().trim();
        if (amount.isEmpty()) {
            etBudgetAmount.setError("请输入预算金额");
            return;
        }

        String userId = ((MainActivity) requireActivity()).getCurrentUserId();
        String currentMonth = new SimpleDateFormat("yyyy-MM", Locale.getDefault()).format(new Date());
        DatabaseHelper dbHelper = SuiliTimeApp.getInstance().getDatabaseHelper();

        String id = dbHelper.setBudget(userId, currentMonth, amount);
        if (id != null) {
            Toast.makeText(requireContext(), "预算设置成功", Toast.LENGTH_SHORT).show();
            loadBudget();
        } else {
            Toast.makeText(requireContext(), "设置失败", Toast.LENGTH_SHORT).show();
        }
    }

    private String parseAmountFromJson(String json) {
        try {
            int start = json.indexOf("\"amount\":\"") + 10;
            int end = json.indexOf("\"", start);
            return "¥" + json.substring(start, end);
        } catch (Exception e) {
            return "¥0.00";
        }
    }
}
