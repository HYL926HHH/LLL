package com.suili.time.ui.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.suili.time.R;
import com.suili.time.SuiliTimeApp;
import com.suili.time.data.DatabaseHelper;
import com.suili.time.ui.MainActivity;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * 记账界面
 */
public class AddFragment extends Fragment {

    private Spinner spinnerType, spinnerCategory;
    private EditText etAmount, etNote, etDate;
    private Button btnSave;

    private List<Map<String, Object>> categories;
    private String currentType = "expense";

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_add, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        spinnerType = view.findViewById(R.id.spinner_type);
        spinnerCategory = view.findViewById(R.id.spinner_category);
        etAmount = view.findViewById(R.id.et_amount);
        etNote = view.findViewById(R.id.et_note);
        etDate = view.findViewById(R.id.et_date);
        btnSave = view.findViewById(R.id.btn_save);

        // 设置日期默认值
        etDate.setText(new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(new Date()));

        // 设置类型选择
        ArrayAdapter<String> typeAdapter = new ArrayAdapter<>(requireContext(),
                android.R.layout.simple_spinner_item, new String[]{"支出", "收入"});
        typeAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinnerType.setAdapter(typeAdapter);

        spinnerType.setOnItemSelectedListener(new android.widget.AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(android.widget.AdapterView<?> parent, View v, int position, long id) {
                currentType = position == 0 ? "expense" : "income";
                loadCategories();
            }
            @Override
            public void onNothingSelected(android.widget.AdapterView<?> parent) {}
        });

        btnSave.setOnClickListener(v -> saveTransaction());

        loadCategories();
    }

    private void loadCategories() {
        String userId = ((MainActivity) requireActivity()).getCurrentUserId();
        DatabaseHelper dbHelper = SuiliTimeApp.getInstance().getDatabaseHelper();
        categories = dbHelper.getCategories(userId, currentType);

        List<String> categoryNames = new ArrayList<>();
        for (Map<String, Object> c : categories) {
            String icon = (String) c.get("icon");
            String name = (String) c.get("name");
            categoryNames.add(icon + " " + name);
        }

        ArrayAdapter<String> adapter = new ArrayAdapter<>(requireContext(),
                android.R.layout.simple_spinner_item, categoryNames);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinnerCategory.setAdapter(adapter);
    }

    private void saveTransaction() {
        String amount = etAmount.getText().toString().trim();
        String note = etNote.getText().toString().trim();
        String date = etDate.getText().toString().trim();

        if (amount.isEmpty()) {
            etAmount.setError("请输入金额");
            return;
        }
        if (spinnerCategory.getCount() == 0) {
            Toast.makeText(requireContext(), "请先创建分类", Toast.LENGTH_SHORT).show();
            return;
        }

        int categoryIndex = spinnerCategory.getSelectedItemPosition();
        String categoryId = (String) categories.get(categoryIndex).get("id");
        String userId = ((MainActivity) requireActivity()).getCurrentUserId();

        DatabaseHelper dbHelper = SuiliTimeApp.getInstance().getDatabaseHelper();
        String id = dbHelper.createTransaction(userId, categoryId, currentType, amount, note, date);

        if (id != null) {
            Toast.makeText(requireContext(), "保存成功", Toast.LENGTH_SHORT).show();
            // 清空表单
            etAmount.setText("");
            etNote.setText("");
        } else {
            Toast.makeText(requireContext(), "保存失败", Toast.LENGTH_SHORT).show();
        }
    }
}
