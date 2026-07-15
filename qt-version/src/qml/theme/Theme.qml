pragma Singleton
import QtQuick

QtObject {
    // 温馨秋日主题 - 浅色模式
    readonly property color background: "#FDF8F0"
    readonly property color card: "#FFFFFF"
    readonly property color primary: "#E8915B"
    readonly property color primaryDark: "#D4725E"
    readonly property color income: "#8DB580"
    readonly property color expense: "#D4725E"
    readonly property color textPrimary: "#4A3728"
    readonly property color textSecondary: "#9B8578"
    readonly property color border: "#F0E6D8"
    readonly property color muted: "#F5EDE4"

    // 深色模式
    readonly property color darkBackground: "#1E1814"
    readonly property color darkCard: "#2A221C"
    readonly property color darkTextPrimary: "#F5EDE4"
    readonly property color darkTextSecondary: "#B8A898"
    readonly property color darkBorder: "#3D322A"
    readonly property color darkMuted: "#3D322A"

    // 字体
    readonly property string fontFamily: "Noto Sans SC"
    readonly property int fontSizeSmall: 12
    readonly property int fontSizeMedium: 14
    readonly property int fontSizeLarge: 18
    readonly property int fontSizeTitle: 24

    // 圆角
    readonly property int radiusSmall: 8
    readonly property int radiusMedium: 12
    readonly property int radiusLarge: 16

    // 间距
    readonly property int spacingSmall: 8
    readonly property int spacingMedium: 16
    readonly property int spacingLarge: 24
}
