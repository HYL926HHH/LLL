import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Page {
    id: root
    background: Rectangle { color: Theme.background }
    property string currentMonth: new Date().toISOString().slice(0, 7)

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 16; spacing: 16

        Text { text: "统计"; font.pixelSize: 20; font.weight: Font.Medium; color: Theme.textPrimary }

        // Month selector
        RowLayout {
            Layout.fillWidth: true; spacing: 8
            Button {
                text: "<"; width: 40; height: 40
                background: Rectangle { radius: 20; color: Theme.muted }
                contentItem: Text { text: parent.text; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; color: Theme.textPrimary }
                onClicked: {
                    var d = new Date(root.currentMonth + "-01")
                    d.setMonth(d.getMonth() - 1)
                    root.currentMonth = d.toISOString().slice(0, 7)
                }
            }
            Text { text: root.currentMonth; font.pixelSize: 16; font.weight: Font.Medium; color: Theme.textPrimary; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter }
            Button {
                text: ">"; width: 40; height: 40
                background: Rectangle { radius: 20; color: Theme.muted }
                contentItem: Text { text: parent.text; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; color: Theme.textPrimary }
                onClicked: {
                    var d = new Date(root.currentMonth + "-01")
                    d.setMonth(d.getMonth() + 1)
                    root.currentMonth = d.toISOString().slice(0, 7)
                }
            }
        }

        // Stats summary
        Rectangle {
            Layout.fillWidth: true; height: 120; radius: Theme.radiusMedium
            color: Theme.card; border.color: Theme.border; border.width: 1
            RowLayout {
                anchors.fill: parent; anchors.margins: 16
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 4
                    Text { text: "收入"; font.pixelSize: Theme.fontSizeSmall; color: Theme.textSecondary }
                    Text { id: statIncome; text: "¥0.00"; font.pixelSize: 18; font.weight: Font.Bold; color: Theme.income }
                }
                Rectangle { width: 1; Layout.fillHeight: true; color: Theme.border }
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 4
                    Text { text: "支出"; font.pixelSize: Theme.fontSizeSmall; color: Theme.textSecondary }
                    Text { id: statExpense; text: "¥0.00"; font.pixelSize: 18; font.weight: Font.Bold; color: Theme.expense }
                }
            }
        }

        // Placeholder for charts
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            radius: Theme.radiusMedium; color: Theme.card; border.color: Theme.border; border.width: 1
            ColumnLayout {
                anchors.centerIn: parent; spacing: 8
                Text { text: "📊"; font.pixelSize: 48; Layout.alignment: Qt.AlignHCenter }
                Text { text: "图表区域"; font.pixelSize: 16; color: Theme.textSecondary; Layout.alignment: Qt.AlignHCenter }
                Text { text: "饼图/柱状图/折线图"; font.pixelSize: Theme.fontSizeSmall; color: Theme.textSecondary; Layout.alignment: Qt.AlignHCenter }
            }
        }
    }
}
