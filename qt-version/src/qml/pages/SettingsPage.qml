import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Page {
    id: root
    signal goBack()
    signal logout()
    background: Rectangle { color: Theme.background }

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 16; spacing: 16

        // Header
        RowLayout {
            Layout.fillWidth: true
            Button {
                text: "←"; width: 40; height: 40
                background: Rectangle { radius: 20; color: Theme.muted }
                contentItem: Text { text: "←"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; color: Theme.textPrimary }
                onClicked: root.goBack()
            }
            Text { text: "设置"; font.pixelSize: 20; font.weight: Font.Medium; color: Theme.textPrimary; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter }
            Item { width: 40 }
        }

        // Data export
        Rectangle {
            Layout.fillWidth: true; radius: Theme.radiusMedium; color: Theme.card; border.color: Theme.border; border.width: 1
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 12
                Text { text: "数据管理"; font.pixelSize: 16; font.weight: Font.Medium; color: Theme.textPrimary }
                Button {
                    Layout.fillWidth: true; height: 40; text: "导出 CSV"
                    background: Rectangle { radius: Theme.radiusSmall; color: Theme.muted; border.color: Theme.border; border.width: 1 }
                    contentItem: Text { text: parent.text; color: Theme.textPrimary; font.pixelSize: Theme.fontSizeMedium; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: dataExporter.exportCSV("transactions.csv")
                }
            }
        }

        // About
        Rectangle {
            Layout.fillWidth: true; radius: Theme.radiusMedium; color: Theme.card; border.color: Theme.border; border.width: 1
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 8
                Text { text: "关于"; font.pixelSize: 16; font.weight: Font.Medium; color: Theme.textPrimary }
                Text { text: "岁里时光 v1.0.0"; font.pixelSize: Theme.fontSizeMedium; color: Theme.textSecondary }
                Text { text: "温馨的个人财务管理工具"; font.pixelSize: Theme.fontSizeSmall; color: Theme.textSecondary }
            }
        }

        // Logout
        Button {
            Layout.fillWidth: true; height: 48; text: "退出登录"
            background: Rectangle { radius: Theme.radiusMedium; color: Qt.rgba(Theme.expense.r, Theme.expense.g, Theme.expense.b, 0.1) }
            contentItem: Text { text: parent.text; color: Theme.expense; font.pixelSize: Theme.fontSizeMedium; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            onClicked: root.logout()
        }
    }
}
