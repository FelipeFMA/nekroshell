import "root:/utils"
import "root:/config"
import Quickshell
import Quickshell.Wayland

PanelWindow {
    required property string name

    WlrLayershell.namespace: `nekroshell-${name}`
    color: "transparent"
}
