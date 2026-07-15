import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Page {
    id: root
    background: Rectangle { color: Theme.background }

    property string currentType: "expense"
    property string selectedCategoryId: ""
    property string successMsg: ""
    property string errorMsg: ""

    Component.onCompleted: categoryManager.loadCategories("expense")

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 16; spacing: 16

        // Type tabs
        RowLayout {
            Layout.fillWidth: true; spacing: 0
            Repeater {
                model: [{key: "expense", label: "支出"}, {key: "income", label: "收入"}]
                delegate: Button {
                    Layout.fillWidth: true; height: 44
                    text: modelData.label
                    font.pixelSize: Theme.fontSizeMedium
                    background: Rectangle {
                        radius: Theme.radiusSmall
                        color: root.currentType === modelData.key ? Theme.primary : Theme.muted
                    }
                    contentItem: Text {
                        text: parent.text; color: root.currentType === modelData.key ? "white" : Theme.textPrimary
                        font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        root.currentType = modelData.key
                        categoryManager.loadCategories(modelData.key)
                    }
                }
            }
        }

        // Amount
        TextField {
            id: amountField; Layout.fillWidth: true; placeholderText: "金额"
            inputMethodHints: Qt.ImhDigitsOnly; font.pixelSize: 24; font.weight: Font.Bold
            background: Rectangle { radius: Theme.radiusMedium; color: Theme.muted; border.color: amountField.activeFocus ? Theme.primary : Theme.border; border.width: amountField.activeFocus ? 2 : 1 }
        }

        // Category grid
        Text { text: "选择分类"; font.pixelSize: Theme.fontSizeMedium; color: Theme.textSecondary }
        GridView {
            Layout.fillWidth: true; height: 200
            cellWidth: 80; cellHeight: 80
            model: categoryManager.categories
            delegate: Item {
                width: 80; height: 80
                ColumnLayout {
                    anchors.centerIn: parent; spacing: 4
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 48; height: 48; radius: 12
                        color: root.selectedCategoryId === modelData.id ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2) : Theme.muted
                        border.color: root.selectedCategoryId === modelData.id ? Theme.primary : "transparent"; border.width: 2
                        Text { anchors.centerIn: parent; text: modelData.icon; font.pixelSize: 20 }
                    }
                    Text { text: modelData.name; font.pixelSize: 11; color: Theme.textPrimary; Layout.alignment: Qt.AlignHCenter }
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: root.selectedCategoryId = modelData.id
                }
            }
        }

        // Date
        TextField {
            id: dateField; Layout.fillWidth: true
            text: new Date().toISOString().slice(0, 10)
            placeholderText: "日期"
            background: Rectangle { radius: Theme.radiusMedium; color: Theme.muted; border.color: Theme.border; border.width: 1 }
        }

        // Note
        TextField {
            id: noteField; Layout.fillWidth: true; placeholderText: "备注（可选）"
            background: Rectangle { radius: Theme.radiusMedium; color: Theme.muted; border.color: Theme.border; border.width: 1 }
        }

        // Messages
        Text { visible: root.errorMsg !== ""; text: root.errorMsg; color: Theme.expense; font.pixelSize: Theme.fontSizeSmall }
        Text { visible: root.successMsg !== ""; text: root.successMsg; color: Theme.income; font.pixelSize: Theme.fontSizeSmall }

        // Save button
        Button {
            Layout.fillWidth: true; height: 48; text: "保存"
            background: Rectangle { radius: Theme.radiusMedium; color: parent.pressed ? Theme.primaryDark : Theme.primary }
            contentItem: Text { text: parent.text; color: "white"; font.pixelSize: Theme.fontSizeMedium; font.weight: Font.Medium; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            onClicked: {
                root.errorMsg = ""; root.successMsg = ""
                if (!amountField.text || parseFloat(amountField.text) <= 0) { root.errorMsg = "请输入有效金额"; return }
                if (!root.selectedCategoryId) { root.errorMsg = "请选择分类"; return }
                transactionManager.addTransaction(root.selectedCategoryId, root.currentType, amountField.text, dateField.text, noteField.text)
            }
            Connections {
                target: transactionManager
                function onTransactionAdded() { root.successMsg = "保存成功"; amountField.text = ""; noteField.text = ""; root.selectedCategoryId = "" }
                function onErrorOccurred(error) { root.errorMsg = error }
            }
        }
    }
}
