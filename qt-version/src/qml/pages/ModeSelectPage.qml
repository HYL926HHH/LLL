import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Page {
    id: root
    signal modeSelected(string mode)

    background: Rectangle { color: Theme.background }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 32
        width: Math.min(parent.width - 48, 400)

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter; spacing: 8
            Text { text: "岁里时光"; font.pixelSize: 28; font.weight: Font.Medium; color: Theme.textPrimary }
            Text { text: "选择你的使用模式"; font.pixelSize: Theme.fontSizeSmall; color: Theme.textSecondary }
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 16

            // Mobile mode card
            Rectangle {
                Layout.fillWidth: true; height: 180; radius: Theme.radiusLarge
                color: Theme.card; border.color: Theme.border; border.width: 1

                ColumnLayout {
                    anchors.centerIn: parent; spacing: 12
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 56; height: 56; radius: 14
                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                        Text { anchors.centerIn: parent; text: "📱"; font.pixelSize: 24 }
                    }
                    Text { text: "移动端模式"; font.pixelSize: 16; font.weight: Font.Medium; color: Theme.textPrimary }
                    Text { text: "底部导航，适合手机"; font.pixelSize: Theme.fontSizeSmall; color: Theme.textSecondary }
                }

                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: root.modeSelected("mobile")
                }
            }

            // PC mode card
            Rectangle {
                Layout.fillWidth: true; height: 180; radius: Theme.radiusLarge
                color: Theme.card; border.color: Theme.border; border.width: 1

                ColumnLayout {
                    anchors.centerIn: parent; spacing: 12
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 56; height: 56; radius: 14
                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                        Text { anchors.centerIn: parent; text: "🖥️"; font.pixelSize: 24 }
                    }
                    Text { text: "PC端模式"; font.pixelSize: 16; font.weight: Font.Medium; color: Theme.textPrimary }
                    Text { text: "侧边栏布局，适合电脑"; font.pixelSize: Theme.fontSizeSmall; color: Theme.textSecondary }
                }

                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: root.modeSelected("pc")
                }
            }
        }
    }
}
