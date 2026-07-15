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

/**
 * 统计界面
 */
public class StatsFragment extends Fragment {

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_stats, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        // TODO: 实现图表统计（使用 MPAndroidChart 库）
        TextView tvPlaceholder = view.findViewById(R.id.tv_placeholder);
        tvPlaceholder.setText("统计图表功能\n（集成 MPAndroidChart 后展示）");
    }
}
