import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    height: 64
    color: Theme.card
    border.color: Theme.border
    border.width: 1

    property int currentIndex: 0

    RowLayout {
        anchors.fill: parent
        anchors.topMargin: 4
        spacing: 0

        Repeater {
            model: [
                {icon: "🏠", label: "首页"},
                {icon: "✏️", label: "记账"},
                {icon: "📊", label: "统计"},
                {icon: "🎯", label: "预算"},
                {icon: "📂", label: "分类"},
                {icon: "👤", label: "我的"}
            ]

            delegate: Item {
                Layout.fillWidth: true; Layout.fillHeight: true

                ColumnLayout {
                    anchors.centerIn: parent; spacing: 2
                    Text {
                        text: modelData.icon; font.pixelSize: 20
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: modelData.label; font.pixelSize: 10
                        color: root.currentIndex === index ? Theme.primary : Theme.textSecondary
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: root.currentIndex = index
                }
            }
        }
    }
}
