import "root:/widgets"
import "root:/services" 
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    StyledWindow {
        id: win

        required property ShellScreen modelData

        screen: modelData
        name: "lockscreen"
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        color: "#1b1b1b"

        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true

        visible: LockscreenService.locked

        Content {
            anchors.fill: parent
        }
    }
}
