pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool isHyprland: false
    property bool isNiri: false

    property var hyprlandService: isHyprland ? hyprlandLoader.item : null
    property var niriService: isNiri ? niriLoader.item : null

    readonly property var activeService: isHyprland ? hyprlandService : niriService

    // Unified API properties
    readonly property var clients: activeService?.clients ?? []
    readonly property var workspaces: activeService?.workspaces ?? ({})
    readonly property var monitors: activeService?.monitors ?? ({})
    readonly property var activeClient: activeService?.activeClient ?? null
    readonly property var activeWorkspace: activeService?.activeWorkspace ?? null
    readonly property var focusedMonitor: activeService?.focusedMonitor ?? null
    readonly property int activeWsId: activeService?.activeWsId ?? 1
    readonly property point cursorPos: activeService?.cursorPos ?? Qt.point(0, 0)

    function reload() {
        if (activeService && typeof activeService.reload === "function") {
            activeService.reload();
        }
    }

    function dispatch(request: string): void {
        if (activeService && typeof activeService.dispatch === "function") {
            activeService.dispatch(request);
        }
    }

    Loader {
        id: hyprlandLoader
        active: isHyprland
        asynchronous: false
        source: isHyprland ? "Hyprland.qml" : ""
    }

    Loader {
        id: niriLoader
        active: isNiri
        asynchronous: false
        source: isNiri ? "Niri.qml" : ""
    }

    Process {
        id: envCheck
        command: ["env"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const envVars = text.split('\n');
                const hasHyprland = envVars.some(line => line.startsWith('HYPRLAND_INSTANCE_SIGNATURE='));
                const hasNiri = envVars.some(line => line.startsWith('NIRI_SOCKET='));

                root.isHyprland = hasHyprland;
                root.isNiri = hasNiri;

                console.log("WindowManager environment detected");
                console.log("Hyprland available:", hasHyprland);
                console.log("Niri available:", hasNiri);
                console.log("Active service:", root.activeService ? (hasHyprland ? "Hyprland" : "Niri") : "None");

                if (root.activeService) {
                    root.reload();
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("WindowManager initialized");
    }
}
