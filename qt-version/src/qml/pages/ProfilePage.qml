import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Page {
    id: root
    signal goToSettings()
    background: Rectangle { color: Theme.background }

    Component.onCompleted: userProfileManager.loadProfile()

    Flickable {
        anchors.fill: parent; contentHeight: mainCol.height + 32; clip: true

        ColumnLayout {
            id: mainCol; width: parent.width; spacing: 16
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 16

            // Avatar & info
            Rectangle {
                Layout.fillWidth: true; height: 160; radius: Theme.radiusLarge
                color: Theme.card; border.color: Theme.border; border.width: 1
                ColumnLayout {
                    anchors.centerIn: parent; spacing: 8
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 64; height: 64; radius: 32
                        gradient: Gradient {
                            GradientStop { position: 0; color: Theme.primary }
                            GradientStop { position: 1; color: Theme.expense }
                        }
                        Text { anchors.centerIn: parent; text: (authManager.currentUserEmail || "U").charAt(0).toUpperCase(); color: "white"; font.pixelSize: 24; font.weight: Font.Bold }
                    }
                    Text { text: userProfileManager.nickname || "用户"; font.pixelSize: 18; font.weight: Font.Medium; color: Theme.textPrimary }
                    Text { text: authManager.currentUserEmail; font.pixelSize: Theme.fontSizeSmall; color: Theme.textSecondary }
                }
            }

            // Stats
            RowLayout {
                Layout.fillWidth: true; spacing: 12
                Repeater {
                    model: [
                        {label: "总收入", color: Theme.income},
                        {label: "总支出", color: Theme.expense},
                        {label: "总笔数", color: Theme.primary}
                    ]
                    delegate: Rectangle {
                        Layout.fillWidth: true; height: 80; radius: Theme.radiusMedium
                        color: Theme.card; border.color: Theme.border; border.width: 1
                        ColumnLayout {
                            anchors.centerIn: parent; spacing: 4
                            Text { text: modelData.label; font.pixelSize: Theme.fontSizeSmall; color: Theme.textSecondary }
                            Text { text: modelData.label === "总笔数" ? "0" : "¥0.00"; font.pixelSize: 18; font.weight: Font.Bold; color: modelData.color }
                        }
                    }
                }
            }

            // Quick actions
            Rectangle {
                Layout.fillWidth: true; radius: Theme.radiusMedium; color: Theme.card; border.color: Theme.border; border.width: 1
                ColumnLayout {
                    anchors.fill: parent; spacing: 0
                    Repeater {
                        model: [
                            {icon: "⚙️", label: "设置", action: "settings"},
                            {icon: "📂", label: "分类管理", action: "categories"},
                            {icon: "🎨", label: "主题切换", action: "theme"},
                            {icon: "📱", label: "模式切换", action: "mode"}
                        ]
                        delegate: Item {
                            Layout.fillWidth: true; height: 52
                            RowLayout {
                                anchors.fill: parent; anchors.margins: 16
                                Text { text: modelData.icon; font.pixelSize: 18 }
                                Text { text: modelData.label; font.pixelSize: Theme.fontSizeMedium; color: Theme.textPrimary; Layout.fillWidth: true }
                                Text { text: "›"; font.pixelSize: 18; color: Theme.textSecondary }
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (modelData.action === "settings") root.goToSettings()
                                }
                            }
                            Rectangle { visible: index < 3; anchors.bottom: parent.bottom; height: 1; color: Theme.border; Layout.fillWidth: true }
                        }
                    }
                }
            }

            // Logout
            Button {
                Layout.fillWidth: true; height: 48; text: "退出登录"
                background: Rectangle { radius: Theme.radiusMedium; color: Qt.rgba(Theme.expense.r, Theme.expense.g, Theme.expense.b, 0.1) }
                contentItem: Text { text: parent.text; color: Theme.expense; font.pixelSize: Theme.fontSizeMedium; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: authManager.logout()
            }
        }
    }
}
