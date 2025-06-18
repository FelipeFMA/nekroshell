import Quickshell.Io

JsonObject {
    property string actionPrefix: ">"
    property int maxShown: 8
    property bool enableDangerousActions: false // Allow actions that can cause losing data, like shutdown, reboot and logout

    property JsonObject sizes: JsonObject {
        property int itemWidth: 600
        property int itemHeight: 57
    }
}
