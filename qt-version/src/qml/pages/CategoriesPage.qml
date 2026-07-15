import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Page {
    id: root
    background: Rectangle { color: Theme.background }
    property string currentType: "expense"

    Component.onCompleted: categoryManager.loadCategories("expense")

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 16; spacing: 16

        Text { text: "分类管理"; font.pixelSize: 20; font.weight: Font.Medium; color: Theme.textPrimary }

        // Type tabs
        RowLayout {
            Layout.fillWidth: true; spacing: 0
            Repeater {
                model: [{key: "expense", label: "支出分类"}, {key: "income", label: "收入分类"}]
                delegate: Button {
                    Layout.fillWidth: true; height: 40; text: modelData.label
                    background: Rectangle { radius: Theme.radiusSmall; color: root.currentType === modelData.key ? Theme.primary : Theme.muted }
                    contentItem: Text { text: parent.text; color: root.currentType === modelData.key ? "white" : Theme.textPrimary; font.pixelSize: Theme.fontSizeMedium; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: { root.currentType = modelData.key; categoryManager.loadCategories(modelData.key) }
                }
            }
        }

        // Category list
        ListView {
            Layout.fillWidth: true; Layout.fillHeight: true
            model: categoryManager.categories
            spacing: 8
            delegate: Rectangle {
                width: ListView.view.width; height: 56; radius: Theme.radiusSmall
                color: Theme.card; border.color: Theme.border; border.width: 1
                RowLayout {
                    anchors.fill: parent; anchors.margins: 12
                    Text { text: modelData.icon; font.pixelSize: 20 }
                    Text { text: modelData.name; font.pixelSize: Theme.fontSizeMedium; color: Theme.textPrimary; Layout.fillWidth: true }
                    Button {
                        text: "删除"; width: 60; height: 32
                        background: Rectangle { radius: 8; color: Qt.rgba(Theme.expense.r, Theme.expense.g, Theme.expense.b, 0.1) }
                        contentItem: Text { text: "删除"; color: Theme.expense; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        onClicked: categoryManager.deleteCategory(modelData.id)
                    }
                }
            }
        }

        // Add category
        RowLayout {
            Layout.fillWidth: true; spacing: 8
            TextField { id: newCatName; Layout.fillWidth: true; placeholderText: "新分类名称"; background: Rectangle { radius: Theme.radiusSmall; color: Theme.muted; border.color: Theme.border; border.width: 1 } }
            TextField { id: newCatIcon; width: 60; placeholderText: "🏷️"; background: Rectangle { radius: Theme.radiusSmall; color: Theme.muted; border.color: Theme.border; border.width: 1 } }
            Button {
                text: "添加"; width: 60; height: 40
                background: Rectangle { radius: Theme.radiusSmall; color: Theme.primary }
                contentItem: Text { text: "添加"; color: "white"; font.pixelSize: Theme.fontSizeSmall; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: {
                    if (newCatName.text) {
                        categoryManager.addCategory(newCatName.text, newCatIcon.text || "🏷️", root.currentType)
                        newCatName.text = ""; newCatIcon.text = ""
                    }
                }
            }
        }
    }
}
