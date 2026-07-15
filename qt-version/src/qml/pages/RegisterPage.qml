import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Page {
    id: root
    signal registerSuccess()
    signal goToLogin()

    background: Rectangle { color: Theme.background }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 24
        width: Math.min(parent.width - 48, 360)

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 64; height: 64; radius: 16
                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                Text { anchors.centerIn: parent; text: "🍂"; font.pixelSize: 28 }
            }
            Text { text: "创建账号"; font.pixelSize: 22; font.weight: Font.Medium; color: Theme.textPrimary }
            Text { text: "开始记录你的岁里时光"; font.pixelSize: Theme.fontSizeSmall; color: Theme.textSecondary }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 400
            radius: Theme.radiusLarge
            color: Theme.card
            border.color: Theme.border; border.width: 1

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 24; spacing: 16

                TextField {
                    id: regEmail; Layout.fillWidth: true; placeholderText: "邮箱地址"
                    background: Rectangle { radius: Theme.radiusMedium; color: Theme.muted; border.color: regEmail.activeFocus ? Theme.primary : Theme.border; border.width: regEmail.activeFocus ? 2 : 1 }
                }
                TextField {
                    id: regPassword; Layout.fillWidth: true; placeholderText: "密码（至少6位）"; echoMode: TextField.Password
                    background: Rectangle { radius: Theme.radiusMedium; color: Theme.muted; border.color: regPassword.activeFocus ? Theme.primary : Theme.border; border.width: regPassword.activeFocus ? 2 : 1 }
                }
                TextField {
                    id: regConfirm; Layout.fillWidth: true; placeholderText: "确认密码"; echoMode: TextField.Password
                    background: Rectangle { radius: Theme.radiusMedium; color: Theme.muted; border.color: regConfirm.activeFocus ? Theme.primary : Theme.border; border.width: regConfirm.activeFocus ? 2 : 1 }
                }

                Text { id: regError; visible: text !== ""; color: Theme.expense; font.pixelSize: Theme.fontSizeSmall }

                Button {
                    Layout.fillWidth: true; height: 48; text: "注册"
                    font.pixelSize: Theme.fontSizeMedium; font.weight: Font.Medium
                    background: Rectangle { radius: Theme.radiusMedium; color: parent.pressed ? Theme.primaryDark : Theme.primary }
                    contentItem: Text { text: parent.text; color: "white"; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        regError.text = ""
                        authManager.registerUser(regEmail.text, regPassword.text)
                    }
                    Connections {
                        target: authManager
                        function onRegisterSuccess() { root.registerSuccess() }
                        function onRegisterFailed(error) { regError.text = error }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter; spacing: 4
                    Text { text: "已有账号？"; font.pixelSize: Theme.fontSizeSmall; color: Theme.textSecondary }
                    Text { text: "去登录"; font.pixelSize: Theme.fontSizeSmall; color: Theme.primary
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.goToLogin() }
                    }
                }
            }
        }
    }
}
