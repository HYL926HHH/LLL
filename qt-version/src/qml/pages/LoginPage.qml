import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Page {
    id: root
    signal loginSuccess()

    background: Rectangle { color: Theme.background }

    header: Item { height: 0 }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 24
        width: Math.min(parent.width - 48, 360)

        // Logo
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 64; height: 64; radius: 16
                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)

                Text {
                    anchors.centerIn: parent
                    text: "🍂"
                    font.pixelSize: 28
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "岁里时光"
                font.pixelSize: 22
                font.weight: Font.Medium
                color: Theme.textPrimary
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "记录生活的每一笔"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textSecondary
            }
        }

        // Form card
        Rectangle {
            Layout.fillWidth: true
            height: 320
            radius: Theme.radiusLarge
            color: Theme.card
            border.color: Theme.border
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                Text {
                    text: "登录"
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Medium
                    color: Theme.textPrimary
                }

                // Email
                TextField {
                    id: emailField
                    Layout.fillWidth: true
                    placeholderText: "邮箱地址"
                    font.pixelSize: Theme.fontSizeMedium
                    background: Rectangle {
                        radius: Theme.radiusMedium
                        color: Theme.muted
                        border.color: emailField.activeFocus ? Theme.primary : Theme.border
                        border.width: emailField.activeFocus ? 2 : 1
                    }
                }

                // Password
                TextField {
                    id: passwordField
                    Layout.fillWidth: true
                    placeholderText: "密码"
                    echoMode: TextField.Password
                    font.pixelSize: Theme.fontSizeMedium
                    background: Rectangle {
                        radius: Theme.radiusMedium
                        color: Theme.muted
                        border.color: passwordField.activeFocus ? Theme.primary : Theme.border
                        border.width: passwordField.activeFocus ? 2 : 1
                    }
                }

                // Error
                Text {
                    id: errorText
                    visible: text !== ""
                    text: ""
                    color: Theme.expense
                    font.pixelSize: Theme.fontSizeSmall
                }

                // Login button
                Button {
                    Layout.fillWidth: true
                    height: 48
                    text: "登录"
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Medium
                    enabled: !loadingIndicator.running

                    background: Rectangle {
                        radius: Theme.radiusMedium
                        color: parent.pressed ? Theme.primaryDark : Theme.primary
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font: parent.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        errorText.text = ""
                        authManager.loginUser(emailField.text, passwordField.text)
                    }

                    Connections {
                        target: authManager
                        function onLoginSuccess() { root.loginSuccess() }
                        function onLoginFailed(error) { errorText.text = error }
                    }
                }

                BusyIndicator {
                    id: loadingIndicator
                    visible: running
                    Layout.alignment: Qt.AlignHCenter
                    width: 32; height: 32
                }

                // Register link
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 4

                    Text {
                        text: "还没有账号？"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textSecondary
                    }
                    Text {
                        text: "立即注册"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.primary
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: stackView.push(registerPage)
                        }
                    }
                }
            }
        }
    }
}
