import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Page {
    id: root
    background: Rectangle { color: Theme.background }
    property string currentMonth: new Date().toISOString().slice(0, 7)
    property string budgetAmount: "0"

    Component.onCompleted: budgetManager.loadBudget(root.currentMonth)

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 16; spacing: 16

        Text { text: "预算管理"; font.pixelSize: 20; font.weight: Font.Medium; color: Theme.textPrimary }

        // Budget card
        Rectangle {
            Layout.fillWidth: true; height: 160; radius: Theme.radiusMedium
            color: Theme.card; border.color: Theme.border; border.width: 1
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 20; spacing: 12
                Text { text: "月度预算"; font.pixelSize: Theme.fontSizeSmall; color: Theme.textSecondary }
                TextField {
                    id: budgetInput; Layout.fillWidth: true; placeholderText: "设置预算金额"
                    inputMethodHints: Qt.ImhDigitsOnly; font.pixelSize: 24; font.weight: Font.Bold
                    text: root.budgetAmount !== "0" ? root.budgetAmount : ""
                    background: Rectangle { radius: Theme.radiusSmall; color: Theme.muted; border.color: budgetInput.activeFocus ? Theme.primary : Theme.border; border.width: budgetInput.activeFocus ? 2 : 1 }
                }
                Button {
                    Layout.fillWidth: true; height: 40; text: "保存预算"
                    background: Rectangle { radius: Theme.radiusSmall; color: parent.pressed ? Theme.primaryDark : Theme.primary }
                    contentItem: Text { text: parent.text; color: "white"; font.pixelSize: Theme.fontSizeMedium; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: budgetManager.saveBudget(root.currentMonth, budgetInput.text)
                }
            }
        }

        // Progress
        Rectangle {
            Layout.fillWidth: true; height: 80; radius: Theme.radiusMedium
            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08)
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 8
                Text { text: "预算进度"; font.pixelSize: Theme.fontSizeSmall; color: Theme.textSecondary }
                ProgressBar {
                    Layout.fillWidth: true; height: 8
                    value: 0.3  // placeholder
                    background: Rectangle { radius: 4; color: Theme.muted }
                    contentItem: Rectangle { radius: 4; color: Theme.primary; width: parent.value * parent.width }
                }
            }
        }

        Connections {
            target: budgetManager
            function onBudgetLoaded() {
                var b = budgetManager.currentBudget()
                if (b.amount) root.budgetAmount = b.amount
            }
            function onBudgetSaved() { root.budgetAmount = budgetInput.text }
        }
    }
}
