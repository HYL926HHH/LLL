import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "pages"
import "components"
import "theme"

ApplicationWindow {
    id: root
    width: 420
    height: 780
    visible: true
    title: "岁里时光"
    color: Theme.background

    property string currentPage: "login"
    property string appMode: ""  // "mobile" or "pc"

    // StackView for page navigation
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: loginPage
    }

    // Pages
    Component {
        id: loginPage
        LoginPage {
            onLoginSuccess: {
                root.currentPage = "modeSelect"
                stackView.replace(modeSelectPage)
            }
        }
    }

    Component {
        id: registerPage
        RegisterPage {
            onRegisterSuccess: {
                stackView.pop()
            }
            onGoToLogin: {
                stackView.pop()
            }
        }
    }

    Component {
        id: modeSelectPage
        ModeSelectPage {
            onModeSelected: function(mode) {
                root.appMode = mode
                root.currentPage = "home"
                stackView.replace(mainApp)
            }
        }
    }

    Component {
        id: mainApp
        Item {
            anchors.fill: parent

            // Content area
            StackLayout {
                id: contentStack
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: navBar.top
                currentIndex: navBar.currentIndex

                HomePage { id: homePage }
                AddPage { id: addPage }
                StatsPage { id: statsPage }
                BudgetPage { id: budgetPage }
                CategoriesPage { id: categoriesPage }
                ProfilePage {
                    id: profilePage
                    onGoToSettings: {
                        stackView.push(settingsPage)
                    }
                }
            }

            NavBar {
                id: navBar
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
            }
        }
    }

    Component {
        id: settingsPage
        SettingsPage {
            onGoBack: stackView.pop()
            onLogout: {
                authManager.logout()
                stackView.clear()
                stackView.push(loginPage)
            }
        }
    }

    // Connections
    Connections {
        target: authManager
        function onLoginFailed(error) {
            console.log("Login failed:", error)
        }
    }
}
