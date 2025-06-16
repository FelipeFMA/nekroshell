import Quickshell.Io

JsonObject {
    property bool enableBlur: true
    property real blurRadius: 64
    property real backgroundOpacity: 0.3
    property bool showClock: true
    property bool showDate: true
    property bool showUserInfo: true
    property int maxAuthAttempts: 5
    property int lockTimeout: 10000 // 10 seconds timeout for auth attempts

    property JsonObject sizes: JsonObject {
        property int containerWidth: 500
        property int containerMinWidth: 400
        property real containerWidthRatio: 0.4
        property int avatarSize: 48
        property int clockFontSize: 56
        property int dateFontSize: 18
    }

    property JsonObject security: JsonObject {
        property bool hidePasswordLength: false
        property bool enableShakeAnimation: true
        property int authTimeoutMs: 2000
        property bool clearPasswordOnError: true
    }
}
