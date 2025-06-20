pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property list<AccessPoint> networks: []
    readonly property AccessPoint active: networks.find(n => n.active) ?? null
    
    property bool connectionInProgress: false
    property string connectionResult: ""
    property bool wifiEnabled: true

    reloadableId: "network"

    function refreshNetworks() {
        getNetworks.running = true;
    }

    function setWifiEnabled(enabled) {
        console.log("WiFi setEnabled called:", enabled);
        wifiToggleProcess.command = ["nmcli", "radio", "wifi", enabled ? "on" : "off"];
        wifiToggleProcess.running = true;
        // Add a short delay before checking status
        Qt.createQmlObject('import QtQuick 2.0; Timer { interval: 500; repeat: false; onTriggered: getRadioStatus.running = true; }', root, 'WifiStatusDelay').start();
    }

    function connectToNetwork(ssid, password = "") {
        connectionInProgress = true;
        connectionResult = "";
        
        if (password === "") {
            // First try to connect using saved connection
            connectKnownProcess.command = ["nmcli", "connection", "up", "id", ssid];
            connectKnownProcess.running = true;
        } else {
            // Connect to secured network with password
            connectProcess.command = ["nmcli", "device", "wifi", "connect", ssid, "password", password];
            connectProcess.running = true;
        }
    }

    function disconnectFromNetwork() {
        disconnectProcess.running = true;
    }

    Process {
        id: connectKnownProcess
        running: false
        stdout: SplitParser {
            onRead: {
                const output = text.trim();
                if (output.includes("successfully activated") || output.includes("Connection successfully activated")) {
                    console.log("Connected using saved connection");
                    root.connectionInProgress = false;
                    root.connectionResult = "success";
                    getNetworks.running = true;
                } else {
                    console.log("Connection output:", output);
                }
            }
        }
        stderr: SplitParser {
            onRead: {
                console.log("Failed to connect with saved connection, need password");
                root.connectionInProgress = false;
                root.connectionResult = "need_password";
            }
        }
    }

    Process {
        id: connectProcess
        running: false
        stdout: SplitParser {
            onRead: {
                console.log("Network connection result:", text);
                root.connectionInProgress = false;
                root.connectionResult = text.includes("successfully") ? "success" : "failed";
                getNetworks.running = true; // Refresh network list
            }
        }
        stderr: SplitParser {
            onRead: {
                console.log("Network connection error:", text);
                root.connectionInProgress = false;
                root.connectionResult = "failed";
            }
        }
    }

    Process {
        id: disconnectProcess
        running: false
        command: ["nmcli", "connection", "down", "id", root.active?.ssid ?? ""]
        stdout: SplitParser {
            onRead: {
                console.log("Network disconnection result:", text);
                getNetworks.running = true; // Refresh network list
            }
        }
    }

    Process {
        id: wifiToggleProcess
        running: false
        stdout: SplitParser {
            onRead: {
                console.log("WiFi toggle result:", text);
                getRadioStatus.running = true; // Check new radio status
            }
        }
        stderr: SplitParser {
            onRead: {
                console.log("WiFi toggle error:", text);
                getRadioStatus.running = true; // Check radio status anyway
            }
        }
    }

    Process {
        id: getRadioStatus
        running: true
        command: ["nmcli", "radio", "wifi"]
        stdout: SplitParser {
            onRead: {
                var raw = typeof line !== "undefined" ? line
                        : typeof text !== "undefined" ? text
                        : typeof data !== "undefined" ? data
                        : typeof output !== "undefined" ? output
                        : "";
                const status = raw.trim().toLowerCase();
                root.wifiEnabled = status === "enabled";
            }
        }
    }

    Process {
        running: true
        command: ["nmcli", "m"]
        stdout: SplitParser {
            onRead: getNetworks.running = true
        }
    }

    Process {
        id: getNetworks
        running: true
        command: ["nmcli", "-g", "ACTIVE,SIGNAL,FREQ,SSID,BSSID,SECURITY", "d", "w"]
        stdout: StdioCollector {
            onStreamFinished: {
                const PLACEHOLDER = "STRINGWHICHHOPEFULLYWONTBEUSED";
                const rep = new RegExp("\\\\:", "g");
                const rep2 = new RegExp(PLACEHOLDER, "g");

                const networks = text.trim().split("\n").map(n => {
                    const net = n.replace(rep, PLACEHOLDER).split(":");
                    return {
                        active: net[0] === "yes",
                        strength: parseInt(net[1]) || 0,
                        frequency: parseInt(net[2]) || 0,
                        ssid: net[3] || "",
                        bssid: (net[4] || "").replace(rep2, ":"),
                        security: net[5] || ""
                    };
                }).filter(n => n.ssid !== "");
                const rNetworks = root.networks;

                const destroyed = rNetworks.filter(rn => !networks.find(n => n.frequency === rn.frequency && n.ssid === rn.ssid && n.bssid === rn.bssid));
                for (const network of destroyed)
                    rNetworks.splice(rNetworks.indexOf(network), 1).forEach(n => n.destroy());

                for (const network of networks) {
                    const match = rNetworks.find(n => n.frequency === network.frequency && n.ssid === network.ssid && n.bssid === network.bssid);
                    if (match) {
                        match.lastIpcObject = network;
                    } else {
                        rNetworks.push(apComp.createObject(root, {
                            lastIpcObject: network
                        }));
                    }
                }
            }
        }
    }

    component AccessPoint: QtObject {
        required property var lastIpcObject
        readonly property string ssid: lastIpcObject.ssid || ""
        readonly property string bssid: lastIpcObject.bssid || ""
        readonly property int strength: lastIpcObject.strength || 0
        readonly property int frequency: lastIpcObject.frequency || 0
        readonly property bool active: lastIpcObject.active || false
        readonly property string security: lastIpcObject.security || ""
        readonly property bool isSecured: security !== "" && security !== "--"
    }

    Component {
        id: apComp

        AccessPoint {}
    }

    Component.onCompleted: {
        getRadioStatus.running = true;
    }
}
