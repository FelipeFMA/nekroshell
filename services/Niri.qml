pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property list<Client> clients: []
    property var workspaces: ({})
    property var monitors: ({})
    property Client activeClient: null
    readonly property var activeWorkspace: {
        const workspacesList = Object.values(workspaces);
        return workspacesList.find(w => w.is_focused) ?? null;
    }
    readonly property var focusedMonitor: {
        const monitorsList = Object.values(monitors);
        return monitorsList.find(m => m.is_focused) ?? null;
    }
    readonly property int activeWsId: activeWorkspace?.idx ?? 1
    property point cursorPos

    function reload() {
        getWorkspaces.running = true;
        getMonitors.running = true;
        getClients.running = true;
        getActiveClient.running = true;
    }

    function dispatch(request: string): void {
        // Parse Hyprland-style commands and convert to Niri actions
        if (request.startsWith("workspace ")) {
            const wsId = request.substring(10);
            if (wsId.startsWith("r+") || wsId.startsWith("r-")) {
                // Relative workspace change
                if (wsId.startsWith("r+")) {
                    dispatchProcess.command = ["niri", "msg", "action", "focus-workspace-down"];
                } else {
                    dispatchProcess.command = ["niri", "msg", "action", "focus-workspace-up"];
                }
            } else {
                // Absolute workspace change - use workspace index directly
                dispatchProcess.command = ["niri", "msg", "action", "focus-workspace", wsId];
            }
            dispatchProcess.running = true;
        } else if (request.startsWith("togglespecialworkspace")) {
            // Niri doesn't have special workspaces, ignore
            console.log("Special workspaces not supported in Niri");
        }
    }

    Component.onCompleted: reload()

    // Fast workspace polling for responsive switching
    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: getWorkspaces.running = true
    }

    // Slower polling for clients and monitors
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            getClients.running = true;
            getActiveClient.running = true;
            getMonitors.running = true;
        }
    }

    Process {
        id: dispatchProcess
        command: []
    }

    Process {
        id: getWorkspaces
        command: ["niri", "msg", "-j", "workspaces"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const workspacesList = JSON.parse(text);
                    const newWorkspaces = {};

                    for (const ws of workspacesList) {
                        // Only add if we don't have this workspace yet, or if this one is focused
                        if (!newWorkspaces[ws.idx] || ws.is_focused) {
                            newWorkspaces[ws.idx] = {
                                id: ws.idx,
                                idx: ws.idx,
                                name: ws.name || ws.idx.toString(),
                                is_focused: ws.is_focused,
                                is_active: ws.is_active,
                                output: ws.output,
                                niri_id: ws.id,
                                lastIpcObject: {
                                    windows: root.clients.filter(c => c.workspace?.idx === ws.idx).length
                                }
                            };
                        }
                    }

                    root.workspaces = newWorkspaces;
                } catch (e) {
                    console.error("Failed to parse workspaces:", e);
                }
            }
        }
    }

    Process {
        id: getMonitors
        command: ["niri", "msg", "-j", "outputs"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const monitorsObj = JSON.parse(text);
                    const newMonitors = {};

                    for (const [name, monitor] of Object.entries(monitorsObj)) {
                        newMonitors[name] = {
                            name: name,
                            is_focused: false // Niri doesn't provide focused info in outputs
                        };
                    }

                    root.monitors = newMonitors;
                } catch (e) {
                    console.error("Failed to parse monitors:", e);
                }
            }
        }
    }

    Process {
        id: getClients
        command: ["niri", "msg", "-j", "windows"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const clientsList = JSON.parse(text);
                    const rClients = root.clients;

                    // Remove destroyed clients
                    const destroyed = rClients.filter(rc => !clientsList.find(c => c.id === rc.id));
                    for (const client of destroyed) {
                        const index = rClients.indexOf(client);
                        if (index > -1) {
                            rClients.splice(index, 1);
                            client.destroy();
                        }
                    }

                    // Add or update clients
                    for (const client of clientsList) {
                        const match = rClients.find(c => c.id === client.id);
                        if (match) {
                            match.lastIpcObject = client;
                        } else {
                            rClients.push(clientComp.createObject(root, {
                                lastIpcObject: client
                            }));
                        }
                    }
                } catch (e) {
                    console.error("Failed to parse clients:", e);
                }
            }
        }
    }

    Process {
        id: getActiveClient
        command: ["niri", "msg", "-j", "focused-window"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const client = JSON.parse(text);
                    const rClient = root.activeClient;

                    if (client && client.id) {
                        if (rClient && rClient.id === client.id) {
                            rClient.lastIpcObject = client;
                        } else {
                            if (rClient) {
                                rClient.destroy();
                            }
                            root.activeClient = clientComp.createObject(root, {
                                lastIpcObject: client
                            });
                        }
                    } else if (rClient) {
                        rClient.destroy();
                        root.activeClient = null;
                    }
                } catch (e) {
                    // No focused window or error parsing
                    if (root.activeClient) {
                        root.activeClient.destroy();
                        root.activeClient = null;
                    }
                }
            }
        }
    }

    component Client: QtObject {
        required property var lastIpcObject
        readonly property int id: lastIpcObject.id
        readonly property string wmClass: lastIpcObject.app_id || ""
        readonly property string title: lastIpcObject.title || ""
        readonly property string initialClass: lastIpcObject.app_id || ""
        readonly property string initialTitle: lastIpcObject.title || ""
        readonly property int x: 0 // Niri doesn't provide window coordinates
        readonly property int y: 0
        readonly property int width: 0
        readonly property int height: 0
        readonly property var workspace: {
            // Find workspace by Niri ID
            const workspacesList = Object.values(root.workspaces);
            return workspacesList.find(w => w.niri_id === lastIpcObject.workspace_id) ?? null;
        }
        readonly property bool floating: lastIpcObject.is_floating || false
        readonly property bool fullscreen: false // Niri doesn't provide this in window info
        readonly property int pid: lastIpcObject.pid || 0
        readonly property int focusHistoryId: lastIpcObject.id
    }

    Component {
        id: clientComp

        Client {}
    }
}
