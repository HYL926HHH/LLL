import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Page {
    id: root
    background: Rectangle { color: Theme.background }

    property double totalIncome: 0
    property double totalExpense: 0
    property var recentTransactions: []

    Component.onCompleted: {
        transactionManager.loadTransactions("")
        var stats = transactionManager.getStats()
        totalIncome = stats.totalIncome
        totalExpense = stats.totalExpense
    }

    Flickable {
        anchors.fill: parent
        contentHeight: mainColumn.height + 32
        clip: true

        ColumnLayout {
            id: mainColumn
            width: parent.width; spacing: 16
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
            anchors.margins: 16

            // Header
            Text { text: "月度概览"; font.pixelSize: 20; font.weight: Font.Medium; color: Theme.textPrimary }

            // Summary cards
            RowLayout {
                Layout.fillWidth: true; spacing: 12

                Rectangle {
                    Layout.fillWidth: true; height: 100; radius: Theme.radiusMedium
                    color: Theme.card; border.color: Theme.border; border.width: 1
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 16; spacing: 4
                        Text { text: "收入"; font.pixelSize: Theme.fontSizeSmall; color: Theme.textSecondary }
                        Text { text: "¥" + root.totalIncome.toFixed(2); font.pixelSize: 20; font.weight: Font.Bold; color: Theme.income }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true; height: 100; radius: Theme.radiusMedium
                    color: Theme.card; border.color: Theme.border; border.width: 1
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 16; spacing: 4
                        Text { text: "支出"; font.pixelSize: Theme.fontSizeSmall; color: Theme.textSecondary }
                        Text { text: "¥" + root.totalExpense.toFixed(2); font.pixelSize: 20; font.weight: Font.Bold; color: Theme.expense }
                    }
                }
            }

            // Balance card
            Rectangle {
                Layout.fillWidth: true; height: 80; radius: Theme.radiusMedium
                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08)
                border.color: Theme.primary; border.width: 1
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 16; spacing: 4
                    Text { text: "结余"; font.pixelSize: Theme.fontSizeSmall; color: Theme.textSecondary }
                    Text { text: "¥" + (root.totalIncome - root.totalExpense).toFixed(2); font.pixelSize: 24; font.weight: Font.Bold; color: Theme.primary }
                }
            }

            // Quick actions
            RowLayout {
                Layout.fillWidth: true; spacing: 12
                Button {
                    Layout.fillWidth: true; height: 44; text: "记一笔"
                    background: Rectangle { radius: Theme.radiusMedium; color: Theme.primary }
                    contentItem: Text { text: parent.text; color: "white"; font.pixelSize: Theme.fontSizeMedium; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: navBar.currentIndex = 1
                }
                Button {
                    Layout.fillWidth: true; height: 44; text: "查看统计"
                    background: Rectangle { radius: Theme.radiusMedium; color: Theme.muted; border.color: Theme.border; border.width: 1 }
                    contentItem: Text { text: parent.text; color: Theme.textPrimary; font.pixelSize: Theme.fontSizeMedium; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: navBar.currentIndex = 2
                }
            }

            // Recent transactions
            Text { text: "最近交易"; font.pixelSize: 16; font.weight: Font.Medium; color: Theme.textPrimary; Layout.topMargin: 8 }

            Repeater {
                model: transactionManager.transactions
                delegate: Rectangle {
                    Layout.fillWidth: true; height: 60; radius: Theme.radiusSmall
                    color: Theme.card; border.color: Theme.border; border.width: 1

                    RowLayout {
                        anchors.fill: parent; anchors.margins: 12
                        Text { text: modelData.category_icon || "📦"; font.pixelSize: 20 }
                        ColumnLayout {
                            Layout.fillWidth: true; spacing: 2
                            Text { text: modelData.category_name || "未分类"; font.pixelSize: Theme.fontSizeMedium; color: Theme.textPrimary }
                            Text { text: modelData.transaction_date; font.pixelSize: Theme.fontSizeSmall; color: Theme.textSecondary }
                        }
                        Text {
                            text: (modelData.type === "income" ? "+" : "-") + "¥" + modelData.amount
                            font.pixelSize: Theme.fontSizeMedium; font.weight: Font.Medium
                            color: modelData.type === "income" ? Theme.income : Theme.expense
                        }
                    }
                }
            }
        }
    }
}
